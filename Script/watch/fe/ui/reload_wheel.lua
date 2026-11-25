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
local ____theme = require("Script.watch.fe.theme") -- 29
local PALETTE = ____theme.PALETTE -- 30
local drawBlossomDot = ____theme.drawBlossomDot -- 32
local drawDiamond = ____theme.drawDiamond -- 33
local drawFiligreeCorners = ____theme.drawFiligreeCorners -- 34
local drawHairline = ____theme.drawHairline -- 35
local drawSilkVeil = ____theme.drawSilkVeil -- 36
local fillRadialGlow = ____theme.fillRadialGlow -- 37
local toColor = ____theme.toColor -- 38
____exports.RELOAD_START_NODE = 0 -- 52
____exports.RELOAD_TARGET_NODE = 8 -- 53
--- 3×3 九宫格节点真源表（对齐后端 Script/watch/reload.ts 与 contract.ts）
____exports.RELOAD_GRID = { -- 56
	{id = 0, col = 0, row = 0, kind = "start"}, -- 57
	{id = 1, col = 1, row = 0, kind = "plain"}, -- 58
	{id = 2, col = 2, row = 0, kind = "lamp"}, -- 59
	{id = 3, col = 0, row = 1, kind = "plain"}, -- 60
	{id = 4, col = 1, row = 1, kind = "bell"}, -- 61
	{id = 5, col = 2, row = 1, kind = "plain"}, -- 62
	{id = 6, col = 0, row = 2, kind = "plain"}, -- 63
	{id = 7, col = 1, row = 2, kind = "plain"}, -- 64
	{id = 8, col = 2, row = 2, kind = "target"} -- 65
} -- 65
--- 8 邻域校验（含斜角，不含自身）
function ____exports.isAdjacentNode(a, b) -- 69
	if a == b then -- 69
		return false -- 71
	end -- 71
	local na = ____exports.RELOAD_GRID[a + 1] -- 73
	local nb = ____exports.RELOAD_GRID[b + 1] -- 74
	if na == nil or nb == nil then -- 74
		return false -- 76
	end -- 76
	return math.abs(na.col - nb.col) <= 1 and math.abs(na.row - nb.row) <= 1 -- 78
