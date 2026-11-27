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
function ____exports.drawReloadPatternGlyph(draw, cx, cy, radius, effect, col, alpha) -- 151
	if alpha == nil then -- 151
		alpha = 1 -- 158
	end -- 158
	local stroke = toColor(col, 235 * alpha) -- 160
	local faint = toColor(col, 130 * alpha) -- 161
	local r = math.max(5, radius) -- 162
	if effect == "echo" then -- 162
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
	if effect == "light" then -- 176
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
	if effect == "knockback" then -- 195
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
	if injected ~= nil then -- 256
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
	if loaded == nil then -- 261
		return nil -- 263
	end -- 263
	local feHook = loaded["watch.fe"] -- 265
	if feHook ~= nil and type(feHook) == "table" then -- 265
		local c = feHook.contract -- 267
		if c ~= nil and type(c) == "table" then -- 267
			return c -- 269
		end -- 269
	end -- 269
	return nil -- 272
end -- 256
local function dispatchIntentFallback(p, intent) -- 275
	local rec = p -- 276
	local handler = rec.submitFeIntent -- 277
	if type(handler) == "function" then -- 277
		return handler(p, intent) ~= false -- 279
	end -- 279
	local tap = rec.reloadTapNode -- 281
	if type(tap) == "function" and intent.kind == "reloadTapNode" then -- 281
		tap(p, intent.node) -- 283
		return true -- 284
	end -- 284
	return false -- 286
end -- 275
local function readOptionalNum(obj, key) -- 289
	if obj ~= nil and type(obj) == "table" then -- 289
		local v = obj[key] -- 291
		if type(v) == "number" then -- 291
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
	if type(Keyboard) ~= "nil" then -- 419
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
	if contract ~= nil then -- 431
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
	if soldierUiX < ctx.uiW * 0.56 then -- 443
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
	if ctx.paused then -- 463
		self:resetInputEdges(ctx.input:isTouchMode()) -- 467
		return -- 468
	end -- 468
	local udt = math.max(0, ctx.uiDt) -- 471
	local wdt = math.max(0, ctx.worldDt) -- 472
	self.animTime = self.animTime + udt -- 473
	if self.localInvalidFlash > 0 then -- 473
		self.localInvalidFlash = math.max(0, self.localInvalidFlash - udt) -- 476
	end -- 476
	if rs.invalidFlash > self.localInvalidFlash then -- 476
		self.localInvalidFlash = rs.invalidFlash -- 479
	end -- 479
	self:ingestAppliedEffects(ctx) -- 483
	self:updateAppliedVfx(wdt) -- 484
	if rs.active and not self.wasActive then -- 484
		self:onSessionOpened(ctx) -- 488
	elseif not rs.active and self.wasActive then -- 488
		self:onSessionClosed(ctx) -- 490
	end -- 490
	self.wasActive = rs.active -- 492
	if not rs.active then -- 492
		self.lastKnownNextEffect = rs.nextEffect -- 495
		self.lastClock.active = false -- 496
		if self.retractAnimT > 0 then -- 496
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
	if liveAns ~= nil and liveWorld ~= nil and not ctx.view.isRehearsal then -- 509
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
			if ctx.events.rawEvents[i + 1].name == "reloadOpen" then -- 548
				hasBackendOpen = true -- 550
				break -- 551
			end -- 551
			i = i + 1 -- 548
		end -- 548
	end -- 548
	if not hasBackendOpen then -- 548
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
	if #self.settledPath > 0 and self.settledPath[#self.settledPath] ~= ____exports.RELOAD_TARGET_NODE and rs.nextEffect ~= "normal" then -- 569
		local ____self_settledPath_3 = self.settledPath -- 569
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
			if n == "reloadSolved" or n == "reloadTimeout" then -- 582
				hasBackendClose = true -- 584
				break -- 585
			end -- 585
			i = i + 1 -- 581
		end -- 581
	end -- 581
	if self.settledTimedOut then -- 581
		if not hasBackendClose then -- 581
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
	if pointerMoved or leftPressed then -- 657
		self.pointerActive = true -- 660
	end -- 660
	local lastNode = activePath[#activePath] -- 663
	local useTouchHit = touchMode or ctx.input.uiHeld or ctx.input.uiPressed -- 664
	local activeHitR = useTouchHit and 38 or self.hitRadius -- 665
	local hitNode = inside and self:hitTestNode(ptrX, ptrY, activeHitR) or -1 -- 666
	local hitResetBtn = inside and (touchMode or #activePath > 1) and self.resetBox:containsPoint(Vec2(ptrX, ptrY)) -- 669
	if (rightPressed or leftPressed and hitResetBtn) and #activePath > 1 then -- 669
		self.dragging = false -- 671
		self.dragAdvanced = false -- 672
		self:triggerInvalidReset(ctx, activePath, false) -- 673
		return -- 674
	end -- 674
	if leftPressed then -- 674
		if hitNode == ____exports.RELOAD_START_NODE or hitNode == lastNode then -- 674
			self.dragging = true -- 680
			self.dragAdvanced = false -- 681
			self.kbCursor = lastNode -- 682
		elseif hitNode >= 0 then -- 682
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 682
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
	elseif self.dragging and leftHeld then -- 693
		if hitNode >= 0 and hitNode ~= lastNode then -- 693
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 693
				self.dragAdvanced = true -- 698
				self:commitNodeStep(ctx, hitNode, activePath) -- 699
			else -- 699
				self.dragging = false -- 702
				self.dragAdvanced = false -- 703
				self:triggerInvalidReset(ctx, activePath, true) -- 704
			end -- 704
			return -- 706
		end -- 706
	elseif leftReleased and self.dragging then -- 706
		local wasDragStroke = self.dragAdvanced -- 709
		self.dragging = false -- 710
		self.dragAdvanced = false -- 711
		if wasDragStroke and lastNode ~= ____exports.RELOAD_TARGET_NODE and #activePath > 1 then -- 711
			self:triggerInvalidReset(ctx, activePath, true) -- 714
			return -- 715
		end -- 715
	end -- 715
	local dCol = 0 -- 720
	local dRow = 0 -- 721
	local confirmPressed = false -- 722
	local resetPressed = false -- 723
	local gpAutoCommit = false -- 724
	if sim ~= nil and (sim.moveCol ~= nil or sim.moveRow ~= nil or sim.confirm ~= nil or sim.reset ~= nil) then -- 724
		dCol = sim.moveCol or 0 -- 727
		dRow = sim.moveRow or 0 -- 728
		confirmPressed = sim.confirm == true -- 729
		resetPressed = sim.reset == true -- 730
	else -- 730
		if type(Keyboard) ~= "nil" then -- 730
			local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 733
			local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 734
			local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 735
			local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 736
			local confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 737
			local reset = Keyboard:isKeyPressed("BackSpace") -- 738
			if up and not self.prevUp then -- 738
				dRow = dRow + 1 -- 740
			end -- 740
			if down and not self.prevDown then -- 740
				dRow = dRow - 1 -- 741
			end -- 741
			if rk and not self.prevRightKey then -- 741
				dCol = dCol + 1 -- 742
			end -- 742
			if lk and not self.prevLeftKey then -- 742
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
		if ctx.input.reloadReset then -- 752
			resetPressed = true -- 755
		end -- 755
		if ctx.input.reloadConfirm then -- 755
			confirmPressed = true -- 758
		end -- 758
		if dCol == 0 and dRow == 0 and ctx.input.reloadStepEdge then -- 758
			dCol = ctx.input.reloadDirCol -- 761
			dRow = ctx.input.reloadDirRow -- 762
			gpAutoCommit = ctx.input.reloadAutoStep -- 763
		end -- 763
	end -- 763
	if resetPressed and #activePath > 1 then -- 763
		self:triggerInvalidReset(ctx, activePath, false) -- 768
		return -- 769
	end -- 769
	if dCol ~= 0 or dRow ~= 0 then -- 769
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
		if gpAutoCommit and nextIdx ~= lastNode and __TS__ArrayIndexOf(activePath, nextIdx) < 0 and ____exports.isAdjacentNode(lastNode, nextIdx) then -- 779
			self:commitNodeStep(ctx, nextIdx, activePath) -- 781
			return -- 782
		end -- 782
	end -- 782
	if confirmPressed then -- 782
		self.pointerActive = false -- 787
		if self.kbCursor == lastNode then -- 787
			return -- 789
		end -- 789
		if __TS__ArrayIndexOf(activePath, self.kbCursor) < 0 and ____exports.isAdjacentNode(lastNode, self.kbCursor) then -- 789
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
	if node == ____exports.RELOAD_TARGET_NODE then -- 802
		self.dragging = false -- 804
		return -- 805
	end -- 805
	self.nodePulseSeq = self.nodePulseSeq + 1 -- 808
	local stepIdx = math.max( -- 809
		1, -- 809
		math.min(6, #self.lastKnownPath) -- 809
	) -- 809
	local pitched = ("assets/audio/combat/reload_node_" .. tostring(stepIdx)) .. ".wav" -- 810
	local nodePath = Content:exist(pitched) and pitched or "assets/audio/combat/reload_node.wav" -- 811
	ctx.audio:playOnce( -- 812
		(((("fe02:reload_node:r" .. tostring(ctx.events.roomSessionId)) .. ":n") .. tostring(self.nodePulseSeq)) .. ":") .. tostring(node), -- 813
		"sfx", -- 814
		nodePath, -- 815
		0.78, -- 816
		"reload:node:" .. tostring(node), -- 817
		ctx.p.ticks -- 818
	) -- 818
end -- 799
function ReloadWheelPlugin.prototype.triggerInvalidReset(self, ctx, activePath, flashError) -- 822
	if flashError then -- 822
		self.localInvalidFlash = 0.36 -- 824
	end -- 824
	self.kbCursor = ____exports.RELOAD_START_NODE -- 826
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 827
	if #activePath > 1 then -- 827
		self:submitIntent(ctx.p, {kind = "reloadTapNode", node = ____exports.RELOAD_START_NODE}) -- 830
	end -- 830
	if flashError then -- 830
		self.nodePulseSeq = self.nodePulseSeq + 1 -- 833
		ctx.audio:playOnce( -- 834
			(("fe02:reload_invalid:r" .. tostring(ctx.events.roomSessionId)) .. ":e") .. tostring(self.nodePulseSeq), -- 835
			"sfx", -- 836
			"assets/audio/combat/reload_invalid.wav", -- 837
			0.72, -- 838
			"reload:invalid", -- 839
			ctx.p.ticks -- 840
		) -- 840
	end -- 840
end -- 822
function ReloadWheelPlugin.prototype.hitTestNode(self, uiX, uiY, hitR) -- 845
	if hitR == nil then -- 845
		hitR = self.hitRadius -- 845
	end -- 845
	local r2 = hitR * hitR -- 846
	local i = 0 -- 847
	do -- 847
		i = 0 -- 848
		while i < #____exports.RELOAD_GRID do -- 848
			local pos = self:getNodeUiPos(i) -- 849
			local dx = uiX - pos.x -- 850
			local dy = uiY - pos.y -- 851
			if dx * dx + dy * dy <= r2 then -- 851
				return i -- 853
			end -- 853
			i = i + 1 -- 848
		end -- 848
	end -- 848
	return -1 -- 856
end -- 845
function ReloadWheelPlugin.prototype.ingestAppliedEffects(self, ctx) -- 859
	local p = ctx.p -- 860
	local triggered = false -- 861
	local i = 0 -- 862
	do -- 862
		i = 0 -- 863
		while i < #ctx.events.rawEvents do -- 863
			local e = ctx.events.rawEvents[i + 1] -- 864
			if e.name == "reloadApplied" then -- 864
				local rawEff = e.data.effect -- 866
				local eff = rawEff == "echo" and "echo" or (rawEff == "light" and "light" or "knockback") -- 867
				local ex = type(e.data.enemyX) == "number" and e.data.enemyX or p.player.x + p.player.facing * 200 -- 870
				self:spawnAppliedVfx(eff, p, ex) -- 871
				triggered = true -- 872
			end -- 872
			i = i + 1 -- 863
		end -- 863
	end -- 863
	if not triggered and ctx.events.shotFired and self.lastKnownNextEffect ~= "normal" and ctx.view.reloadSession.nextEffect == "normal" then -- 863
		local tx = ctx.events.shotTrace ~= nil and ctx.events.shotTrace.x1 or p.player.x + p.player.facing * 220 -- 877
		self:spawnAppliedVfx(self.lastKnownNextEffect, p, tx) -- 878
	end -- 878
end -- 859
function ReloadWheelPlugin.prototype.spawnAppliedVfx(self, effect, p, targetX) -- 882
	local originX = p.player.x + p.player.facing * 18 -- 883
	local originY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.62 -- 884
	local targetY = p.player.y + p.player.depth * DEPTH_Y_SCALE + 46 -- 885
	local maxLife = effect == "light" and 0.42 or (effect == "echo" and 0.56 or 0.34) -- 886
	local ____self_appliedVfx_31 = self.appliedVfx -- 886
	____self_appliedVfx_31[#____self_appliedVfx_31 + 1] = { -- 887
		effect = effect, -- 888
		originX = originX, -- 889
		originY = originY, -- 890
		targetX = targetX, -- 891
		targetY = targetY, -- 892
		facing = p.player.facing >= 0 and 1 or -1, -- 893
		life = maxLife, -- 894
		maxLife = maxLife -- 895
	} -- 895
end -- 882
function ReloadWheelPlugin.prototype.updateAppliedVfx(self, wdt) -- 899
	if wdt <= 0 or #self.appliedVfx == 0 then -- 899
		return -- 901
	end -- 901
	local w = 0 -- 903
	local i = 0 -- 904
	do -- 904
		i = 0 -- 905
		while i < #self.appliedVfx do -- 905
			local fx = self.appliedVfx[i + 1] -- 906
			fx.life = fx.life - wdt -- 907
			if fx.life > 0 then -- 907
				self.appliedVfx[w + 1] = fx -- 909
				w = w + 1 -- 910
			end -- 910
			i = i + 1 -- 905
		end -- 905
	end -- 905
	__TS__ArraySetLength(self.appliedVfx, w) -- 905
end -- 899
function ReloadWheelPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 917
	if #self.appliedVfx == 0 then -- 917
		return -- 924
	end -- 924
	local cam = ctx.cam -- 926
	local i = 0 -- 927
	do -- 927
		i = 0 -- 928
		while i < #self.appliedVfx do -- 928
			local fx = self.appliedVfx[i + 1] -- 929
			local k = math.max( -- 930
				0, -- 930
				math.min(1, fx.life / fx.maxLife) -- 930
			) -- 930
			local prog = 1 - k -- 931
			local ox = cam:sx(fx.originX) -- 932
			local oy = cam:sy(fx.originY) -- 933
			local tx = cam:sx(fx.targetX) -- 934
			local ty = cam:sy(fx.targetY) -- 935
			if fx.effect == "knockback" then -- 935
				local r = cam:len(12 + prog * 34) -- 939
				local startA = fx.facing >= 0 and -48 or 132 -- 940
				local endA = fx.facing >= 0 and 48 or 228 -- 941
				fgGlow:drawArc( -- 942
					Vec2(tx, ty), -- 942
					r, -- 942
					startA, -- 942
					endA, -- 942
					2.4 * k, -- 942
					toColor(PALETTE.moonPale, 210 * k) -- 942
				) -- 942
				fgDraw:drawArc( -- 943
					Vec2( -- 943
						tx - fx.facing * cam:len(6), -- 943
						ty -- 943
					), -- 943
					r * 0.72, -- 943
					startA, -- 943
					endA, -- 943
					1.5 * k, -- 943
					toColor(PALETTE.silkLine, 165 * k) -- 943
				) -- 943
			elseif fx.effect == "echo" then -- 943
				local r1 = cam:len(10 + prog * 64) -- 946
				local r2 = cam:len(6 + prog * 40) -- 947
				fgGlow:drawRing( -- 948
					Vec2(tx, ty), -- 948
					math.max(1, r1 - 1.6), -- 948
					r1, -- 948
					Color(0, 0, 0, 0), -- 948
					1.3, -- 948
					toColor(PALETTE.amber, 210 * k) -- 948
				) -- 948
				fgGlow:drawRing( -- 949
					Vec2(tx, ty), -- 949
					math.max(1, r2 - 1.2), -- 949
					r2, -- 949
					Color(0, 0, 0, 0), -- 949
					1, -- 949
					toColor(PALETTE.amberCore, 175 * k) -- 949
				) -- 949
			elseif fx.effect == "light" then -- 949
				fgGlow:drawSegment( -- 952
					Vec2(ox, oy), -- 952
					Vec2(tx, ty), -- 952
					5 * k, -- 952
					toColor(PALETTE.amber, 68 * k) -- 952
				) -- 952
				fgGlow:drawSegment( -- 953
					Vec2(ox, oy), -- 953
					Vec2(tx, ty), -- 953
					1.8 * k, -- 953
					toColor(PALETTE.amberCore, 185 * k) -- 953
				) -- 953
				fillRadialGlow( -- 954
					fgGlow, -- 954
					tx, -- 954
					ty, -- 954
					cam:len(42 * (0.6 + prog * 0.4)), -- 954
					cam:len(34), -- 954
					toColor(PALETTE.amberCore, 118 * k), -- 954
					Color(244, 234, 214, 0), -- 954
					16 -- 954
				) -- 954
			end -- 954
			i = i + 1 -- 928
		end -- 928
	end -- 928
end -- 917
function ReloadWheelPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 960
	local rs = ctx.view.reloadSession -- 967
	local active = rs.active -- 968
	local retracting = not active and self.retractAnimT > 0.01 -- 969
	if not active and not retracting then -- 969
		if rs.nextEffect ~= "normal" and not ctx.view.craftBench.active then -- 969
			self:drawArmedEffectBadge( -- 973
				uiDraw, -- 973
				uiInkDraw, -- 973
				uiArt, -- 973
				ctx, -- 973
				rs.nextEffect -- 973
			) -- 973
		end -- 973
		return false -- 975
	end -- 975
	local cx = self.panelCx -- 978
	local cy = self.panelCy -- 979
	local pw = self.panelW -- 980
	local ph = self.panelH -- 981
	local x0 = cx - pw * 0.5 -- 982
	local y0 = cy - ph * 0.5 -- 983
	local appear = active and math.min(1, self.openAnimT) or math.max( -- 985
		0, -- 987
		self.retractAnimT / math.max(0.01, self.retractDuration) -- 987
	) -- 987
	local shakeX = self.localInvalidFlash > 0 and math.sin(self.animTime * 62) * 5.5 * (self.localInvalidFlash / 0.36) or 0 -- 988
	local px = cx + shakeX -- 991
	if active then -- 991
		uiDraw:drawRect( -- 995
			Rect(0, 0, ctx.uiW, ctx.uiH), -- 995
			Color( -- 995
				10, -- 995
				13, -- 995
				20, -- 995
				math.floor(54 * appear + 0.5) -- 995
			) -- 995
		) -- 995
	end -- 995
	drawSilkVeil( -- 999
		uiDraw, -- 999
		uiArt, -- 999
		"rw_outer_veil", -- 999
		px, -- 999
		cy, -- 999
		pw + 34, -- 999
		ph + 28, -- 999
		PALETTE.inkWash, -- 999
		0.72 * appear, -- 999
		-2 -- 999
	) -- 999
	if not uiArt:tryPlace( -- 999
		"ink_song_paper", -- 1000
		"rw_paper", -- 1000
		px, -- 1000
		cy, -- 1000
		pw, -- 1000
		ph, -- 1000
		{opacity = 0.94 * appear, layer = 1} -- 1000
	) then -- 1000
		uiDraw:drawRoundedRect( -- 1001
			Rect(x0 + shakeX, y0, pw, ph), -- 1002
			6, -- 1003
			toColor(PALETTE.xuanPaper, 240 * appear), -- 1004
			1.2, -- 1005
			toColor(PALETTE.xuanInkSub, 180 * appear) -- 1006
		) -- 1006
	end -- 1006
	local frameCol = self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInkSub -- 1009
	drawFiligreeCorners( -- 1010
		uiInkDraw, -- 1010
		uiArt, -- 1010
		"rw_frame", -- 1010
		x0 + shakeX + 8, -- 1010
		y0 + 8, -- 1010
		pw - 16, -- 1010
		ph - 16, -- 1010
		frameCol, -- 1010
		0.72 * appear, -- 1010
		22, -- 1010
		true, -- 1010
		2 -- 1010
	) -- 1010
	local activePath = active and (#rs.path > 0 and rs.path or ({____exports.RELOAD_START_NODE})) or self.settledPath -- 1013
	local previewEffect = active and (#rs.path >= 2 and ____exports.deriveEffectFromGrid(activePath) or rs.previewEffect) or self.settledEffect -- 1016
	local effAccent = self:effectInkColor(previewEffect) -- 1019
	local headY = y0 + ph - 32 -- 1021
	____exports.drawReloadPatternGlyph( -- 1022
		uiInkDraw, -- 1022
		px - 52, -- 1022
		headY, -- 1022
		11, -- 1022
		previewEffect, -- 1022
		effAccent, -- 1022
		appear -- 1022
	) -- 1022
	local titleText = active and ____exports.reloadEffectShortLabel(previewEffect) or (self.settledTimedOut and "普通装填" or ____exports.reloadEffectShortLabel(self.settledEffect)) -- 1023
	ctx.texts:put( -- 1026
		"sm", -- 1027
		titleText, -- 1028
		px - 32, -- 1029
		headY, -- 1030
		toColor(self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInk), -- 1031
		0, -- 1032
		0.5, -- 1033
		"Left", -- 1034
		1.6, -- 1035
		0.96 * appear, -- 1036
		0 -- 1037
	) -- 1037
	if active and (ctx.input:isTouchMode() or #activePath > 1) then -- 1037
		local canReset = #activePath > 1 -- 1040
		local rb = Rect(self.resetBox.x + shakeX, self.resetBox.y, self.resetBox.width, self.resetBox.height) -- 1041
		uiInkDraw:drawRect( -- 1042
			rb, -- 1043
			Color( -- 1044
				32, -- 1044
				30, -- 1044
				32, -- 1044
				math.floor((canReset and 32 or 12) * appear + 0.5) -- 1044
			), -- 1044
			0.85, -- 1045
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub, (canReset and 185 or 95) * appear) -- 1046
		) -- 1046
		ctx.texts:put( -- 1048
			"xs", -- 1049
			"重画", -- 1050
			rb.x + rb.width * 0.5, -- 1051
			rb.y + rb.height * 0.5, -- 1052
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub), -- 1053
			0.5, -- 1054
			0.5, -- 1055
			"Center", -- 1056
			1, -- 1057
			(canReset and 0.94 or 0.52) * appear, -- 1058
			0 -- 1059
		) -- 1059
	end -- 1059
	drawHairline( -- 1062
		uiInkDraw, -- 1062
		uiArt, -- 1062
		"rw_head_line", -- 1062
		px, -- 1062
		headY - 18, -- 1062
		pw - 42, -- 1062
		PALETTE.xuanInkSub, -- 1062
		0.45 * appear, -- 1062
		false, -- 1062
		2 -- 1062
	) -- 1062
	local idx = 0 -- 1065
	do -- 1065
		idx = 0 -- 1066
		while idx < 3 do -- 1066
			local hA = self:getNodeUiPos(idx * 3) -- 1067
			local hB = self:getNodeUiPos(idx * 3 + 2) -- 1068
			uiInkDraw:drawSegment( -- 1069
				Vec2(hA.x + shakeX, hA.y), -- 1069
				Vec2(hB.x + shakeX, hB.y), -- 1069
				0.75, -- 1069
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1069
			) -- 1069
			local vA = self:getNodeUiPos(idx) -- 1070
			local vB = self:getNodeUiPos(6 + idx) -- 1071
			uiInkDraw:drawSegment( -- 1072
				Vec2(vA.x + shakeX, vA.y), -- 1072
				Vec2(vB.x + shakeX, vB.y), -- 1072
				0.75, -- 1072
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1072
			) -- 1072
			idx = idx + 1 -- 1066
		end -- 1066
	end -- 1066
	if #activePath >= 2 then -- 1066
		self:drawPathStrokes( -- 1077
			uiInkDraw, -- 1077
			uiGlow, -- 1077
			activePath, -- 1077
			previewEffect, -- 1077
			effAccent, -- 1077
			shakeX, -- 1077
			appear -- 1077
		) -- 1077
	end -- 1077
	if active and self.dragging and #activePath >= 1 then -- 1077
		local tail = self:getNodeUiPos(activePath[#activePath]) -- 1082
		local mx = ctx.input.uiHeld and ctx.input.uiX / ctx.uiScale or self.lastUiPtrX -- 1083
		local my = ctx.input.uiHeld and ctx.input.uiY / ctx.uiScale or self.lastUiPtrY -- 1084
		uiInkDraw:drawSegment( -- 1085
			Vec2(tail.x + shakeX, tail.y), -- 1085
			Vec2(mx, my), -- 1085
			1.4, -- 1085
			toColor(effAccent, 150 * appear) -- 1085
		) -- 1085
		uiInkDraw:drawDot( -- 1086
			Vec2(mx, my), -- 1086
			3, -- 1086
			toColor(effAccent, 210 * appear) -- 1086
		) -- 1086
	end -- 1086
	local lastNode = #activePath > 0 and activePath[#activePath] or ____exports.RELOAD_START_NODE -- 1090
	do -- 1090
		idx = 0 -- 1091
		while idx < #____exports.RELOAD_GRID do -- 1091
			local spec = ____exports.RELOAD_GRID[idx + 1] -- 1092
			local pos = self:getNodeUiPos(idx) -- 1093
			local nx = pos.x + shakeX -- 1094
			local ny = pos.y -- 1095
			local inPath = __TS__ArrayIndexOf(activePath, idx) >= 0 -- 1096
			local isValidNext = active and not inPath and ____exports.isAdjacentNode(lastNode, idx) -- 1097
			local isKbFocus = active and not self.pointerActive and self.kbCursor == idx -- 1098
			self:drawGridNode( -- 1099
				uiInkDraw, -- 1099
				uiGlow, -- 1099
				spec, -- 1099
				nx, -- 1099
				ny, -- 1099
				inPath, -- 1099
				isValidNext, -- 1099
				isKbFocus, -- 1099
				effAccent, -- 1099
				appear -- 1099
			) -- 1099
			idx = idx + 1 -- 1091
		end -- 1091
	end -- 1091
	self:drawChildFinger( -- 1103
		uiInkDraw, -- 1103
		uiGlow, -- 1103
		active, -- 1103
		activePath, -- 1103
		shakeX, -- 1103
		appear -- 1103
	) -- 1103
	local barW = pw - 52 -- 1106
	local barX = px - barW * 0.5 -- 1107
	local barY = y0 + 28 -- 1108
	local remainFrac = active and math.max( -- 1109
		0, -- 1110
		math.min( -- 1110
			1, -- 1110
			1 - rs.elapsed / math.max(0.01, rs.duration) -- 1110
		) -- 1110
	) or (self.settledTimedOut and 0 or 1) -- 1110
	local urgent = active and remainFrac < 0.25 -- 1112
	local barCol = urgent and PALETTE.rouge or PALETTE.xuanInk -- 1113
	uiInkDraw:drawSegment( -- 1114
		Vec2(barX, barY), -- 1114
		Vec2(barX + barW, barY), -- 1114
		1.4, -- 1114
		toColor(PALETTE.xuanInkSub, 85 * appear) -- 1114
	) -- 1114
	if remainFrac > 0.005 then -- 1114
		uiInkDraw:drawSegment( -- 1116
			Vec2(barX, barY), -- 1116
			Vec2(barX + barW * remainFrac, barY), -- 1116
			3, -- 1116
			toColor(barCol, 225 * appear) -- 1116
		) -- 1116
	end -- 1116
	local tTick = 1 -- 1119
	do -- 1119
		tTick = 1 -- 1120
		while tTick <= 3 do -- 1120
			local tx = barX + barW * (tTick / 4) -- 1121
			uiInkDraw:drawSegment( -- 1122
				Vec2(tx, barY - 3.5), -- 1122
				Vec2(tx, barY + 3.5), -- 1122
				0.9, -- 1122
				toColor(PALETTE.xuanInkSub, 125 * appear) -- 1122
			) -- 1122
			tTick = tTick + 1 -- 1120
		end -- 1120
	end -- 1120
	if active and ctx.view.assistHintsEnabled then -- 1120
		local mode = ctx.input.inputMode -- 1127
		local hint = mode == "gamepad" and ("左摇杆八向直连至右上 · " .. keyTagFor("back", "gamepad", ctx.input.gamepadLayout)) .. " 重画" or (mode == "touch" and "单指一笔滑连至右上 · 点重画清空" or "拖线或方向+回车连至右上") -- 1128
		ctx.texts:put( -- 1133
			"xs", -- 1134
			hint, -- 1135
			px, -- 1136
			y0 + 13, -- 1137
			toColor(PALETTE.xuanInkSub), -- 1138
			0.5, -- 1139
			0.5, -- 1140
			"Center", -- 1141
			0.6, -- 1142
			0.82 * appear, -- 1143
			0 -- 1144
		) -- 1144
	end -- 1144
	return active -- 1148
end -- 960
function ReloadWheelPlugin.prototype.effectInkColor(self, effect) -- 1151
	if effect == "echo" then -- 1151
		return PALETTE.rouge -- 1153
	end -- 1153
	if effect == "light" then -- 1153
		return PALETTE.amberDim -- 1156
	end -- 1156
	if effect == "knockback" then -- 1156
		return PALETTE.xuanInk -- 1159
	end -- 1159
	return PALETTE.xuanInkSub -- 1161
end -- 1151
function ReloadWheelPlugin.prototype.drawPathStrokes(self, uiInkDraw, uiGlow, path, effect, col, shakeX, appear) -- 1164
	local i = 0 -- 1173
	do -- 1173
		i = 0 -- 1174
		while i < #path - 1 do -- 1174
			local p0 = self:getNodeUiPos(path[i + 1]) -- 1175
			local p1 = self:getNodeUiPos(path[i + 1 + 1]) -- 1176
			local ax = p0.x + shakeX -- 1177
			local ay = p0.y -- 1178
			local bx = p1.x + shakeX -- 1179
			local by = p1.y -- 1180
			if effect == "echo" then -- 1180
				local dx = bx - ax -- 1184
				local dy = by - ay -- 1185
				local len = math.max( -- 1186
					1, -- 1186
					math.sqrt(dx * dx + dy * dy) -- 1186
				) -- 1186
				local nx = -dy / len * 2.2 -- 1187
				local ny = dx / len * 2.2 -- 1188
				uiInkDraw:drawSegment( -- 1189
					Vec2(ax + nx, ay + ny), -- 1189
					Vec2(bx + nx, by + ny), -- 1189
					1.35, -- 1189
					toColor(col, 220 * appear) -- 1189
				) -- 1189
				uiInkDraw:drawSegment( -- 1190
					Vec2(ax - nx, ay - ny), -- 1190
					Vec2(bx - nx, by - ny), -- 1190
					1.35, -- 1190
					toColor(col, 220 * appear) -- 1190
				) -- 1190
			elseif effect == "light" then -- 1190
				uiInkDraw:drawSegment( -- 1193
					Vec2(ax, ay), -- 1193
					Vec2(bx, by), -- 1193
					3.1, -- 1193
					toColor(PALETTE.xuanInk, 195 * appear) -- 1193
				) -- 1193
				uiInkDraw:drawSegment( -- 1194
					Vec2(ax, ay), -- 1194
					Vec2(bx, by), -- 1194
					1.3, -- 1194
					toColor(PALETTE.amberCore, 235 * appear) -- 1194
				) -- 1194
				uiGlow:drawSegment( -- 1195
					Vec2(ax, ay), -- 1195
					Vec2(bx, by), -- 1195
					3.2, -- 1195
					toColor(PALETTE.amber, 55 * appear) -- 1195
				) -- 1195
			else -- 1195
				uiInkDraw:drawSegment( -- 1198
					Vec2(ax, ay), -- 1198
					Vec2(bx, by), -- 1198
					2.8, -- 1198
					toColor(col, 230 * appear) -- 1198
				) -- 1198
			end -- 1198
			i = i + 1 -- 1174
		end -- 1174
	end -- 1174
end -- 1164
function ReloadWheelPlugin.prototype.drawGridNode(self, uiInkDraw, uiGlow, spec, nx, ny, inPath, isValidNext, isKbFocus, effAccent, appear) -- 1203
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
			appear -- 1232
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
			appear -- 1243
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
end -- 1203
function ReloadWheelPlugin.prototype.drawChildFinger(self, uiInkDraw, uiGlow, active, path, shakeX, appear) -- 1287
	local fx = 0 -- 1295
	local fy = 0 -- 1296
	if active then -- 1296
		local tipNode = #path > 0 and path[#path] or ____exports.RELOAD_START_NODE -- 1299
		local pos = self:getNodeUiPos(tipNode) -- 1300
		local tapPulse = #path <= 1 and math.sin(self.animTime * 4.8) * 3.5 or 0 -- 1301
		fx = pos.x + shakeX - 6 - tapPulse * 0.4 -- 1302
		fy = pos.y - 6 - tapPulse -- 1303
		if #path <= 1 then -- 1303
			local ringR = 17 + math.sin(self.animTime * 4.2) * 2.5 -- 1306
			uiInkDraw:drawRing( -- 1307
				Vec2(pos.x + shakeX, pos.y), -- 1307
				ringR - 1, -- 1307
				ringR, -- 1307
				Color(0, 0, 0, 0), -- 1307
				1, -- 1307
				toColor(PALETTE.rouge, 130 * appear) -- 1307
			) -- 1307
		end -- 1307
	elseif self.retractAnimT > 0 and #path > 0 then -- 1307
		local prog = math.max( -- 1311
			0, -- 1311
			math.min( -- 1311
				1, -- 1311
				1 - self.retractAnimT / math.max(0.01, self.retractDuration) -- 1311
			) -- 1311
		) -- 1311
		local revFloat = (1 - prog) * (#path - 1) -- 1312
		local idxA = math.max( -- 1313
			0, -- 1313
			math.min( -- 1313
				#path - 1, -- 1313
				math.floor(revFloat) -- 1313
			) -- 1313
		) -- 1313
		local idxB = math.max( -- 1314
			0, -- 1314
			math.min(#path - 1, idxA + 1) -- 1314
		) -- 1314
		local frac = revFloat - idxA -- 1315
		local pA = self:getNodeUiPos(path[idxA + 1]) -- 1316
		local pB = self:getNodeUiPos(path[idxB + 1]) -- 1317
		fx = pA.x + (pB.x - pA.x) * frac + shakeX - prog * 28 -- 1318
		fy = pA.y + (pB.y - pA.y) * frac - prog * 22 -- 1319
	else -- 1319
		return -- 1321
	end -- 1321
	local a255 = math.floor(240 * appear + 0.5) -- 1325
	local inkCol = toColor(PALETTE.xuanInk, 180 * appear) -- 1326
	uiInkDraw:drawPolygon( -- 1327
		{ -- 1327
			Vec2(fx - 30, fy - 20), -- 1328
			Vec2(fx - 22, fy - 28), -- 1329
			Vec2(fx - 11, fy - 14), -- 1330
			Vec2(fx - 17, fy - 9) -- 1331
		}, -- 1331
		Color(164, 78, 54, a255), -- 1332
		1, -- 1332
		inkCol -- 1332
	) -- 1332
	uiInkDraw:drawSegment( -- 1334
		Vec2(fx - 16, fy - 10), -- 1334
		Vec2(fx - 11, fy - 15), -- 1334
		2, -- 1334
		Color(204, 174, 122, a255) -- 1334
	) -- 1334
	uiInkDraw:drawCircle( -- 1336
		Vec2(fx - 9, fy - 8), -- 1336
		4.8, -- 1336
		Color(238, 212, 182, a255) -- 1336
	) -- 1336
	uiInkDraw:drawSegment( -- 1337
		Vec2(fx - 7, fy - 6), -- 1337
		Vec2(fx, fy), -- 1337
		2.5, -- 1337
		Color(244, 222, 196, a255) -- 1337
	) -- 1337
	uiInkDraw:drawRing( -- 1338
		Vec2(fx, fy), -- 1338
		2, -- 1338
		3, -- 1338
		Color(0, 0, 0, 0), -- 1338
		0.9, -- 1338
		inkCol -- 1338
	) -- 1338
	uiGlow:drawDot( -- 1339
		Vec2(fx, fy), -- 1339
		3.4, -- 1339
		toColor(PALETTE.amberCore, 80 * appear) -- 1339
	) -- 1339
end -- 1287
function ReloadWheelPlugin.prototype.drawArmedEffectBadge(self, uiDraw, uiInkDraw, uiArt, ctx, effect) -- 1343
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1350
	local bx = 46 + safe.left -- 1351
	local by = ctx.uiH - 134 - safe.top -- 1352
	local col = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberCore or PALETTE.cyanCore) -- 1353
	drawSilkVeil( -- 1354
		uiDraw, -- 1354
		uiArt, -- 1354
		"rw_armed_veil", -- 1354
		bx + 54, -- 1354
		by, -- 1354
		142, -- 1354
		30, -- 1354
		PALETTE.inkWash, -- 1354
		0.72, -- 1354
		-1 -- 1354
	) -- 1354
	____exports.drawReloadPatternGlyph( -- 1355
		uiInkDraw, -- 1355
		bx + 12, -- 1355
		by, -- 1355
		9, -- 1355
		effect, -- 1355
		col, -- 1355
		0.96 -- 1355
	) -- 1355
	drawBlossomDot( -- 1356
		uiInkDraw, -- 1356
		uiArt, -- 1356
		"rw_armed_dot", -- 1356
		bx + 28, -- 1356
		by, -- 1356
		6, -- 1356
		col, -- 1356
		0.85, -- 1356
		3 -- 1356
	) -- 1356
	ctx.texts:put( -- 1357
		"xs", -- 1357
		____exports.reloadEffectShortLabel(effect), -- 1357
		bx + 38, -- 1357
		by, -- 1357
		toColor(PALETTE.textBright), -- 1357
		0, -- 1357
		0.5, -- 1357
		"Left", -- 1357
		1, -- 1357
		0.94, -- 1357
		0.08 -- 1357
	) -- 1357
end -- 1343
function ____exports.createReloadWheelPlugin(contract) -- 1361
	return __TS__New(____exports.ReloadWheelPlugin, contract) -- 1362
end -- 1361
return ____exports -- 1361