end -- 69
--- 完整路径合法性校验：起点 0、每步相邻、不重复、终点 8
function ____exports.validateReloadPath(path) -- 82
	if #path < 2 then -- 82
		return false -- 84
	end -- 84
	if path[1] ~= ____exports.RELOAD_START_NODE or path[#path] ~= ____exports.RELOAD_TARGET_NODE then -- 84
		return false -- 87
	end -- 87
	local seen = {} -- 89
	local i = 0 -- 90
	do -- 90
		i = 0 -- 91
		while i < #path do -- 91
			local n = path[i + 1] -- 92
			if n < 0 or n >= #____exports.RELOAD_GRID or seen[n] == true then -- 92
				return false -- 94
			end -- 94
			seen[n] = true -- 96
			if i > 0 and not ____exports.isAdjacentNode(path[i], n) then -- 96
				return false -- 98
			end -- 98
			i = i + 1 -- 91
		end -- 91
	end -- 91
	return true -- 101
end -- 82
--- 按路径经过纹样推导效果（铃纹 4 优先于灯纹 2，其余合法连接为推退 knockback）
function ____exports.deriveEffectFromGrid(path) -- 105
	if #path < 2 then -- 105
		return "normal" -- 107
	end -- 107
	local hasBell = false -- 109
	local hasLamp = false -- 110
	local i = 0 -- 111
	do -- 111
		i = 0 -- 112
		while i < #path do -- 112
			if path[i + 1] == 4 then -- 112
				hasBell = true -- 114
			elseif path[i + 1] == 2 then -- 114
				hasLamp = true -- 116
			end -- 116
			i = i + 1 -- 112
		end -- 112
	end -- 112
	if hasBell then -- 112
		return "echo" -- 120
	end -- 120
	if hasLamp then -- 120
		return "light" -- 123
	end -- 123
	return "knockback" -- 125
end -- 105
function ____exports.reloadEffectShortLabel(effect) -- 128
	if effect == "knockback" then -- 128
		return "推退" -- 130
	end -- 130
	if effect == "echo" then -- 130
		return "回声诱导" -- 133
	end -- 133
	if effect == "light" then -- 133
		return "照亮遮蔽" -- 136
	end -- 136
	return "待起笔" -- 138
end -- 128
--- 绘制静音/灰度可辨的效果几何纹样（供 reload_wheel 与 craft_bench 共享同一符号体系）：
-- - knockback：双尖横冲箭矢（实线）
-- - echo：铜铃轮廓 + 两侧声波弧（虚/双弧）
-- - light：六角提灯轮廓 + 四向破障短芒
-- - normal：素墨空圆
function ____exports.drawReloadPatternGlyph(draw, cx, cy, radius, effect, col, alpha) -- 148
	if alpha == nil then -- 148
		alpha = 1 -- 155
	end -- 155
	local stroke = toColor(col, 235 * alpha) -- 157
	local faint = toColor(col, 130 * alpha) -- 158
	local r = math.max(5, radius) -- 159
	if effect == "echo" then -- 159
		draw:drawPolygon( -- 163
			{ -- 163
				Vec2(cx - r * 0.56, cy - r * 0.36), -- 164
				Vec2(cx + r * 0.56, cy - r * 0.36), -- 165
				Vec2(cx + r * 0.34, cy + r * 0.42), -- 166
				Vec2(cx, cy + r * 0.62), -- 167
				Vec2(cx - r * 0.34, cy + r * 0.42) -- 168
			}, -- 168
			Color(0, 0, 0, 0), -- 169
			1.35, -- 169
			stroke -- 169
		) -- 169
		draw:drawDot( -- 170
			Vec2(cx, cy - r * 0.54), -- 170
			math.max(1.6, r * 0.16), -- 170
			stroke -- 170
		) -- 170
		draw:drawArc( -- 171
			Vec2(cx, cy + r * 0.04), -- 171
			r * 0.92, -- 171
			-32, -- 171
			32, -- 171
			1, -- 171
			faint -- 171
		) -- 171
		draw:drawArc( -- 172
			Vec2(cx, cy + r * 0.04), -- 172
			r * 0.92, -- 172
			148, -- 172
			212, -- 172
			1, -- 172
			faint -- 172
		) -- 172
		return -- 173
	end -- 173
	if effect == "light" then -- 173
		draw:drawPolygon( -- 178
			{ -- 178
				Vec2(cx, cy + r * 0.72), -- 179
				Vec2(cx + r * 0.48, cy + r * 0.28), -- 180
				Vec2(cx + r * 0.42, cy - r * 0.44), -- 181
				Vec2(cx, cy - r * 0.64), -- 182
				Vec2(cx - r * 0.42, cy - r * 0.44), -- 183
				Vec2(cx - r * 0.48, cy + r * 0.28) -- 184
			}, -- 184
			Color(0, 0, 0, 0), -- 185
			1.35, -- 185
			stroke -- 185
		) -- 185
		drawDiamond( -- 186
			draw, -- 186
			cx, -- 186
			cy, -- 186
			r * 0.22, -- 186
			r * 0.3, -- 186
			stroke -- 186
		) -- 186
		draw:drawSegment( -- 188
			Vec2(cx - r * 0.98, cy), -- 188
			Vec2(cx - r * 0.68, cy), -- 188
			1.1, -- 188
			faint -- 188
		) -- 188
		draw:drawSegment( -- 189
			Vec2(cx + r * 0.68, cy), -- 189
			Vec2(cx + r * 0.98, cy), -- 189
			1.1, -- 189
			faint -- 189
		) -- 189
		draw:drawSegment( -- 190
			Vec2(cx, cy + r * 0.8), -- 190
			Vec2(cx, cy + r * 1.04), -- 190
			1.1, -- 190
			faint -- 190
		) -- 190
		draw:drawSegment( -- 191
			Vec2(cx, cy - r * 0.74), -- 191
			Vec2(cx, cy - r * 1), -- 191
			1.1, -- 191
			faint -- 191
		) -- 191
		return -- 192
	end -- 192
	if effect == "knockback" then -- 192
		draw:drawSegment( -- 197
			Vec2(cx - r * 0.85, cy), -- 197
			Vec2(cx + r * 0.85, cy), -- 197
			1.6, -- 197
			stroke -- 197
		) -- 197
		draw:drawSegment( -- 198
			Vec2(cx + r * 0.24, cy + r * 0.54), -- 198
			Vec2(cx + r * 0.85, cy), -- 198
			1.5, -- 198
			stroke -- 198
		) -- 198
		draw:drawSegment( -- 199
			Vec2(cx + r * 0.24, cy - r * 0.54), -- 199
			Vec2(cx + r * 0.85, cy), -- 199
			1.5, -- 199
			stroke -- 199
		) -- 199
		draw:drawSegment( -- 200
			Vec2(cx - r * 0.34, cy + r * 0.36), -- 200
			Vec2(cx + r * 0.14, cy), -- 200
			1.1, -- 200
			faint -- 200
		) -- 200
		draw:drawSegment( -- 201
			Vec2(cx - r * 0.34, cy - r * 0.36), -- 201
			Vec2(cx + r * 0.14, cy), -- 201
			1.1, -- 201
			faint -- 201
		) -- 201
		return -- 202
	end -- 202
	draw:drawRing( -- 206
		Vec2(cx, cy), -- 206
		r * 0.52, -- 206
		r * 0.68, -- 206
		Color(0, 0, 0, 0), -- 206
		1.1, -- 206
		faint -- 206
	) -- 206
end -- 148
local function resolveRuntimeContract(injected) -- 253
	if injected ~= nil then -- 253
		return injected -- 255
	end -- 255
	local g = _G -- 257
	local ____temp_0 -- 258
	if g.package ~= nil then -- 258
		____temp_0 = g.package.loaded -- 258
	else -- 258
		____temp_0 = nil -- 258
	end -- 258
	local loaded = ____temp_0 -- 258
	if loaded == nil then -- 258
		return nil -- 260
	end -- 260
	local feHook = loaded["watch.fe"] -- 262
	if feHook ~= nil and type(feHook) == "table" then -- 262
		local c = feHook.contract -- 264
		if c ~= nil and type(c) == "table" then -- 264
			return c -- 266
		end -- 266
	end -- 266
	return nil -- 269
end -- 253
local function dispatchIntentFallback(p, intent) -- 272
	local rec = p -- 273
	local handler = rec.submitFeIntent -- 274
	if type(handler) == "function" then -- 274
		return handler(p, intent) ~= false -- 276
	end -- 276
	local tap = rec.reloadTapNode -- 278
	if type(tap) == "function" and intent.kind == "reloadTapNode" then -- 278
		tap(p, intent.node) -- 280
		return true -- 281
	end -- 281
	return false -- 283
end -- 272
local function readOptionalNum(obj, key) -- 286
	if obj ~= nil and type(obj) == "table" then -- 286
		local v = obj[key] -- 288
		if type(v) == "number" then -- 288
			return v -- 290
		end -- 290
	end -- 290
	return nil -- 293
end -- 286
____exports.ReloadWheelPlugin = __TS__Class() -- 296
local ReloadWheelPlugin = ____exports.ReloadWheelPlugin -- 296
ReloadWheelPlugin.name = "ReloadWheelPlugin" -- 296
function ReloadWheelPlugin.prototype.____constructor(self, contract) -- 345
	self.id = "fe-02-reload-wheel" -- 297
	self.wasActive = false -- 301
	self.openAnimT = 0 -- 302
	self.openDuration = 0.24 -- 303
	self.retractAnimT = 0 -- 304
	self.retractDuration = 0.28 -- 305
	self.settledPath = {} -- 306
	self.settledEffect = "normal" -- 307
	self.settledTimedOut = false -- 308
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 309
	self.lastKnownNextEffect = "normal" -- 310
	self.kbCursor = ____exports.RELOAD_START_NODE -- 313
	self.dragging = false -- 314
	self.pointerActive = false -- 315
	self.prevLeft = false -- 316
	self.prevRight = false -- 317
	self.prevUp = false -- 318
	self.prevDown = false -- 319
	self.prevLeftKey = false -- 320
	self.prevRightKey = false -- 321
	self.prevConfirm = false -- 322
	self.prevReset = false -- 323
	self.localInvalidFlash = 0 -- 324
	self.animTime = 0 -- 325
	self.nodePulseSeq = 0 -- 326
	self.panelCx = 940 -- 329
	self.panelCy = 374 -- 330
	self.panelW = 286 -- 331
	self.panelH = 316 -- 332
	self.cellStep = 66 -- 333
	self.hitRadius = 25 -- 334
	self.answerTicksAccum = 0 -- 337
	self.worldTicksAccum = 0 -- 338
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 339
	self.appliedVfx = {} -- 342
	self.injectedContract = contract -- 346
end -- 345
function ReloadWheelPlugin.prototype.injectInputForTest(self, sim) -- 350
	self.pendingSimInput = sim -- 351
end -- 350
function ReloadWheelPlugin.prototype.getNodeUiPos(self, nodeId) -- 354
	local spec = ____exports.RELOAD_GRID[nodeId + 1] or ____exports.RELOAD_GRID[1] -- 355
	return {x = self.panelCx + (spec.col - 1) * self.cellStep, y = self.panelCy - 6 + (spec.row - 1) * self.cellStep} -- 356
end -- 354
function ReloadWheelPlugin.prototype.getClockReadings(self) -- 362
	return {answerTicks = self.lastClock.answerTicks, worldTicks = self.lastClock.worldTicks, ratio = self.lastClock.ratio, active = self.lastClock.active} -- 363
end -- 362
function ReloadWheelPlugin.prototype.getState(self) -- 371
	return { -- 372
		active = self.wasActive, -- 373
		kbCursor = self.kbCursor, -- 374
		dragging = self.dragging, -- 375
		path = __TS__ArraySlice(self.lastKnownPath), -- 376
		previewEffect = ____exports.deriveEffectFromGrid(self.lastKnownPath), -- 377
		nextEffect = self.lastKnownNextEffect, -- 378
		retracting = self.retractAnimT > 0, -- 379
		invalidFlash = self.localInvalidFlash, -- 380
		clock = self:getClockReadings(), -- 381
		panelCenterX = self.panelCx, -- 382
		panelCenterY = self.panelCy, -- 383
		cellStep = self.cellStep -- 384
	} -- 384
end -- 371
function ReloadWheelPlugin.prototype.onBindPlay(self, _p, _view) -- 388
	self.wasActive = false -- 389
	self.openAnimT = 0 -- 390
	self.retractAnimT = 0 -- 391
	self.settledPath = {} -- 392
	self.settledEffect = "normal" -- 393
	self.settledTimedOut = false -- 394
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 395
	self.lastKnownNextEffect = "normal" -- 396
	self.kbCursor = ____exports.RELOAD_START_NODE -- 397
	self.dragging = false -- 398
	self.pointerActive = false -- 399
	self.localInvalidFlash = 0 -- 400
	self.animTime = 0 -- 401
	self.answerTicksAccum = 0 -- 402
	self.worldTicksAccum = 0 -- 403
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 404
	self.appliedVfx = {} -- 405
	self.pendingSimInput = nil -- 406
	self:resetInputEdges() -- 407
end -- 388
function ReloadWheelPlugin.prototype.resetInputEdges(self) -- 410
	local ____temp_1 -- 411
	if type(Mouse) ~= "nil" then -- 411
		____temp_1 = Mouse.leftButtonPressed -- 411
	else -- 411
		____temp_1 = false -- 411
	end -- 411
	self.prevLeft = ____temp_1 -- 411
	local ____temp_2 -- 412
	if type(Mouse) ~= "nil" then -- 412
		____temp_2 = Mouse.rightButtonPressed -- 412
	else -- 412
		____temp_2 = false -- 412
	end -- 412
	self.prevRight = ____temp_2 -- 412
	if type(Keyboard) ~= "nil" then -- 412
		self.prevUp = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 414
		self.prevDown = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 415
		self.prevLeftKey = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 416
		self.prevRightKey = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 417
		self.prevConfirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 418
		self.prevReset = Keyboard:isKeyPressed("BackSpace") -- 419
	end -- 419
end -- 410
function ReloadWheelPlugin.prototype.submitIntent(self, p, intent) -- 423
	local contract = resolveRuntimeContract(self.injectedContract) -- 424
	if contract ~= nil then -- 424
		return contract:submitIntent(p, intent) -- 426
	end -- 426
	return dispatchIntentFallback(p, intent) -- 428
end -- 423
function ReloadWheelPlugin.prototype.computePanelPlacement(self, ctx) -- 431
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 432
	local marginX = self.panelW * 0.5 + 34 -- 433
	if soldierUiX < ctx.uiW * 0.56 then -- 433
		self.panelCx = math.min( -- 435
			ctx.uiW - marginX, -- 435
			math.max(ctx.uiW * 0.7, soldierUiX + 230) -- 435
		) -- 435
	else -- 435
		self.panelCx = math.max( -- 437
			marginX, -- 437
			math.min(ctx.uiW * 0.3, soldierUiX - 230) -- 437
		) -- 437
	end -- 437
	self.panelCy = math.max( -- 439
		self.panelH * 0.5 + 78, -- 439
		math.min(ctx.uiH - self.panelH * 0.5 - 66, ctx.uiH * 0.52) -- 439
	) -- 439
end -- 431
function ReloadWheelPlugin.prototype.update(self, ctx) -- 442
	local rs = ctx.view.reloadSession -- 443
	local p = ctx.p -- 444
	self:computePanelPlacement(ctx) -- 447
	ctx.audio:setWorldPlaySpeed(rs.active and math.max( -- 450
		0.25, -- 450
		math.min(1, ctx.view.timeScale) -- 450
	) or 1) -- 450
	if ctx.paused then -- 450
		self:resetInputEdges() -- 454
		return -- 455
	end -- 455
	local udt = math.max(0, ctx.uiDt) -- 458
	local wdt = math.max(0, ctx.worldDt) -- 459
	self.animTime = self.animTime + udt -- 460
	if self.localInvalidFlash > 0 then -- 460
		self.localInvalidFlash = math.max(0, self.localInvalidFlash - udt) -- 463
	end -- 463
	if rs.invalidFlash > self.localInvalidFlash then -- 463
		self.localInvalidFlash = rs.invalidFlash -- 466
	end -- 466
	self:ingestAppliedEffects(ctx) -- 470
	self:updateAppliedVfx(wdt) -- 471
	if rs.active and not self.wasActive then -- 471
		self:onSessionOpened(ctx) -- 475
	elseif not rs.active and self.wasActive then -- 475
		self:onSessionClosed(ctx) -- 477
	end -- 477
	self.wasActive = rs.active -- 479
	if not rs.active then -- 479
		self.lastKnownNextEffect = rs.nextEffect -- 482
		self.lastClock.active = false -- 483
		if self.retractAnimT > 0 then -- 483
			self.retractAnimT = math.max(0, self.retractAnimT - udt) -- 485
		end -- 485
		self.pendingSimInput = nil -- 487
		return -- 488
	end -- 488
	self.openAnimT = math.min( -- 492
		1, -- 492
		self.openAnimT + udt / math.max(0.01, self.openDuration) -- 492
	) -- 492
	local liveAns = readOptionalNum(p, "reloadAnswerTicks") -- 495
	local liveWorld = readOptionalNum(p, "reloadWorldTicks") -- 496
	if liveAns ~= nil and liveWorld ~= nil and not ctx.view.isRehearsal then -- 496
		self.answerTicksAccum = liveAns -- 498
		self.worldTicksAccum = liveWorld -- 499
	else -- 499
		self.answerTicksAccum = self.answerTicksAccum + udt * 60 -- 501
		self.worldTicksAccum = self.worldTicksAccum + wdt * 60 -- 502
	end -- 502
	self.lastClock = { -- 504
		answerTicks = math.floor(self.answerTicksAccum + 0.5), -- 505
		worldTicks = math.floor(self.worldTicksAccum + 0.5), -- 506
		ratio = self.worldTicksAccum > 0.01 and self.answerTicksAccum / self.worldTicksAccum or 0, -- 507
		active = true -- 508
	} -- 508
	local activePath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 512
	self.lastKnownPath = activePath -- 513
	self.lastKnownNextEffect = rs.nextEffect -- 514
	self:processInputs(ctx, activePath) -- 517
end -- 442
function ReloadWheelPlugin.prototype.onSessionOpened(self, ctx) -- 520
	local rs = ctx.view.reloadSession -- 521
	self.openDuration = rs.firstTime and 0.24 or 0.1 -- 522
	self.openAnimT = 0 -- 523
	self.retractAnimT = 0 -- 524
	self.kbCursor = ____exports.RELOAD_START_NODE -- 525
	self.dragging = false -- 526
	self.pointerActive = false -- 527
	self.lastKnownPath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 528
	self.answerTicksAccum = 0 -- 529
	self.worldTicksAccum = 0 -- 530
	self:resetInputEdges() -- 531
	local hasBackendOpen = false -- 533
	local i = 0 -- 534
	do -- 534
		i = 0 -- 535
		while i < #ctx.events.rawEvents do -- 535
			if ctx.events.rawEvents[i + 1].name == "reloadOpen" then -- 535
				hasBackendOpen = true -- 537
				break -- 538
			end -- 538
			i = i + 1 -- 535
		end -- 535
	end -- 535
	if not hasBackendOpen then -- 535
		ctx.audio:playOnce( -- 542
			(("fe02:reload_open:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 543
			"sfx", -- 544
			"assets/audio/combat/reload_open.wav", -- 545
			0.8, -- 546
			"reload:open", -- 547
			ctx.p.ticks -- 548
		) -- 548
	end -- 548
end -- 520
function ReloadWheelPlugin.prototype.onSessionClosed(self, ctx) -- 553
	local rs = ctx.view.reloadSession -- 554
	self.dragging = false -- 555
	self.settledPath = __TS__ArraySlice(self.lastKnownPath) -- 556
	if #self.settledPath > 0 and self.settledPath[#self.settledPath] ~= ____exports.RELOAD_TARGET_NODE and rs.nextEffect ~= "normal" then -- 556
		local ____self_settledPath_3 = self.settledPath -- 556
		____self_settledPath_3[#____self_settledPath_3 + 1] = ____exports.RELOAD_TARGET_NODE -- 559
	end -- 559
	self.settledEffect = rs.nextEffect -- 561
	self.settledTimedOut = rs.nextEffect == "normal" -- 562
	self.retractAnimT = self.retractDuration -- 563
	local hasBackendClose = false -- 566
	local i = 0 -- 567
	do -- 567
		i = 0 -- 568
		while i < #ctx.events.rawEvents do -- 568
			local n = ctx.events.rawEvents[i + 1].name -- 569
			if n == "reloadSolved" or n == "reloadTimeout" then -- 569
				hasBackendClose = true -- 571
				break -- 572
			end -- 572
			i = i + 1 -- 568
		end -- 568
	end -- 568
	if self.settledTimedOut then -- 568
		if not hasBackendClose then -- 568
			ctx.audio:playOnce( -- 578
				(("fe02:reload_timeout:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 579
				"sfx", -- 580
				"assets/audio/combat/reload_timeout.wav", -- 581
				0.78, -- 582
				"reload:timeout", -- 583
				ctx.p.ticks -- 584
			) -- 584
		end -- 584
	else -- 584
		local effectWav = self.settledEffect == "echo" and "assets/audio/combat/reload_solved_echo.wav" or (self.settledEffect == "light" and "assets/audio/combat/reload_solved_light.wav" or "assets/audio/combat/reload_solved_knockback.wav") -- 588
		ctx.audio:playOnce( -- 593
			(((("fe02:reload_solved_fx:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks)) .. ":") .. self.settledEffect, -- 594
			"sfx", -- 595
			effectWav, -- 596
			0.88, -- 597
			"reload:solved:" .. self.settledEffect, -- 598
			ctx.p.ticks -- 599
		) -- 599
	end -- 599
end -- 553
function ReloadWheelPlugin.prototype.processInputs(self, ctx, activePath) -- 604
	local sim = self.pendingSimInput -- 605
	self.pendingSimInput = nil -- 606
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or ctx.input.mx / ctx.uiScale -- 608
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or ctx.input.my / ctx.uiScale -- 609
	local ____temp_10 -- 610
	if (sim and sim.pointerX) ~= nil then -- 610
		____temp_10 = true -- 610
	else -- 610
		____temp_10 = ctx.input.inside -- 610
	end -- 610
	local inside = ____temp_10 -- 610
	local ____temp_13 -- 611
	if (sim and sim.leftHeld) ~= nil then -- 611
		____temp_13 = sim.leftHeld -- 611
	else -- 611
		____temp_13 = ctx.input.fire.held or type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 611
	end -- 611
	local leftHeld = ____temp_13 -- 611
	local ____temp_16 -- 612
	if (sim and sim.rightHeld) ~= nil then -- 612
		____temp_16 = sim.rightHeld -- 612
	else -- 612
		____temp_16 = type(Mouse) ~= "nil" and Mouse.rightButtonPressed -- 612
	end -- 612
	local rightHeld = ____temp_16 -- 612
	local leftPressed = leftHeld and not self.prevLeft -- 614
	local leftReleased = not leftHeld and self.prevLeft -- 615
	local rightPressed = rightHeld and not self.prevRight -- 616
	self.prevLeft = leftHeld -- 617
	self.prevRight = rightHeld -- 618
	local pointerMoved = (sim and sim.pointerX) ~= nil or inside and math.abs(ctx.input.mdx) + math.abs(ctx.input.mdy) >= ctx.uiScale -- 620
	if pointerMoved then -- 620
		self.pointerActive = true -- 623
	end -- 623
	local lastNode = activePath[#activePath] -- 626
	local hitNode = inside and self:hitTestNode(ptrX, ptrY) or -1 -- 627
	if rightPressed and #activePath > 1 then -- 627
		self.dragging = false -- 631
		self:triggerInvalidReset(ctx, activePath, false) -- 632
		return -- 633
	end -- 633
	if leftPressed then -- 633
		if hitNode == ____exports.RELOAD_START_NODE or hitNode == lastNode then -- 633
			self.dragging = true -- 639
			self.kbCursor = lastNode -- 640
		elseif hitNode >= 0 then -- 640
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 640
				self.dragging = true -- 643
				self:commitNodeStep(ctx, hitNode, activePath) -- 644
			else -- 644
				self.dragging = false -- 646
				self:triggerInvalidReset(ctx, activePath, true) -- 647
			end -- 647
			return -- 649
		end -- 649
	elseif self.dragging and leftHeld then -- 649
		if hitNode >= 0 and hitNode ~= lastNode then -- 649
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 649
				self:commitNodeStep(ctx, hitNode, activePath) -- 654
			else -- 654
				self.dragging = false -- 657
				self:triggerInvalidReset(ctx, activePath, true) -- 658
			end -- 658
			return -- 660
		end -- 660
	elseif leftReleased and self.dragging then -- 660
		self.dragging = false -- 663
		if lastNode ~= ____exports.RELOAD_TARGET_NODE and #activePath > 1 then -- 663
			self:triggerInvalidReset(ctx, activePath, true) -- 666
			return -- 667
		end -- 667
	end -- 667
	local dCol = 0 -- 672
	local dRow = 0 -- 673
	local confirmPressed = false -- 674
	local resetPressed = false -- 675
	if sim ~= nil and (sim.moveCol ~= nil or sim.moveRow ~= nil or sim.confirm ~= nil or sim.reset ~= nil) then -- 675
		dCol = sim.moveCol or 0 -- 678
		dRow = sim.moveRow or 0 -- 679
		confirmPressed = sim.confirm == true -- 680
		resetPressed = sim.reset == true -- 681
	elseif type(Keyboard) ~= "nil" then -- 681
		local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 683
		local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 684
		local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 685
		local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 686
		local confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 687
		local reset = Keyboard:isKeyPressed("BackSpace") -- 688
		if up and not self.prevUp then -- 688
			dRow = dRow + 1 -- 690
		end -- 690
		if down and not self.prevDown then -- 690
			dRow = dRow - 1 -- 691
		end -- 691
		if rk and not self.prevRightKey then -- 691
			dCol = dCol + 1 -- 692
		end -- 692
		if lk and not self.prevLeftKey then -- 692
			dCol = dCol - 1 -- 693
		end -- 693
		confirmPressed = confirm and not self.prevConfirm -- 694
		resetPressed = reset and not self.prevReset -- 695
		self.prevUp = up -- 697
		self.prevDown = down -- 698
		self.prevLeftKey = lk -- 699
		self.prevRightKey = rk -- 700
		self.prevConfirm = confirm -- 701
		self.prevReset = reset -- 702
	end -- 702
	if resetPressed and #activePath > 1 then -- 702
		self:triggerInvalidReset(ctx, activePath, false) -- 706
		return -- 707
	end -- 707
	if dCol ~= 0 or dRow ~= 0 then -- 707
		self.pointerActive = false -- 711
		local cur = ____exports.RELOAD_GRID[self.kbCursor + 1] or ____exports.RELOAD_GRID[1] -- 712
		local nextCol = math.max( -- 713
			0, -- 713
			math.min(2, cur.col + dCol) -- 713
		) -- 713
		local nextRow = math.max( -- 714
			0, -- 714
			math.min(2, cur.row + dRow) -- 714
		) -- 714
		self.kbCursor = nextRow * 3 + nextCol -- 715
	end -- 715
	if confirmPressed then -- 715
		self.pointerActive = false -- 719
		if self.kbCursor == lastNode then -- 719
			return -- 721
		end -- 721
		if __TS__ArrayIndexOf(activePath, self.kbCursor) < 0 and ____exports.isAdjacentNode(lastNode, self.kbCursor) then -- 721
			self:commitNodeStep(ctx, self.kbCursor, activePath) -- 724
		else -- 724
			self:triggerInvalidReset(ctx, activePath, true) -- 726
		end -- 726
	end -- 726
end -- 604
function ReloadWheelPlugin.prototype.commitNodeStep(self, ctx, node, activePath) -- 731
	self.kbCursor = node -- 732
	self:submitIntent(ctx.p, {kind = "reloadTapNode", node = node}) -- 733
	self.lastKnownPath = __TS__ArrayConcat(activePath, {node}) -- 734
	if node == ____exports.RELOAD_TARGET_NODE then -- 734
		self.dragging = false -- 736
		return -- 737
	end -- 737
	self.nodePulseSeq = self.nodePulseSeq + 1 -- 740
	ctx.audio:playOnce( -- 741
		(((("fe02:reload_node:r" .. tostring(ctx.events.roomSessionId)) .. ":n") .. tostring(self.nodePulseSeq)) .. ":") .. tostring(node), -- 742
		"sfx", -- 743
		"assets/audio/combat/reload_node.wav", -- 744
		0.78, -- 745
		"reload:node:" .. tostring(node), -- 746
		ctx.p.ticks -- 747
	) -- 747
end -- 731
function ReloadWheelPlugin.prototype.triggerInvalidReset(self, ctx, activePath, flashError) -- 751
	if flashError then -- 751
		self.localInvalidFlash = 0.36 -- 753
	end -- 753
	self.kbCursor = ____exports.RELOAD_START_NODE -- 755
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 756
	if #activePath > 1 then -- 756
		self:submitIntent(ctx.p, {kind = "reloadTapNode", node = ____exports.RELOAD_START_NODE}) -- 759
	end -- 759
	if flashError then -- 759
		self.nodePulseSeq = self.nodePulseSeq + 1 -- 762
		ctx.audio:playOnce( -- 763
			(("fe02:reload_invalid:r" .. tostring(ctx.events.roomSessionId)) .. ":e") .. tostring(self.nodePulseSeq), -- 764
			"sfx", -- 765
			"assets/audio/combat/reload_invalid.wav", -- 766
			0.72, -- 767
			"reload:invalid", -- 768
			ctx.p.ticks -- 769
		) -- 769
	end -- 769
end -- 751
function ReloadWheelPlugin.prototype.hitTestNode(self, uiX, uiY) -- 774
	local r2 = self.hitRadius * self.hitRadius -- 775
	local i = 0 -- 776
	do -- 776
		i = 0 -- 777
		while i < #____exports.RELOAD_GRID do -- 777
			local pos = self:getNodeUiPos(i) -- 778
			local dx = uiX - pos.x -- 779
			local dy = uiY - pos.y -- 780
			if dx * dx + dy * dy <= r2 then -- 780
				return i -- 782
			end -- 782
			i = i + 1 -- 777
		end -- 777
	end -- 777
	return -1 -- 785
end -- 774
function ReloadWheelPlugin.prototype.ingestAppliedEffects(self, ctx) -- 788
	local p = ctx.p -- 789
	local triggered = false -- 790
	local i = 0 -- 791
	do -- 791
		i = 0 -- 792
		while i < #ctx.events.rawEvents do -- 792
			local e = ctx.events.rawEvents[i + 1] -- 793
			if e.name == "reloadApplied" then -- 793
				local rawEff = e.data.effect -- 795
				local eff = rawEff == "echo" and "echo" or (rawEff == "light" and "light" or "knockback") -- 796
				local ex = type(e.data.enemyX) == "number" and e.data.enemyX or p.player.x + p.player.facing * 200 -- 799
				self:spawnAppliedVfx(eff, p, ex) -- 800
				triggered = true -- 801
			end -- 801
			i = i + 1 -- 792
		end -- 792
	end -- 792
	if not triggered and ctx.events.shotFired and self.lastKnownNextEffect ~= "normal" and ctx.view.reloadSession.nextEffect == "normal" then -- 792
		local tx = ctx.events.shotTrace ~= nil and ctx.events.shotTrace.x1 or p.player.x + p.player.facing * 220 -- 806
		self:spawnAppliedVfx(self.lastKnownNextEffect, p, tx) -- 807
	end -- 807
end -- 788
function ReloadWheelPlugin.prototype.spawnAppliedVfx(self, effect, p, targetX) -- 811
	local originX = p.player.x + p.player.facing * 18 -- 812
	local originY = p.player.y + p.player.depth + p.player.h * 0.62 -- 813
	local targetY = p.player.y + p.player.depth + 46 -- 814
	local maxLife = effect == "light" and 0.42 or (effect == "echo" and 0.56 or 0.34) -- 815
	local ____self_appliedVfx_19 = self.appliedVfx -- 815
	____self_appliedVfx_19[#____self_appliedVfx_19 + 1] = { -- 816
		effect = effect, -- 817
		originX = originX, -- 818
		originY = originY, -- 819
		targetX = targetX, -- 820
		targetY = targetY, -- 821
		facing = p.player.facing >= 0 and 1 or -1, -- 822
		life = maxLife, -- 823
		maxLife = maxLife -- 824
	} -- 824
end -- 811
function ReloadWheelPlugin.prototype.updateAppliedVfx(self, wdt) -- 828
	if wdt <= 0 or #self.appliedVfx == 0 then -- 828
		return -- 830
	end -- 830
	local w = 0 -- 832
	local i = 0 -- 833
	do -- 833
		i = 0 -- 834
		while i < #self.appliedVfx do -- 834
			local fx = self.appliedVfx[i + 1] -- 835
			fx.life = fx.life - wdt -- 836
			if fx.life > 0 then -- 836
				self.appliedVfx[w + 1] = fx -- 838
				w = w + 1 -- 839
			end -- 839
			i = i + 1 -- 834
		end -- 834
	end -- 834
	__TS__ArraySetLength(self.appliedVfx, w) -- 834
end -- 828
function ReloadWheelPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, _worldArt, ctx) -- 846
	if #self.appliedVfx == 0 then -- 846
		return -- 853
	end -- 853
	local cam = ctx.cam -- 855
	local i = 0 -- 856
	do -- 856
		i = 0 -- 857
		while i < #self.appliedVfx do -- 857
			local fx = self.appliedVfx[i + 1] -- 858
			local k = math.max( -- 859
				0, -- 859
				math.min(1, fx.life / fx.maxLife) -- 859
			) -- 859
			local prog = 1 - k -- 860
			local ox = cam:sx(fx.originX) -- 861
			local oy = cam:sy(fx.originY) -- 862
			local tx = cam:sx(fx.targetX) -- 863
			local ty = cam:sy(fx.targetY) -- 864
			if fx.effect == "knockback" then -- 864
				local r = cam:len(12 + prog * 34) -- 868
				local startA = fx.facing >= 0 and -48 or 132 -- 869
				local endA = fx.facing >= 0 and 48 or 228 -- 870
				fgGlow:drawArc( -- 871
					Vec2(tx, ty), -- 871
					r, -- 871
					startA, -- 871
					endA, -- 871
					2.4 * k, -- 871
					toColor(PALETTE.moonPale, 210 * k) -- 871
				) -- 871
				fgDraw:drawArc( -- 872
					Vec2( -- 872
						tx - fx.facing * cam:len(6), -- 872
						ty -- 872
					), -- 872
					r * 0.72, -- 872
					startA, -- 872
					endA, -- 872
					1.5 * k, -- 872
					toColor(PALETTE.silkLine, 165 * k) -- 872
				) -- 872
			elseif fx.effect == "echo" then -- 872
				local r1 = cam:len(10 + prog * 64) -- 875
				local r2 = cam:len(6 + prog * 40) -- 876
				fgGlow:drawRing( -- 877
					Vec2(tx, ty), -- 877
					math.max(1, r1 - 1.6), -- 877
					r1, -- 877
					Color(0, 0, 0, 0), -- 877
					1.3, -- 877
					toColor(PALETTE.amber, 210 * k) -- 877
				) -- 877
				fgGlow:drawRing( -- 878
					Vec2(tx, ty), -- 878
					math.max(1, r2 - 1.2), -- 878
					r2, -- 878
					Color(0, 0, 0, 0), -- 878
					1, -- 878
					toColor(PALETTE.amberCore, 175 * k) -- 878
				) -- 878
			elseif fx.effect == "light" then -- 878
				fgGlow:drawSegment( -- 881
					Vec2(ox, oy), -- 881
					Vec2(tx, ty), -- 881
					5 * k, -- 881
					toColor(PALETTE.amber, 68 * k) -- 881
				) -- 881
				fgGlow:drawSegment( -- 882
					Vec2(ox, oy), -- 882
					Vec2(tx, ty), -- 882
					1.8 * k, -- 882
					toColor(PALETTE.amberCore, 185 * k) -- 882
				) -- 882
				fillRadialGlow( -- 883
					fgGlow, -- 883
					tx, -- 883
					ty, -- 883
					cam:len(42 * (0.6 + prog * 0.4)), -- 883
					cam:len(34), -- 883
					toColor(PALETTE.amberCore, 118 * k), -- 883
					Color(244, 234, 214, 0), -- 883
					16 -- 883
				) -- 883
			end -- 883
			i = i + 1 -- 857
		end -- 857
	end -- 857
end -- 846
function ReloadWheelPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 889
	local rs = ctx.view.reloadSession -- 896
	local active = rs.active -- 897
	local retracting = not active and self.retractAnimT > 0.01 -- 898
	if not active and not retracting then -- 898
		if rs.nextEffect ~= "normal" and not ctx.view.craftBench.active then -- 898
			self:drawArmedEffectBadge( -- 902
				uiDraw, -- 902
				uiInkDraw, -- 902
				uiArt, -- 902
				ctx, -- 902
				rs.nextEffect -- 902
			) -- 902
		end -- 902
		return false -- 904
	end -- 904
	local cx = self.panelCx -- 907
	local cy = self.panelCy -- 908
	local pw = self.panelW -- 909
	local ph = self.panelH -- 910
	local x0 = cx - pw * 0.5 -- 911
	local y0 = cy - ph * 0.5 -- 912
	local appear = active and math.min(1, self.openAnimT) or math.max( -- 914
		0, -- 916
		self.retractAnimT / math.max(0.01, self.retractDuration) -- 916
	) -- 916
	local shakeX = self.localInvalidFlash > 0 and math.sin(self.animTime * 62) * 5.5 * (self.localInvalidFlash / 0.36) or 0 -- 917
	local px = cx + shakeX -- 920
	if active then -- 920
		uiDraw:drawRect( -- 924
			Rect(0, 0, ctx.uiW, ctx.uiH), -- 924
			Color( -- 924
				10, -- 924
				13, -- 924
				20, -- 924
				math.floor(54 * appear + 0.5) -- 924
			) -- 924
		) -- 924
	end -- 924
	drawSilkVeil( -- 928
		uiDraw, -- 928
		uiArt, -- 928
		"rw_outer_veil", -- 928
		px, -- 928
		cy, -- 928
		pw + 34, -- 928
		ph + 28, -- 928
		PALETTE.inkWash, -- 928
		0.72 * appear, -- 928
		-2 -- 928
	) -- 928
	if not uiArt:tryPlace( -- 928
		"ink_song_paper", -- 929
		"rw_paper", -- 929
		px, -- 929
		cy, -- 929
		pw, -- 929
		ph, -- 929
		{opacity = 0.94 * appear, layer = 1} -- 929
	) then -- 929
		uiDraw:drawRoundedRect( -- 930
			Rect(x0 + shakeX, y0, pw, ph), -- 931
			6, -- 932
			toColor(PALETTE.xuanPaper, 240 * appear), -- 933
			1.2, -- 934
			toColor(PALETTE.xuanInkSub, 180 * appear) -- 935
		) -- 935
	end -- 935
	local frameCol = self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInkSub -- 938
	drawFiligreeCorners( -- 939
		uiInkDraw, -- 939
		uiArt, -- 939
		"rw_frame", -- 939
		x0 + shakeX + 8, -- 939
		y0 + 8, -- 939
		pw - 16, -- 939
		ph - 16, -- 939
		frameCol, -- 939
		0.72 * appear, -- 939
		22, -- 939
		true, -- 939
		2 -- 939
	) -- 939
	local activePath = active and (#rs.path > 0 and rs.path or ({____exports.RELOAD_START_NODE})) or self.settledPath -- 942
	local previewEffect = active and (#rs.path >= 2 and ____exports.deriveEffectFromGrid(activePath) or rs.previewEffect) or self.settledEffect -- 945
	local effAccent = self:effectInkColor(previewEffect) -- 948
	local headY = y0 + ph - 32 -- 950
	____exports.drawReloadPatternGlyph( -- 951
		uiInkDraw, -- 951
		px - 52, -- 951
		headY, -- 951
		11, -- 951
		previewEffect, -- 951
		effAccent, -- 951
		appear -- 951
	) -- 951
	local titleText = active and ____exports.reloadEffectShortLabel(previewEffect) or (self.settledTimedOut and "普通装填" or ____exports.reloadEffectShortLabel(self.settledEffect)) -- 952
	ctx.texts:put( -- 955
		"sm", -- 956
		titleText, -- 957
		px - 32, -- 958
		headY, -- 959
		toColor(self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInk), -- 960
		0, -- 961
		0.5, -- 962
		"Left", -- 963
		1.6, -- 964
		0.96 * appear, -- 965
		0 -- 966
	) -- 966
	drawHairline( -- 968
		uiInkDraw, -- 968
		uiArt, -- 968
		"rw_head_line", -- 968
		px, -- 968
		headY - 18, -- 968
		pw - 42, -- 968
		PALETTE.xuanInkSub, -- 968
		0.45 * appear, -- 968
		false, -- 968
		2 -- 968
	) -- 968
	local idx = 0 -- 971
	do -- 971
		idx = 0 -- 972
		while idx < 3 do -- 972
			local hA = self:getNodeUiPos(idx * 3) -- 973
			local hB = self:getNodeUiPos(idx * 3 + 2) -- 974
			uiInkDraw:drawSegment( -- 975
				Vec2(hA.x + shakeX, hA.y), -- 975
				Vec2(hB.x + shakeX, hB.y), -- 975
				0.75, -- 975
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 975
			) -- 975
			local vA = self:getNodeUiPos(idx) -- 976
			local vB = self:getNodeUiPos(6 + idx) -- 977
			uiInkDraw:drawSegment( -- 978
				Vec2(vA.x + shakeX, vA.y), -- 978
				Vec2(vB.x + shakeX, vB.y), -- 978
				0.75, -- 978
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 978
			) -- 978
			idx = idx + 1 -- 972
		end -- 972
	end -- 972
	if #activePath >= 2 then -- 972
		self:drawPathStrokes( -- 983
			uiInkDraw, -- 983
			uiGlow, -- 983
			activePath, -- 983
			previewEffect, -- 983
			effAccent, -- 983
			shakeX, -- 983
			appear -- 983
		) -- 983
	end -- 983
	if active and self.dragging and #activePath >= 1 then -- 983
		local tail = self:getNodeUiPos(activePath[#activePath]) -- 988
		local mx = ctx.input.mx / ctx.uiScale -- 989
		local my = ctx.input.my / ctx.uiScale -- 990
		uiInkDraw:drawSegment( -- 991
			Vec2(tail.x + shakeX, tail.y), -- 991
			Vec2(mx, my), -- 991
			1.4, -- 991
			toColor(effAccent, 150 * appear) -- 991
		) -- 991
		uiInkDraw:drawDot( -- 992
			Vec2(mx, my), -- 992
			3, -- 992
			toColor(effAccent, 210 * appear) -- 992
		) -- 992
	end -- 992
	local lastNode = #activePath > 0 and activePath[#activePath] or ____exports.RELOAD_START_NODE -- 996
	do -- 996
		idx = 0 -- 997
		while idx < #____exports.RELOAD_GRID do -- 997
			local spec = ____exports.RELOAD_GRID[idx + 1] -- 998
			local pos = self:getNodeUiPos(idx) -- 999
			local nx = pos.x + shakeX -- 1000
			local ny = pos.y -- 1001
			local inPath = __TS__ArrayIndexOf(activePath, idx) >= 0 -- 1002
			local isValidNext = active and not inPath and ____exports.isAdjacentNode(lastNode, idx) -- 1003
			local isKbFocus = active and not self.pointerActive and self.kbCursor == idx -- 1004
			self:drawGridNode( -- 1005
				uiInkDraw, -- 1005
				uiGlow, -- 1005
				spec, -- 1005
				nx, -- 1005
				ny, -- 1005
				inPath, -- 1005
				isValidNext, -- 1005
				isKbFocus, -- 1005
				effAccent, -- 1005
				appear -- 1005
			) -- 1005
			idx = idx + 1 -- 997
		end -- 997
	end -- 997
	self:drawChildFinger( -- 1009
		uiInkDraw, -- 1009
		uiGlow, -- 1009
		active, -- 1009
		activePath, -- 1009
		shakeX, -- 1009
		appear -- 1009
	) -- 1009
	local barW = pw - 52 -- 1012
	local barX = px - barW * 0.5 -- 1013
	local barY = y0 + 28 -- 1014
	local remainFrac = active and math.max( -- 1015
		0, -- 1016
		math.min( -- 1016
			1, -- 1016
			1 - rs.elapsed / math.max(0.01, rs.duration) -- 1016
		) -- 1016
	) or (self.settledTimedOut and 0 or 1) -- 1016
	local urgent = active and remainFrac < 0.25 -- 1018
	local barCol = urgent and PALETTE.rouge or PALETTE.xuanInk -- 1019
	uiInkDraw:drawSegment( -- 1020
		Vec2(barX, barY), -- 1020
		Vec2(barX + barW, barY), -- 1020
		1.4, -- 1020
		toColor(PALETTE.xuanInkSub, 85 * appear) -- 1020
	) -- 1020
	if remainFrac > 0.005 then -- 1020
		uiInkDraw:drawSegment( -- 1022
			Vec2(barX, barY), -- 1022
			Vec2(barX + barW * remainFrac, barY), -- 1022
			3, -- 1022
			toColor(barCol, 225 * appear) -- 1022
		) -- 1022
	end -- 1022
	local tTick = 1 -- 1025
	do -- 1025
		tTick = 1 -- 1026
		while tTick <= 3 do -- 1026
			local tx = barX + barW * (tTick / 4) -- 1027
			uiInkDraw:drawSegment( -- 1028
				Vec2(tx, barY - 3.5), -- 1028
				Vec2(tx, barY + 3.5), -- 1028
				0.9, -- 1028
				toColor(PALETTE.xuanInkSub, 125 * appear) -- 1028
			) -- 1028
			tTick = tTick + 1 -- 1026
		end -- 1026
	end -- 1026
	if active and ctx.view.assistHintsEnabled then -- 1026
		ctx.texts:put( -- 1033
			"xs", -- 1034
			"拖线或方向+回车连至右上", -- 1035
			px, -- 1036
			y0 + 13, -- 1037
			toColor(PALETTE.xuanInkSub), -- 1038
			0.5, -- 1039
			0.5, -- 1040
			"Center", -- 1041
			0.6, -- 1042
			0.82 * appear, -- 1043
			0 -- 1044
		) -- 1044
	end -- 1044
	return active -- 1048
end -- 889
function ReloadWheelPlugin.prototype.effectInkColor(self, effect) -- 1051
	if effect == "echo" then -- 1051
		return PALETTE.rouge -- 1053
	end -- 1053
	if effect == "light" then -- 1053
		return PALETTE.amberDim -- 1056
	end -- 1056
	if effect == "knockback" then -- 1056
		return PALETTE.xuanInk -- 1059
	end -- 1059
	return PALETTE.xuanInkSub -- 1061
end -- 1051
function ReloadWheelPlugin.prototype.drawPathStrokes(self, uiInkDraw, uiGlow, path, effect, col, shakeX, appear) -- 1064
	local i = 0 -- 1073
	do -- 1073
		i = 0 -- 1074
		while i < #path - 1 do -- 1074
			local p0 = self:getNodeUiPos(path[i + 1]) -- 1075
			local p1 = self:getNodeUiPos(path[i + 1 + 1]) -- 1076
			local ax = p0.x + shakeX -- 1077
			local ay = p0.y -- 1078
			local bx = p1.x + shakeX -- 1079
			local by = p1.y -- 1080
			if effect == "echo" then -- 1080
				local dx = bx - ax -- 1084
				local dy = by - ay -- 1085
				local len = math.max( -- 1086
					1, -- 1086
					math.sqrt(dx * dx + dy * dy) -- 1086
				) -- 1086
				local nx = -dy / len * 2.2 -- 1087
				local ny = dx / len * 2.2 -- 1088
				uiInkDraw:drawSegment( -- 1089
					Vec2(ax + nx, ay + ny), -- 1089
					Vec2(bx + nx, by + ny), -- 1089
					1.35, -- 1089
					toColor(col, 220 * appear) -- 1089
				) -- 1089
				uiInkDraw:drawSegment( -- 1090
					Vec2(ax - nx, ay - ny), -- 1090
					Vec2(bx - nx, by - ny), -- 1090
					1.35, -- 1090
					toColor(col, 220 * appear) -- 1090
				) -- 1090
			elseif effect == "light" then -- 1090
				uiInkDraw:drawSegment( -- 1093
					Vec2(ax, ay), -- 1093
					Vec2(bx, by), -- 1093
					3.1, -- 1093
					toColor(PALETTE.xuanInk, 195 * appear) -- 1093
				) -- 1093
				uiInkDraw:drawSegment( -- 1094
					Vec2(ax, ay), -- 1094
					Vec2(bx, by), -- 1094
					1.3, -- 1094
					toColor(PALETTE.amberCore, 235 * appear) -- 1094
				) -- 1094
				uiGlow:drawSegment( -- 1095
					Vec2(ax, ay), -- 1095
					Vec2(bx, by), -- 1095
					3.2, -- 1095
					toColor(PALETTE.amber, 55 * appear) -- 1095
				) -- 1095
			else -- 1095
				uiInkDraw:drawSegment( -- 1098
					Vec2(ax, ay), -- 1098
					Vec2(bx, by), -- 1098
					2.8, -- 1098
					toColor(col, 230 * appear) -- 1098
				) -- 1098
			end -- 1098
			i = i + 1 -- 1074
		end -- 1074
	end -- 1074
end -- 1064
function ReloadWheelPlugin.prototype.drawGridNode(self, uiInkDraw, uiGlow, spec, nx, ny, inPath, isValidNext, isKbFocus, effAccent, appear) -- 1103
	local baseR = spec.kind == "plain" and 11 or 15 -- 1115
	local strokeCol = inPath and effAccent or (isValidNext and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 1116
	local strokeAlpha = inPath and 245 or (isValidNext and 185 or 115) -- 1117
	if isKbFocus then -- 1117
		local focusCol = (isValidNext or inPath) and PALETTE.rouge or PALETTE.xuanInkSub -- 1121
		uiInkDraw:drawRing( -- 1122
			Vec2(nx, ny), -- 1122
			baseR + 4.5, -- 1122
			baseR + 6.2, -- 1122
			Color(0, 0, 0, 0), -- 1122
			1.1, -- 1122
			toColor(focusCol, 215 * appear) -- 1122
		) -- 1122
	end -- 1122
	if spec.kind == "bell" then -- 1122
		if inPath then -- 1122
			uiInkDraw:drawCircle( -- 1128
				Vec2(nx, ny), -- 1128
				baseR + 1, -- 1128
				toColor(PALETTE.rouge, 36 * appear) -- 1128
			) -- 1128
			uiGlow:drawRing( -- 1129
				Vec2(nx, ny), -- 1129
				baseR + 2, -- 1129
				baseR + 5, -- 1129
				Color(0, 0, 0, 0), -- 1129
				1.2, -- 1129
				toColor(PALETTE.rouge, 110 * appear) -- 1129
			) -- 1129
		end -- 1129
		uiInkDraw:drawRing( -- 1131
			Vec2(nx, ny), -- 1131
			baseR - 1.2, -- 1131
			baseR, -- 1131
			Color(0, 0, 0, 0), -- 1131
			1.1, -- 1131
			toColor(strokeCol, strokeAlpha * appear) -- 1131
		) -- 1131
		____exports.drawReloadPatternGlyph( -- 1132
			uiInkDraw, -- 1132
			nx, -- 1132
			ny, -- 1132
			9.5, -- 1132
			"echo", -- 1132
			inPath and PALETTE.rouge or strokeCol, -- 1132
			appear -- 1132
		) -- 1132
		return -- 1133
	end -- 1133
	if spec.kind == "lamp" then -- 1133
		if inPath then -- 1133
			uiInkDraw:drawCircle( -- 1139
				Vec2(nx, ny), -- 1139
				baseR + 1, -- 1139
				toColor(PALETTE.amber, 56 * appear) -- 1139
			) -- 1139
			fillRadialGlow( -- 1140
				uiGlow, -- 1140
				nx, -- 1140
				ny, -- 1140
				22, -- 1140
				22, -- 1140
				toColor(PALETTE.amberCore, 72 * appear), -- 1140
				Color(244, 234, 214, 0), -- 1140
				12 -- 1140
			) -- 1140
		end -- 1140
		uiInkDraw:drawRing( -- 1142
			Vec2(nx, ny), -- 1142
			baseR - 1.2, -- 1142
			baseR, -- 1142
			Color(0, 0, 0, 0), -- 1142
			1.1, -- 1142
			toColor(strokeCol, strokeAlpha * appear) -- 1142
		) -- 1142
		____exports.drawReloadPatternGlyph( -- 1143
			uiInkDraw, -- 1143
			nx, -- 1143
			ny, -- 1143
			9.5, -- 1143
			"light", -- 1143
			inPath and PALETTE.xuanInk or strokeCol, -- 1143
			appear -- 1143
		) -- 1143
		return -- 1144
	end -- 1144
	if spec.kind == "target" then -- 1144
		drawDiamond( -- 1149
			uiInkDraw, -- 1150
			nx, -- 1151
			ny, -- 1152
			baseR, -- 1153
			baseR, -- 1154
			inPath and toColor(PALETTE.xuanInk, 220 * appear) or Color(0, 0, 0, 0), -- 1155
			1.4, -- 1156
			toColor(inPath and PALETTE.rouge or PALETTE.xuanInk, 230 * appear) -- 1157
		) -- 1157
		drawDiamond( -- 1159
			uiInkDraw, -- 1160
			nx, -- 1161
			ny, -- 1162
			baseR * 0.56, -- 1163
			baseR * 0.56, -- 1164
			toColor(inPath and PALETTE.amberCore or PALETTE.xuanInk, 210 * appear) -- 1165
		) -- 1165
		return -- 1167
	end -- 1167
	if spec.kind == "start" then -- 1167
		uiInkDraw:drawRing( -- 1172
			Vec2(nx, ny), -- 1172
			baseR - 2.2, -- 1172
			baseR, -- 1172
			Color(0, 0, 0, 0), -- 1172
			1.2, -- 1172
			toColor(PALETTE.rouge, 220 * appear) -- 1172
		) -- 1172
		uiInkDraw:drawCircle( -- 1173
			Vec2(nx, ny), -- 1173
			4.8, -- 1173
			toColor(PALETTE.xuanInk, 235 * appear) -- 1173
		) -- 1173
		return -- 1174
	end -- 1174
	if inPath then -- 1174
		uiInkDraw:drawCircle( -- 1179
			Vec2(nx, ny), -- 1179
			6.2, -- 1179
			toColor(effAccent, 235 * appear) -- 1179
		) -- 1179
		uiInkDraw:drawRing( -- 1180
			Vec2(nx, ny), -- 1180
			9.5, -- 1180
			10.8, -- 1180
			Color(0, 0, 0, 0), -- 1180
			1, -- 1180
			toColor(effAccent, 165 * appear) -- 1180
		) -- 1180
	else -- 1180
		uiInkDraw:drawRing( -- 1182
			Vec2(nx, ny), -- 1182
			5.6, -- 1182
			7, -- 1182
			Color(0, 0, 0, 0), -- 1182
			1, -- 1182
			toColor(strokeCol, strokeAlpha * appear) -- 1182
		) -- 1182
	end -- 1182
end -- 1103
function ReloadWheelPlugin.prototype.drawChildFinger(self, uiInkDraw, uiGlow, active, path, shakeX, appear) -- 1187
	local fx = 0 -- 1195
	local fy = 0 -- 1196
	if active then -- 1196
		local tipNode = #path > 0 and path[#path] or ____exports.RELOAD_START_NODE -- 1199
		local pos = self:getNodeUiPos(tipNode) -- 1200
		local tapPulse = #path <= 1 and math.sin(self.animTime * 4.8) * 3.5 or 0 -- 1201
		fx = pos.x + shakeX - 6 - tapPulse * 0.4 -- 1202
		fy = pos.y - 6 - tapPulse -- 1203
		if #path <= 1 then -- 1203
			local ringR = 17 + math.sin(self.animTime * 4.2) * 2.5 -- 1206
			uiInkDraw:drawRing( -- 1207
				Vec2(pos.x + shakeX, pos.y), -- 1207
				ringR - 1, -- 1207
				ringR, -- 1207
				Color(0, 0, 0, 0), -- 1207
				1, -- 1207
				toColor(PALETTE.rouge, 130 * appear) -- 1207
			) -- 1207
		end -- 1207
	elseif self.retractAnimT > 0 and #path > 0 then -- 1207
		local prog = math.max( -- 1211
			0, -- 1211
			math.min( -- 1211
				1, -- 1211
				1 - self.retractAnimT / math.max(0.01, self.retractDuration) -- 1211
			) -- 1211
		) -- 1211
		local revFloat = (1 - prog) * (#path - 1) -- 1212
		local idxA = math.max( -- 1213
			0, -- 1213
			math.min( -- 1213
				#path - 1, -- 1213
				math.floor(revFloat) -- 1213
			) -- 1213
		) -- 1213
		local idxB = math.max( -- 1214
			0, -- 1214
			math.min(#path - 1, idxA + 1) -- 1214
		) -- 1214
		local frac = revFloat - idxA -- 1215
		local pA = self:getNodeUiPos(path[idxA + 1]) -- 1216
		local pB = self:getNodeUiPos(path[idxB + 1]) -- 1217
		fx = pA.x + (pB.x - pA.x) * frac + shakeX - prog * 28 -- 1218
		fy = pA.y + (pB.y - pA.y) * frac - prog * 22 -- 1219
	else -- 1219
		return -- 1221
	end -- 1221
	local a255 = math.floor(240 * appear + 0.5) -- 1225
	local inkCol = toColor(PALETTE.xuanInk, 180 * appear) -- 1226
	uiInkDraw:drawPolygon( -- 1227
		{ -- 1227
			Vec2(fx - 30, fy - 20), -- 1228
			Vec2(fx - 22, fy - 28), -- 1229
			Vec2(fx - 11, fy - 14), -- 1230
			Vec2(fx - 17, fy - 9) -- 1231
		}, -- 1231
		Color(164, 78, 54, a255), -- 1232
		1, -- 1232
		inkCol -- 1232
	) -- 1232
	uiInkDraw:drawSegment( -- 1234
		Vec2(fx - 16, fy - 10), -- 1234
		Vec2(fx - 11, fy - 15), -- 1234
		2, -- 1234
		Color(204, 174, 122, a255) -- 1234
	) -- 1234
	uiInkDraw:drawCircle( -- 1236
		Vec2(fx - 9, fy - 8), -- 1236
		4.8, -- 1236
		Color(238, 212, 182, a255) -- 1236
	) -- 1236
	uiInkDraw:drawSegment( -- 1237
		Vec2(fx - 7, fy - 6), -- 1237
		Vec2(fx, fy), -- 1237
		2.5, -- 1237
		Color(244, 222, 196, a255) -- 1237
	) -- 1237
	uiInkDraw:drawRing( -- 1238
		Vec2(fx, fy), -- 1238
		2, -- 1238
		3, -- 1238
		Color(0, 0, 0, 0), -- 1238
		0.9, -- 1238
		inkCol -- 1238
	) -- 1238
	uiGlow:drawDot( -- 1239
		Vec2(fx, fy), -- 1239
		3.4, -- 1239
		toColor(PALETTE.amberCore, 80 * appear) -- 1239
	) -- 1239
end -- 1187
function ReloadWheelPlugin.prototype.drawArmedEffectBadge(self, uiDraw, uiInkDraw, uiArt, ctx, effect) -- 1243
	local bx = 46 -- 1250
	local by = ctx.uiH - 112 -- 1251
	local col = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberCore or PALETTE.cyanCore) -- 1252
	drawSilkVeil( -- 1253
		uiDraw, -- 1253
		uiArt, -- 1253
		"rw_armed_veil", -- 1253
		bx + 54, -- 1253
		by, -- 1253
		142, -- 1253
		30, -- 1253
		PALETTE.inkWash, -- 1253
		0.72, -- 1253
		-1 -- 1253
	) -- 1253
	____exports.drawReloadPatternGlyph( -- 1254
		uiInkDraw, -- 1254
		bx + 12, -- 1254
		by, -- 1254
		9, -- 1254
		effect, -- 1254
		col, -- 1254
		0.96 -- 1254
	) -- 1254
	drawBlossomDot( -- 1255
		uiInkDraw, -- 1255
		uiArt, -- 1255
		"rw_armed_dot", -- 1255
		bx + 28, -- 1255
		by, -- 1255
		6, -- 1255
		col, -- 1255
		0.85, -- 1255
		3 -- 1255
	) -- 1255
	ctx.texts:put( -- 1256
		"xs", -- 1256
		____exports.reloadEffectShortLabel(effect), -- 1256
		bx + 38, -- 1256
		by, -- 1256
		toColor(PALETTE.textBright), -- 1256
		0, -- 1256
		0.5, -- 1256
		"Left", -- 1256
		1, -- 1256
		0.94, -- 1256
		0.08 -- 1256
	) -- 1256
end -- 1243
function ____exports.createReloadWheelPlugin(contract) -- 1260
	return __TS__New(____exports.ReloadWheelPlugin, contract) -- 1261
end -- 1260
return ____exports -- 1260