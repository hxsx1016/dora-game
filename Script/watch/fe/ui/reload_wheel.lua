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
function ReloadWheelPlugin.prototype.____constructor(self, contract) -- 368
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
	self.prevUp = false -- 338
	self.prevDown = false -- 339
	self.prevLeftKey = false -- 340
	self.prevRightKey = false -- 341
	self.prevConfirm = false -- 342
	self.prevReset = false -- 343
	self.localInvalidFlash = 0 -- 344
	self.animTime = 0 -- 345
	self.nodePulseSeq = 0 -- 346
	self.panelCx = 940 -- 349
	self.panelCy = 374 -- 350
	self.panelW = 286 -- 351
	self.panelH = 316 -- 352
	self.cellStep = 66 -- 353
	self.hitRadius = 25 -- 354
	self.resetBox = Rect(0, 0, 0, 0) -- 355
	self.lastUiPtrX = 0 -- 356
	self.lastUiPtrY = 0 -- 357
	self.answerTicksAccum = 0 -- 360
	self.worldTicksAccum = 0 -- 361
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 362
	self.appliedVfx = {} -- 365
	self.injectedContract = contract -- 369
end -- 368
function ReloadWheelPlugin.prototype.injectInputForTest(self, sim) -- 373
	self.pendingSimInput = sim -- 374
end -- 373
function ReloadWheelPlugin.prototype.getNodeUiPos(self, nodeId) -- 377
	local spec = ____exports.RELOAD_GRID[nodeId + 1] or ____exports.RELOAD_GRID[1] -- 378
	return {x = self.panelCx + (spec.col - 1) * self.cellStep, y = self.panelCy - 6 + (spec.row - 1) * self.cellStep} -- 379
end -- 377
function ReloadWheelPlugin.prototype.getClockReadings(self) -- 385
	return {answerTicks = self.lastClock.answerTicks, worldTicks = self.lastClock.worldTicks, ratio = self.lastClock.ratio, active = self.lastClock.active} -- 386
end -- 385
function ReloadWheelPlugin.prototype.getState(self) -- 394
	return { -- 395
		active = self.wasActive, -- 396
		kbCursor = self.kbCursor, -- 397
		dragging = self.dragging, -- 398
		path = __TS__ArraySlice(self.lastKnownPath), -- 399
		previewEffect = ____exports.deriveEffectFromGrid(self.lastKnownPath), -- 400
		nextEffect = self.lastKnownNextEffect, -- 401
		retracting = self.retractAnimT > 0, -- 402
		invalidFlash = self.localInvalidFlash, -- 403
		clock = self:getClockReadings(), -- 404
		panelCenterX = self.panelCx, -- 405
		panelCenterY = self.panelCy, -- 406
		cellStep = self.cellStep -- 407
	} -- 407
end -- 394
function ReloadWheelPlugin.prototype.onBindPlay(self, _p, _view) -- 411
	self.wasActive = false -- 412
	self.openAnimT = 0 -- 413
	self.retractAnimT = 0 -- 414
	self.settledPath = {} -- 415
	self.settledEffect = "normal" -- 416
	self.settledTimedOut = false -- 417
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 418
	self.lastKnownNextEffect = "normal" -- 419
	self.kbCursor = ____exports.RELOAD_START_NODE -- 420
	self.dragging = false -- 421
	self.pointerActive = false -- 422
	self.localInvalidFlash = 0 -- 423
	self.animTime = 0 -- 424
	self.answerTicksAccum = 0 -- 425
	self.worldTicksAccum = 0 -- 426
	self.lastClock = {answerTicks = 0, worldTicks = 0, ratio = 0, active = false} -- 427
	self.appliedVfx = {} -- 428
	self.pendingSimInput = nil -- 429
	self:resetInputEdges() -- 430
end -- 411
function ReloadWheelPlugin.prototype.resetInputEdges(self, touchMode) -- 433
	if touchMode == nil then -- 433
		touchMode = false -- 433
	end -- 433
	local ____temp_1 -- 434
	if not touchMode and type(Mouse) ~= "nil" then -- 434
		____temp_1 = Mouse.leftButtonPressed -- 434
	else -- 434
		____temp_1 = false -- 434
	end -- 434
	self.prevLeft = ____temp_1 -- 434
	local ____temp_2 -- 435
	if not touchMode and type(Mouse) ~= "nil" then -- 435
		____temp_2 = Mouse.rightButtonPressed -- 435
	else -- 435
		____temp_2 = false -- 435
	end -- 435
	self.prevRight = ____temp_2 -- 435
	if type(Keyboard) ~= "nil" then -- 435
		self.prevUp = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 437
		self.prevDown = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 438
		self.prevLeftKey = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 439
		self.prevRightKey = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 440
		self.prevConfirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 441
		self.prevReset = Keyboard:isKeyPressed("BackSpace") -- 442
	end -- 442
end -- 433
function ReloadWheelPlugin.prototype.submitIntent(self, p, intent) -- 446
	local contract = resolveRuntimeContract(self.injectedContract) -- 447
	if contract ~= nil then -- 447
		return contract:submitIntent(p, intent) -- 449
	end -- 449
	return dispatchIntentFallback(p, intent) -- 451
end -- 446
function ReloadWheelPlugin.prototype.computePanelPlacement(self, ctx) -- 454
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 455
	local soldierUiX = ctx.cam:sx(ctx.p.player.x) / ctx.uiScale -- 456
	local marginX = self.panelW * 0.5 + 34 -- 457
	local minCx = marginX + safe.left -- 458
	local maxCx = math.max(minCx, ctx.uiW - marginX - safe.right) -- 459
	if soldierUiX < ctx.uiW * 0.56 then -- 459
		self.panelCx = math.min( -- 461
			maxCx, -- 461
			math.max( -- 461
				minCx, -- 461
				math.max(ctx.uiW * 0.7, soldierUiX + 230) -- 461
			) -- 461
		) -- 461
	else -- 461
		self.panelCx = math.max( -- 463
			minCx, -- 463
			math.min( -- 463
				maxCx, -- 463
				math.min(ctx.uiW * 0.3, soldierUiX - 230) -- 463
			) -- 463
		) -- 463
	end -- 463
	local minCy = self.panelH * 0.5 + 78 + safe.bottom -- 465
	local maxCy = math.max(minCy, ctx.uiH - self.panelH * 0.5 - 66 - safe.top) -- 466
	self.panelCy = math.max( -- 467
		minCy, -- 467
		math.min(maxCy, ctx.uiH * 0.52) -- 467
	) -- 467
	self.resetBox = Rect(self.panelCx + 56, self.panelCy + self.panelH * 0.5 - 45, 72, 26) -- 468
end -- 454
function ReloadWheelPlugin.prototype.update(self, ctx) -- 471
	local rs = ctx.view.reloadSession -- 472
	local p = ctx.p -- 473
	self:computePanelPlacement(ctx) -- 476
	ctx.audio:setWorldPlaySpeed(rs.active and math.max( -- 479
		0.25, -- 479
		math.min(1, ctx.view.timeScale) -- 479
	) or 1) -- 479
	if ctx.paused then -- 479
		self:resetInputEdges(ctx.input:isTouchMode()) -- 483
		return -- 484
	end -- 484
	local udt = math.max(0, ctx.uiDt) -- 487
	local wdt = math.max(0, ctx.worldDt) -- 488
	self.animTime = self.animTime + udt -- 489
	if self.localInvalidFlash > 0 then -- 489
		self.localInvalidFlash = math.max(0, self.localInvalidFlash - udt) -- 492
	end -- 492
	if rs.invalidFlash > self.localInvalidFlash then -- 492
		self.localInvalidFlash = rs.invalidFlash -- 495
	end -- 495
	self:ingestAppliedEffects(ctx) -- 499
	self:updateAppliedVfx(wdt) -- 500
	if rs.active and not self.wasActive then -- 500
		self:onSessionOpened(ctx) -- 504
	elseif not rs.active and self.wasActive then -- 504
		self:onSessionClosed(ctx) -- 506
	end -- 506
	self.wasActive = rs.active -- 508
	if not rs.active then -- 508
		self.lastKnownNextEffect = rs.nextEffect -- 511
		self.lastClock.active = false -- 512
		if self.retractAnimT > 0 then -- 512
			self.retractAnimT = math.max(0, self.retractAnimT - udt) -- 514
		end -- 514
		self.pendingSimInput = nil -- 516
		return -- 517
	end -- 517
	self.openAnimT = math.min( -- 521
		1, -- 521
		self.openAnimT + udt / math.max(0.01, self.openDuration) -- 521
	) -- 521
	local liveAns = readOptionalNum(p, "reloadAnswerTicks") -- 524
	local liveWorld = readOptionalNum(p, "reloadWorldTicks") -- 525
	if liveAns ~= nil and liveWorld ~= nil and not ctx.view.isRehearsal then -- 525
		self.answerTicksAccum = liveAns -- 527
		self.worldTicksAccum = liveWorld -- 528
	else -- 528
		self.answerTicksAccum = self.answerTicksAccum + udt * 60 -- 530
		self.worldTicksAccum = self.worldTicksAccum + wdt * 60 -- 531
	end -- 531
	self.lastClock = { -- 533
		answerTicks = math.floor(self.answerTicksAccum + 0.5), -- 534
		worldTicks = math.floor(self.worldTicksAccum + 0.5), -- 535
		ratio = self.worldTicksAccum > 0.01 and self.answerTicksAccum / self.worldTicksAccum or 0, -- 536
		active = true -- 537
	} -- 537
	local activePath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 541
	self.lastKnownPath = activePath -- 542
	self.lastKnownNextEffect = rs.nextEffect -- 543
	self:processInputs(ctx, activePath) -- 546
end -- 471
function ReloadWheelPlugin.prototype.onSessionOpened(self, ctx) -- 549
	local rs = ctx.view.reloadSession -- 550
	self.openDuration = rs.firstTime and 0.24 or 0.1 -- 551
	self.openAnimT = 0 -- 552
	self.retractAnimT = 0 -- 553
	self.kbCursor = ____exports.RELOAD_START_NODE -- 554
	self.dragging = false -- 555
	self.pointerActive = false -- 556
	self.lastKnownPath = #rs.path > 0 and __TS__ArraySlice(rs.path) or ({____exports.RELOAD_START_NODE}) -- 557
	self.answerTicksAccum = 0 -- 558
	self.worldTicksAccum = 0 -- 559
	self:resetInputEdges(ctx.input:isTouchMode()) -- 560
	local hasBackendOpen = false -- 562
	local i = 0 -- 563
	do -- 563
		i = 0 -- 564
		while i < #ctx.events.rawEvents do -- 564
			if ctx.events.rawEvents[i + 1].name == "reloadOpen" then -- 564
				hasBackendOpen = true -- 566
				break -- 567
			end -- 567
			i = i + 1 -- 564
		end -- 564
	end -- 564
	if not hasBackendOpen then -- 564
		ctx.audio:playOnce( -- 571
			(("fe02:reload_open:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 572
			"sfx", -- 573
			"assets/audio/combat/reload_open.wav", -- 574
			0.8, -- 575
			"reload:open", -- 576
			ctx.p.ticks -- 577
		) -- 577
	end -- 577
end -- 549
function ReloadWheelPlugin.prototype.onSessionClosed(self, ctx) -- 582
	local rs = ctx.view.reloadSession -- 583
	self.dragging = false -- 584
	self.settledPath = __TS__ArraySlice(self.lastKnownPath) -- 585
	if #self.settledPath > 0 and self.settledPath[#self.settledPath] ~= ____exports.RELOAD_TARGET_NODE and rs.nextEffect ~= "normal" then -- 585
		local ____self_settledPath_3 = self.settledPath -- 585
		____self_settledPath_3[#____self_settledPath_3 + 1] = ____exports.RELOAD_TARGET_NODE -- 588
	end -- 588
	self.settledEffect = rs.nextEffect -- 590
	self.settledTimedOut = rs.nextEffect == "normal" -- 591
	self.retractAnimT = self.retractDuration -- 592
	local hasBackendClose = false -- 595
	local i = 0 -- 596
	do -- 596
		i = 0 -- 597
		while i < #ctx.events.rawEvents do -- 597
			local n = ctx.events.rawEvents[i + 1].name -- 598
			if n == "reloadSolved" or n == "reloadTimeout" then -- 598
				hasBackendClose = true -- 600
				break -- 601
			end -- 601
			i = i + 1 -- 597
		end -- 597
	end -- 597
	if self.settledTimedOut then -- 597
		if not hasBackendClose then -- 597
			ctx.audio:playOnce( -- 607
				(("fe02:reload_timeout:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks), -- 608
				"sfx", -- 609
				"assets/audio/combat/reload_timeout.wav", -- 610
				0.78, -- 611
				"reload:timeout", -- 612
				ctx.p.ticks -- 613
			) -- 613
		end -- 613
	else -- 613
		local effectWav = self.settledEffect == "echo" and "assets/audio/combat/reload_solved_echo.wav" or (self.settledEffect == "light" and "assets/audio/combat/reload_solved_light.wav" or "assets/audio/combat/reload_solved_knockback.wav") -- 617
		ctx.audio:playOnce( -- 622
			(((("fe02:reload_solved_fx:r" .. tostring(ctx.events.roomSessionId)) .. ":t") .. tostring(ctx.p.ticks)) .. ":") .. self.settledEffect, -- 623
			"sfx", -- 624
			effectWav, -- 625
			0.88, -- 626
			"reload:solved:" .. self.settledEffect, -- 627
			ctx.p.ticks -- 628
		) -- 628
	end -- 628
end -- 582
function ReloadWheelPlugin.prototype.processInputs(self, ctx, activePath) -- 633
	local sim = self.pendingSimInput -- 634
	self.pendingSimInput = nil -- 635
	local touchMode = ctx.input:isTouchMode() -- 637
	local useUiPtr = (sim and sim.pointerX) == nil and (ctx.input.uiHeld or ctx.input.uiPressed or ctx.input.uiReleased or touchMode and ctx.input.uiInside) -- 638
	local ptrX = (sim and sim.pointerX) ~= nil and sim.pointerX or (useUiPtr and ctx.input.uiX or ctx.input.mx) / ctx.uiScale -- 640
	local ptrY = (sim and sim.pointerY) ~= nil and sim.pointerY or (useUiPtr and ctx.input.uiY or ctx.input.my) / ctx.uiScale -- 643
	local ____temp_13 -- 646
	if (sim and sim.pointerX) ~= nil then -- 646
		____temp_13 = true -- 647
	else -- 647
		local ____useUiPtr_12 -- 648
		if useUiPtr then -- 648
			____useUiPtr_12 = ctx.input.uiInside -- 648
		else -- 648
			____useUiPtr_12 = ctx.input.inside -- 648
		end -- 648
		____temp_13 = ____useUiPtr_12 -- 648
	end -- 648
	local inside = ____temp_13 -- 646
	local kbmMode = ctx.input.inputMode == "kbm" -- 649
	local ____temp_16 -- 650
	if (sim and sim.leftHeld) ~= nil then -- 650
		____temp_16 = sim.leftHeld -- 651
	else -- 651
		____temp_16 = ctx.input.uiHeld or ctx.input.fire.held or kbmMode and type(Mouse) ~= "nil" and Mouse.leftButtonPressed -- 652
	end -- 652
	local leftHeld = ____temp_16 -- 650
	local ____temp_19 -- 653
	if (sim and sim.rightHeld) ~= nil then -- 653
		____temp_19 = sim.rightHeld -- 654
	else -- 654
		____temp_19 = ctx.input.uiRightPressed or kbmMode and type(Mouse) ~= "nil" and Mouse.rightButtonPressed -- 655
	end -- 655
	local rightHeld = ____temp_19 -- 653
	local ____temp_22 -- 657
	if (sim and sim.leftHeld) ~= nil then -- 657
		____temp_22 = leftHeld and not self.prevLeft -- 658
	else -- 658
		____temp_22 = ctx.input.uiPressed or leftHeld and not self.prevLeft -- 659
	end -- 659
	local leftPressed = ____temp_22 -- 657
	local ____temp_25 -- 660
	if (sim and sim.leftHeld) ~= nil then -- 660
		____temp_25 = not leftHeld and self.prevLeft -- 661
	else -- 661
		____temp_25 = ctx.input.uiReleased or not leftHeld and self.prevLeft -- 662
	end -- 662
	local leftReleased = ____temp_25 -- 660
	local ____temp_28 -- 663
	if (sim and sim.rightHeld) ~= nil then -- 663
		____temp_28 = rightHeld and not self.prevRight -- 664
	else -- 664
		____temp_28 = ctx.input.uiRightPressed or rightHeld and not self.prevRight -- 665
	end -- 665
	local rightPressed = ____temp_28 -- 663
	self.prevLeft = leftHeld -- 666
	self.prevRight = rightHeld -- 667
	self.lastUiPtrX = ptrX -- 668
	self.lastUiPtrY = ptrY -- 669
	local rawDx = useUiPtr and ctx.input.uiDx or ctx.input.mdx -- 671
	local rawDy = useUiPtr and ctx.input.uiDy or ctx.input.mdy -- 672
	local pointerMoved = (sim and sim.pointerX) ~= nil or inside and math.abs(rawDx) + math.abs(rawDy) >= ctx.uiScale -- 673
	if pointerMoved or leftPressed then -- 673
		self.pointerActive = true -- 676
	end -- 676
	local lastNode = activePath[#activePath] -- 679
	local useTouchHit = touchMode or ctx.input.uiHeld or ctx.input.uiPressed -- 680
	local activeHitR = useTouchHit and 38 or self.hitRadius -- 681
	local hitNode = inside and self:hitTestNode(ptrX, ptrY, activeHitR) or -1 -- 682
	local hitResetBtn = inside and (touchMode or #activePath > 1) and self.resetBox:containsPoint(Vec2(ptrX, ptrY)) -- 685
	if (rightPressed or leftPressed and hitResetBtn) and #activePath > 1 then -- 685
		self.dragging = false -- 687
		self.dragAdvanced = false -- 688
		self:triggerInvalidReset(ctx, activePath, false) -- 689
		return -- 690
	end -- 690
	if leftPressed then -- 690
		if hitNode == ____exports.RELOAD_START_NODE or hitNode == lastNode then -- 690
			self.dragging = true -- 696
			self.dragAdvanced = false -- 697
			self.kbCursor = lastNode -- 698
		elseif hitNode >= 0 then -- 698
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 698
				self.dragging = true -- 701
				self.dragAdvanced = false -- 702
				self:commitNodeStep(ctx, hitNode, activePath) -- 703
			else -- 703
				self.dragging = false -- 705
				self.dragAdvanced = false -- 706
				self:triggerInvalidReset(ctx, activePath, true) -- 707
			end -- 707
			return -- 709
		end -- 709
	elseif self.dragging and leftHeld then -- 709
		if hitNode >= 0 and hitNode ~= lastNode then -- 709
			if __TS__ArrayIndexOf(activePath, hitNode) < 0 and ____exports.isAdjacentNode(lastNode, hitNode) then -- 709
				self.dragAdvanced = true -- 714
				self:commitNodeStep(ctx, hitNode, activePath) -- 715
			else -- 715
				self.dragging = false -- 718
				self.dragAdvanced = false -- 719
				self:triggerInvalidReset(ctx, activePath, true) -- 720
			end -- 720
			return -- 722
		end -- 722
	elseif leftReleased and self.dragging then -- 722
		local wasDragStroke = self.dragAdvanced -- 725
		self.dragging = false -- 726
		self.dragAdvanced = false -- 727
		if wasDragStroke and lastNode ~= ____exports.RELOAD_TARGET_NODE and #activePath > 1 then -- 727
			self:triggerInvalidReset(ctx, activePath, true) -- 730
			return -- 731
		end -- 731
	end -- 731
	local dCol = 0 -- 736
	local dRow = 0 -- 737
	local confirmPressed = false -- 738
	local resetPressed = false -- 739
	local gpAutoCommit = false -- 740
	if sim ~= nil and (sim.moveCol ~= nil or sim.moveRow ~= nil or sim.confirm ~= nil or sim.reset ~= nil) then -- 740
		dCol = sim.moveCol or 0 -- 743
		dRow = sim.moveRow or 0 -- 744
		confirmPressed = sim.confirm == true -- 745
		resetPressed = sim.reset == true -- 746
	else -- 746
		if type(Keyboard) ~= "nil" then -- 746
			local up = Keyboard:isKeyPressed("W") or Keyboard:isKeyPressed("Up") -- 749
			local down = Keyboard:isKeyPressed("S") or Keyboard:isKeyPressed("Down") -- 750
			local lk = Keyboard:isKeyPressed("A") or Keyboard:isKeyPressed("Left") -- 751
			local rk = Keyboard:isKeyPressed("D") or Keyboard:isKeyPressed("Right") -- 752
			local confirm = Keyboard:isKeyPressed("Return") or Keyboard:isKeyPressed("Space") or Keyboard:isKeyPressed("E") -- 753
			local reset = Keyboard:isKeyPressed("BackSpace") -- 754
			if up and not self.prevUp then -- 754
				dRow = dRow + 1 -- 756
			end -- 756
			if down and not self.prevDown then -- 756
				dRow = dRow - 1 -- 757
			end -- 757
			if rk and not self.prevRightKey then -- 757
				dCol = dCol + 1 -- 758
			end -- 758
			if lk and not self.prevLeftKey then -- 758
				dCol = dCol - 1 -- 759
			end -- 759
			confirmPressed = confirm and not self.prevConfirm -- 760
			resetPressed = reset and not self.prevReset -- 761
			self.prevUp = up -- 763
			self.prevDown = down -- 764
			self.prevLeftKey = lk -- 765
			self.prevRightKey = rk -- 766
			self.prevConfirm = confirm -- 767
			self.prevReset = reset -- 768
		end -- 768
		if ctx.input.reloadReset then -- 768
			resetPressed = true -- 771
		end -- 771
		if ctx.input.reloadConfirm then -- 771
			confirmPressed = true -- 774
		end -- 774
		if dCol == 0 and dRow == 0 and ctx.input.reloadStepEdge then -- 774
			dCol = ctx.input.reloadDirCol -- 777
			dRow = ctx.input.reloadDirRow -- 778
			gpAutoCommit = ctx.input.reloadAutoStep -- 779
		end -- 779
	end -- 779
	if resetPressed and #activePath > 1 then -- 779
		self:triggerInvalidReset(ctx, activePath, false) -- 784
		return -- 785
	end -- 785
	if dCol ~= 0 or dRow ~= 0 then -- 785
		self.pointerActive = false -- 789
		local baseIdx = gpAutoCommit and lastNode or self.kbCursor -- 790
		local cur = ____exports.RELOAD_GRID[baseIdx + 1] or ____exports.RELOAD_GRID[1] -- 791
		local nextCol = math.max( -- 792
			0, -- 792
			math.min(2, cur.col + dCol) -- 792
		) -- 792
		local nextRow = math.max( -- 793
			0, -- 793
			math.min(2, cur.row + dRow) -- 793
		) -- 793
		local nextIdx = nextRow * 3 + nextCol -- 794
		self.kbCursor = nextIdx -- 795
		if gpAutoCommit and nextIdx ~= lastNode and __TS__ArrayIndexOf(activePath, nextIdx) < 0 and ____exports.isAdjacentNode(lastNode, nextIdx) then -- 795
			self:commitNodeStep(ctx, nextIdx, activePath) -- 797
			return -- 798
		end -- 798
	end -- 798
	if confirmPressed then -- 798
		self.pointerActive = false -- 803
		if self.kbCursor == lastNode then -- 803
			return -- 805
		end -- 805
		if __TS__ArrayIndexOf(activePath, self.kbCursor) < 0 and ____exports.isAdjacentNode(lastNode, self.kbCursor) then -- 805
			self:commitNodeStep(ctx, self.kbCursor, activePath) -- 808
		else -- 808
			self:triggerInvalidReset(ctx, activePath, true) -- 810
		end -- 810
	end -- 810
end -- 633
function ReloadWheelPlugin.prototype.commitNodeStep(self, ctx, node, activePath) -- 815
	self.kbCursor = node -- 816
	self:submitIntent(ctx.p, {kind = "reloadTapNode", node = node}) -- 817
	self.lastKnownPath = __TS__ArrayConcat(activePath, {node}) -- 818
	if node == ____exports.RELOAD_TARGET_NODE then -- 818
		self.dragging = false -- 820
		return -- 821
	end -- 821
	self.nodePulseSeq = self.nodePulseSeq + 1 -- 824
	local stepIdx = math.max( -- 825
		1, -- 825
		math.min(6, #self.lastKnownPath) -- 825
	) -- 825
	local pitched = ("assets/audio/combat/reload_node_" .. tostring(stepIdx)) .. ".wav" -- 826
	local nodePath = Content:exist(pitched) and pitched or "assets/audio/combat/reload_node.wav" -- 827
	ctx.audio:playOnce( -- 828
		(((("fe02:reload_node:r" .. tostring(ctx.events.roomSessionId)) .. ":n") .. tostring(self.nodePulseSeq)) .. ":") .. tostring(node), -- 829
		"sfx", -- 830
		nodePath, -- 831
		0.78, -- 832
		"reload:node:" .. tostring(node), -- 833
		ctx.p.ticks -- 834
	) -- 834
end -- 815
function ReloadWheelPlugin.prototype.triggerInvalidReset(self, ctx, activePath, flashError) -- 838
	if flashError then -- 838
		self.localInvalidFlash = 0.36 -- 840
	end -- 840
	self.kbCursor = ____exports.RELOAD_START_NODE -- 842
	self.lastKnownPath = {____exports.RELOAD_START_NODE} -- 843
	if #activePath > 1 then -- 843
		self:submitIntent(ctx.p, {kind = "reloadTapNode", node = ____exports.RELOAD_START_NODE}) -- 846
	end -- 846
	if flashError then -- 846
		self.nodePulseSeq = self.nodePulseSeq + 1 -- 849
		ctx.audio:playOnce( -- 850
			(("fe02:reload_invalid:r" .. tostring(ctx.events.roomSessionId)) .. ":e") .. tostring(self.nodePulseSeq), -- 851
			"sfx", -- 852
			"assets/audio/combat/reload_invalid.wav", -- 853
			0.72, -- 854
			"reload:invalid", -- 855
			ctx.p.ticks -- 856
		) -- 856
	end -- 856
end -- 838
function ReloadWheelPlugin.prototype.hitTestNode(self, uiX, uiY, hitR) -- 861
	if hitR == nil then -- 861
		hitR = self.hitRadius -- 861
	end -- 861
	local r2 = hitR * hitR -- 862
	local i = 0 -- 863
	do -- 863
		i = 0 -- 864
		while i < #____exports.RELOAD_GRID do -- 864
			local pos = self:getNodeUiPos(i) -- 865
			local dx = uiX - pos.x -- 866
			local dy = uiY - pos.y -- 867
			if dx * dx + dy * dy <= r2 then -- 867
				return i -- 869
			end -- 869
			i = i + 1 -- 864
		end -- 864
	end -- 864
	return -1 -- 872
end -- 861
function ReloadWheelPlugin.prototype.ingestAppliedEffects(self, ctx) -- 875
	local p = ctx.p -- 876
	local triggered = false -- 877
	local i = 0 -- 878
	do -- 878
		i = 0 -- 879
		while i < #ctx.events.rawEvents do -- 879
			local e = ctx.events.rawEvents[i + 1] -- 880
			if e.name == "reloadApplied" then -- 880
				local rawEff = e.data.effect -- 882
				local eff = rawEff == "echo" and "echo" or (rawEff == "light" and "light" or "knockback") -- 883
				local ex = type(e.data.enemyX) == "number" and e.data.enemyX or p.player.x + p.player.facing * 200 -- 886
				self:spawnAppliedVfx(eff, p, ex) -- 887
				triggered = true -- 888
			end -- 888
			i = i + 1 -- 879
		end -- 879
	end -- 879
	if not triggered and ctx.events.shotFired and self.lastKnownNextEffect ~= "normal" and ctx.view.reloadSession.nextEffect == "normal" then -- 879
		local tx = ctx.events.shotTrace ~= nil and ctx.events.shotTrace.x1 or p.player.x + p.player.facing * 220 -- 893
		self:spawnAppliedVfx(self.lastKnownNextEffect, p, tx) -- 894
	end -- 894
end -- 875
function ReloadWheelPlugin.prototype.spawnAppliedVfx(self, effect, p, targetX) -- 898
	local originX = p.player.x + p.player.facing * 18 -- 899
	local originY = p.player.y + p.player.depth * DEPTH_Y_SCALE + p.player.h * 0.62 -- 900
	local targetY = p.player.y + p.player.depth * DEPTH_Y_SCALE + 46 -- 901
	local maxLife = effect == "light" and 0.42 or (effect == "echo" and 0.56 or 0.34) -- 902
	local ____self_appliedVfx_31 = self.appliedVfx -- 902
	____self_appliedVfx_31[#____self_appliedVfx_31 + 1] = { -- 903
		effect = effect, -- 904
		originX = originX, -- 905
		originY = originY, -- 906
		targetX = targetX, -- 907
		targetY = targetY, -- 908
		facing = p.player.facing >= 0 and 1 or -1, -- 909
		life = maxLife, -- 910
		maxLife = maxLife -- 911
	} -- 911
end -- 898
function ReloadWheelPlugin.prototype.updateAppliedVfx(self, wdt) -- 915
	if wdt <= 0 or #self.appliedVfx == 0 then -- 915
		return -- 917
	end -- 917
	local w = 0 -- 919
	local i = 0 -- 920
	do -- 920
		i = 0 -- 921
		while i < #self.appliedVfx do -- 921
			local fx = self.appliedVfx[i + 1] -- 922
			fx.life = fx.life - wdt -- 923
			if fx.life > 0 then -- 923
				self.appliedVfx[w + 1] = fx -- 925
				w = w + 1 -- 926
			end -- 926
			i = i + 1 -- 921
		end -- 921
	end -- 921
	__TS__ArraySetLength(self.appliedVfx, w) -- 921
end -- 915
function ReloadWheelPlugin.prototype.drawActorsOverlay(self, fgDraw, fgGlow, worldArt, ctx) -- 933
	if #self.appliedVfx == 0 then -- 933
		return -- 940
	end -- 940
	local cam = ctx.cam -- 942
	local i = 0 -- 943
	do -- 943
		i = 0 -- 944
		while i < #self.appliedVfx do -- 944
			local fx = self.appliedVfx[i + 1] -- 945
			local k = math.max( -- 946
				0, -- 946
				math.min(1, fx.life / fx.maxLife) -- 946
			) -- 946
			local prog = 1 - k -- 947
			local ox = cam:sx(fx.originX) -- 948
			local oy = cam:sy(fx.originY) -- 949
			local tx = cam:sx(fx.targetX) -- 950
			local ty = cam:sy(fx.targetY) -- 951
			if fx.effect == "knockback" then -- 951
				local r = cam:len(12 + prog * 34) -- 955
				local startA = fx.facing >= 0 and -48 or 132 -- 956
				local endA = fx.facing >= 0 and 48 or 228 -- 957
				fgGlow:drawArc( -- 958
					Vec2(tx, ty), -- 958
					r, -- 958
					startA, -- 958
					endA, -- 958
					2.4 * k, -- 958
					toColor(PALETTE.moonPale, 210 * k) -- 958
				) -- 958
				fgDraw:drawArc( -- 959
					Vec2( -- 959
						tx - fx.facing * cam:len(6), -- 959
						ty -- 959
					), -- 959
					r * 0.72, -- 959
					startA, -- 959
					endA, -- 959
					1.5 * k, -- 959
					toColor(PALETTE.silkLine, 165 * k) -- 959
				) -- 959
				local smokeSz = cam:len(22 + prog * 18) -- 960
				worldArt:tryPlace( -- 961
					"fe_vfx_smoke", -- 961
					"rw_kb_smoke_" .. tostring(i), -- 961
					tx - fx.facing * cam:len(4 + prog * 10), -- 961
					ty, -- 961
					smokeSz, -- 961
					smokeSz, -- 961
					{ -- 961
						frame = math.min( -- 962
							3, -- 962
							math.floor(prog * 4) -- 962
						), -- 962
						opacity = 0.78 * k, -- 963
						layer = 8 -- 964
					} -- 964
				) -- 964
			elseif fx.effect == "echo" then -- 964
				local r1 = cam:len(10 + prog * 64) -- 968
				local r2 = cam:len(6 + prog * 40) -- 969
				if not worldArt:tryPlace( -- 969
					"ink_enso_fine", -- 970
					"rw_echo_ring_" .. tostring(i), -- 970
					tx, -- 970
					ty, -- 970
					r1 * 2.2, -- 970
					r1 * 2.2, -- 970
					{ -- 970
						color = toColor(PALETTE.amber), -- 971
						opacity = 0.85 * k, -- 972
						angle = prog * 28, -- 973
						layer = 8 -- 974
					} -- 974
				) then -- 974
					fgGlow:drawRing( -- 976
						Vec2(tx, ty), -- 976
						math.max(1, r1 - 1.6), -- 976
						r1, -- 976
						Color(0, 0, 0, 0), -- 976
						1.3, -- 976
						toColor(PALETTE.amber, 210 * k) -- 976
					) -- 976
				end -- 976
				fgGlow:drawRing( -- 978
					Vec2(tx, ty), -- 978
					math.max(1, r2 - 1.2), -- 978
					r2, -- 978
					Color(0, 0, 0, 0), -- 978
					1, -- 978
					toColor(PALETTE.amberCore, 175 * k) -- 978
				) -- 978
			elseif fx.effect == "light" then -- 978
				fgGlow:drawSegment( -- 981
					Vec2(ox, oy), -- 981
					Vec2(tx, ty), -- 981
					5 * k, -- 981
					toColor(PALETTE.amber, 68 * k) -- 981
				) -- 981
				fgGlow:drawSegment( -- 982
					Vec2(ox, oy), -- 982
					Vec2(tx, ty), -- 982
					1.8 * k, -- 982
					toColor(PALETTE.amberCore, 185 * k) -- 982
				) -- 982
				local flashSz = cam:len(26 + prog * 10) -- 983
				worldArt:tryPlace( -- 984
					"fe_vfx_muzzle", -- 984
					"rw_light_flare_" .. tostring(i), -- 984
					ox, -- 984
					oy, -- 984
					flashSz, -- 984
					flashSz * 0.75, -- 984
					{ -- 984
						frame = math.min( -- 985
							2, -- 985
							math.floor(prog * 3) -- 985
						), -- 985
						facing = fx.facing, -- 986
						opacity = 0.9 * k, -- 987
						layer = 9 -- 988
					} -- 988
				) -- 988
				fillRadialGlow( -- 990
					fgGlow, -- 990
					tx, -- 990
					ty, -- 990
					cam:len(42 * (0.6 + prog * 0.4)), -- 990
					cam:len(34), -- 990
					toColor(PALETTE.amberCore, 118 * k), -- 990
					Color(244, 234, 214, 0), -- 990
					16 -- 990
				) -- 990
			end -- 990
			i = i + 1 -- 944
		end -- 944
	end -- 944
end -- 933
function ReloadWheelPlugin.prototype.drawFullSpeedUi(self, uiDraw, uiInkDraw, uiArt, uiGlow, ctx) -- 996
	local rs = ctx.view.reloadSession -- 1003
	local active = rs.active -- 1004
	local retracting = not active and self.retractAnimT > 0.01 -- 1005
	if not active and not retracting then -- 1005
		if rs.nextEffect ~= "normal" and not ctx.view.craftBench.active then -- 1005
			self:drawArmedEffectBadge( -- 1009
				uiDraw, -- 1009
				uiInkDraw, -- 1009
				uiArt, -- 1009
				ctx, -- 1009
				rs.nextEffect -- 1009
			) -- 1009
		end -- 1009
		return false -- 1011
	end -- 1011
	local cx = self.panelCx -- 1014
	local cy = self.panelCy -- 1015
	local pw = self.panelW -- 1016
	local ph = self.panelH -- 1017
	local x0 = cx - pw * 0.5 -- 1018
	local y0 = cy - ph * 0.5 -- 1019
	local appear = active and math.min(1, self.openAnimT) or math.max( -- 1021
		0, -- 1023
		self.retractAnimT / math.max(0.01, self.retractDuration) -- 1023
	) -- 1023
	local shakeX = self.localInvalidFlash > 0 and math.sin(self.animTime * 62) * 5.5 * (self.localInvalidFlash / 0.36) or 0 -- 1024
	local px = cx + shakeX -- 1027
	if active then -- 1027
		uiDraw:drawRect( -- 1031
			Rect(0, 0, ctx.uiW, ctx.uiH), -- 1031
			Color( -- 1031
				10, -- 1031
				13, -- 1031
				20, -- 1031
				math.floor(54 * appear + 0.5) -- 1031
			) -- 1031
		) -- 1031
	end -- 1031
	drawSilkVeil( -- 1035
		uiDraw, -- 1035
		uiArt, -- 1035
		"rw_outer_veil", -- 1035
		px, -- 1035
		cy, -- 1035
		pw + 34, -- 1035
		ph + 28, -- 1035
		PALETTE.inkWash, -- 1035
		0.72 * appear, -- 1035
		-2 -- 1035
	) -- 1035
	if not uiArt:tryPlace( -- 1035
		"ink_song_paper", -- 1036
		"rw_paper", -- 1036
		px, -- 1036
		cy, -- 1036
		pw, -- 1036
		ph, -- 1036
		{opacity = 0.94 * appear, layer = 1} -- 1036
	) then -- 1036
		uiDraw:drawRoundedRect( -- 1037
			Rect(x0 + shakeX, y0, pw, ph), -- 1038
			6, -- 1039
			toColor(PALETTE.xuanPaper, 240 * appear), -- 1040
			1.2, -- 1041
			toColor(PALETTE.xuanInkSub, 180 * appear) -- 1042
		) -- 1042
	end -- 1042
	local frameCol = self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInkSub -- 1045
	drawFiligreeCorners( -- 1046
		uiInkDraw, -- 1046
		uiArt, -- 1046
		"rw_frame", -- 1046
		x0 + shakeX + 8, -- 1046
		y0 + 8, -- 1046
		pw - 16, -- 1046
		ph - 16, -- 1046
		frameCol, -- 1046
		0.72 * appear, -- 1046
		22, -- 1046
		true, -- 1046
		2 -- 1046
	) -- 1046
	local activePath = active and (#rs.path > 0 and rs.path or ({____exports.RELOAD_START_NODE})) or self.settledPath -- 1049
	local previewEffect = active and (#rs.path >= 2 and ____exports.deriveEffectFromGrid(activePath) or rs.previewEffect) or self.settledEffect -- 1052
	local effAccent = self:effectInkColor(previewEffect) -- 1055
	local headY = y0 + ph - 32 -- 1057
	____exports.drawReloadPatternGlyph( -- 1058
		uiInkDraw, -- 1058
		px - 52, -- 1058
		headY, -- 1058
		11, -- 1058
		previewEffect, -- 1058
		effAccent, -- 1058
		appear -- 1058
	) -- 1058
	local titleText = active and ____exports.reloadEffectShortLabel(previewEffect) or (self.settledTimedOut and "普通装填" or ____exports.reloadEffectShortLabel(self.settledEffect)) -- 1059
	ctx.texts:put( -- 1062
		"sm", -- 1063
		titleText, -- 1064
		px - 32, -- 1065
		headY, -- 1066
		toColor(self.localInvalidFlash > 0.05 and PALETTE.rouge or PALETTE.xuanInk), -- 1067
		0, -- 1068
		0.5, -- 1069
		"Left", -- 1070
		1.6, -- 1071
		0.96 * appear, -- 1072
		0 -- 1073
	) -- 1073
	if active and (ctx.input:isTouchMode() or #activePath > 1) then -- 1073
		local canReset = #activePath > 1 -- 1076
		local rb = Rect(self.resetBox.x + shakeX, self.resetBox.y, self.resetBox.width, self.resetBox.height) -- 1077
		uiInkDraw:drawRect( -- 1078
			rb, -- 1079
			Color( -- 1080
				32, -- 1080
				30, -- 1080
				32, -- 1080
				math.floor((canReset and 32 or 12) * appear + 0.5) -- 1080
			), -- 1080
			0.85, -- 1081
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub, (canReset and 185 or 95) * appear) -- 1082
		) -- 1082
		ctx.texts:put( -- 1084
			"xs", -- 1085
			"重画", -- 1086
			rb.x + rb.width * 0.5, -- 1087
			rb.y + rb.height * 0.5, -- 1088
			toColor(canReset and PALETTE.rouge or PALETTE.xuanInkSub), -- 1089
			0.5, -- 1090
			0.5, -- 1091
			"Center", -- 1092
			1, -- 1093
			(canReset and 0.94 or 0.52) * appear, -- 1094
			0 -- 1095
		) -- 1095
	end -- 1095
	drawHairline( -- 1098
		uiInkDraw, -- 1098
		uiArt, -- 1098
		"rw_head_line", -- 1098
		px, -- 1098
		headY - 18, -- 1098
		pw - 42, -- 1098
		PALETTE.xuanInkSub, -- 1098
		0.45 * appear, -- 1098
		false, -- 1098
		2 -- 1098
	) -- 1098
	local idx = 0 -- 1101
	do -- 1101
		idx = 0 -- 1102
		while idx < 3 do -- 1102
			local hA = self:getNodeUiPos(idx * 3) -- 1103
			local hB = self:getNodeUiPos(idx * 3 + 2) -- 1104
			uiInkDraw:drawSegment( -- 1105
				Vec2(hA.x + shakeX, hA.y), -- 1105
				Vec2(hB.x + shakeX, hB.y), -- 1105
				0.75, -- 1105
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1105
			) -- 1105
			local vA = self:getNodeUiPos(idx) -- 1106
			local vB = self:getNodeUiPos(6 + idx) -- 1107
			uiInkDraw:drawSegment( -- 1108
				Vec2(vA.x + shakeX, vA.y), -- 1108
				Vec2(vB.x + shakeX, vB.y), -- 1108
				0.75, -- 1108
				toColor(PALETTE.xuanInkSub, 78 * appear) -- 1108
			) -- 1108
			idx = idx + 1 -- 1102
		end -- 1102
	end -- 1102
	if #activePath >= 2 then -- 1102
		self:drawPathStrokes( -- 1113
			uiInkDraw, -- 1113
			uiGlow, -- 1113
			activePath, -- 1113
			previewEffect, -- 1113
			effAccent, -- 1113
			shakeX, -- 1113
			appear -- 1113
		) -- 1113
	end -- 1113
	if active and self.dragging and #activePath >= 1 then -- 1113
		local tail = self:getNodeUiPos(activePath[#activePath]) -- 1118
		local mx = ctx.input.uiHeld and ctx.input.uiX / ctx.uiScale or self.lastUiPtrX -- 1119
		local my = ctx.input.uiHeld and ctx.input.uiY / ctx.uiScale or self.lastUiPtrY -- 1120
		uiInkDraw:drawSegment( -- 1121
			Vec2(tail.x + shakeX, tail.y), -- 1121
			Vec2(mx, my), -- 1121
			1.4, -- 1121
			toColor(effAccent, 150 * appear) -- 1121
		) -- 1121
		uiInkDraw:drawDot( -- 1122
			Vec2(mx, my), -- 1122
			3, -- 1122
			toColor(effAccent, 210 * appear) -- 1122
		) -- 1122
	end -- 1122
	local lastNode = #activePath > 0 and activePath[#activePath] or ____exports.RELOAD_START_NODE -- 1126
	do -- 1126
		idx = 0 -- 1127
		while idx < #____exports.RELOAD_GRID do -- 1127
			local spec = ____exports.RELOAD_GRID[idx + 1] -- 1128
			local pos = self:getNodeUiPos(idx) -- 1129
			local nx = pos.x + shakeX -- 1130
			local ny = pos.y -- 1131
			local inPath = __TS__ArrayIndexOf(activePath, idx) >= 0 -- 1132
			local isValidNext = active and not inPath and ____exports.isAdjacentNode(lastNode, idx) -- 1133
			local isKbFocus = active and not self.pointerActive and self.kbCursor == idx -- 1134
			self:drawGridNode( -- 1135
				uiInkDraw, -- 1135
				uiArt, -- 1135
				uiGlow, -- 1135
				spec, -- 1135
				nx, -- 1135
				ny, -- 1135
				inPath, -- 1135
				isValidNext, -- 1135
				isKbFocus, -- 1135
				effAccent, -- 1135
				appear -- 1135
			) -- 1135
			idx = idx + 1 -- 1127
		end -- 1127
	end -- 1127
	self:drawChildFinger( -- 1139
		uiInkDraw, -- 1139
		uiArt, -- 1139
		uiGlow, -- 1139
		active, -- 1139
		activePath, -- 1139
		shakeX, -- 1139
		appear -- 1139
	) -- 1139
	local barW = pw - 52 -- 1142
	local barX = px - barW * 0.5 -- 1143
	local barY = y0 + 28 -- 1144
	local remainFrac = active and math.max( -- 1145
		0, -- 1146
		math.min( -- 1146
			1, -- 1146
			1 - rs.elapsed / math.max(0.01, rs.duration) -- 1146
		) -- 1146
	) or (self.settledTimedOut and 0 or 1) -- 1146
	local urgent = active and remainFrac < 0.25 -- 1148
	local barCol = urgent and PALETTE.rouge or PALETTE.xuanInk -- 1149
	uiInkDraw:drawSegment( -- 1150
		Vec2(barX, barY), -- 1150
		Vec2(barX + barW, barY), -- 1150
		1.4, -- 1150
		toColor(PALETTE.xuanInkSub, 85 * appear) -- 1150
	) -- 1150
	if remainFrac > 0.005 then -- 1150
		uiInkDraw:drawSegment( -- 1152
			Vec2(barX, barY), -- 1152
			Vec2(barX + barW * remainFrac, barY), -- 1152
			3, -- 1152
			toColor(barCol, 225 * appear) -- 1152
		) -- 1152
	end -- 1152
	local tTick = 1 -- 1155
	do -- 1155
		tTick = 1 -- 1156
		while tTick <= 3 do -- 1156
			local tx = barX + barW * (tTick / 4) -- 1157
			uiInkDraw:drawSegment( -- 1158
				Vec2(tx, barY - 3.5), -- 1158
				Vec2(tx, barY + 3.5), -- 1158
				0.9, -- 1158
				toColor(PALETTE.xuanInkSub, 125 * appear) -- 1158
			) -- 1158
			tTick = tTick + 1 -- 1156
		end -- 1156
	end -- 1156
	if active and ctx.view.assistHintsEnabled then -- 1156
		local mode = ctx.input.inputMode -- 1163
		local hint = mode == "gamepad" and ("左摇杆八向直连至右上 · " .. keyTagFor("back", "gamepad", ctx.input.gamepadLayout)) .. " 重画" or (mode == "touch" and "单指一笔滑连至右上 · 点重画清空" or "拖线或方向+回车连至右上") -- 1164
		ctx.texts:put( -- 1169
			"xs", -- 1170
			hint, -- 1171
			px, -- 1172
			y0 + 13, -- 1173
			toColor(PALETTE.xuanInkSub), -- 1174
			0.5, -- 1175
			0.5, -- 1176
			"Center", -- 1177
			0.6, -- 1178
			0.82 * appear, -- 1179
			0 -- 1180
		) -- 1180
	end -- 1180
	return active -- 1184
end -- 996
function ReloadWheelPlugin.prototype.effectInkColor(self, effect) -- 1187
	if effect == "echo" then -- 1187
		return PALETTE.rouge -- 1189
	end -- 1189
	if effect == "light" then -- 1189
		return PALETTE.amberDim -- 1192
	end -- 1192
	if effect == "knockback" then -- 1192
		return PALETTE.xuanInk -- 1195
	end -- 1195
	return PALETTE.xuanInkSub -- 1197
end -- 1187
function ReloadWheelPlugin.prototype.drawPathStrokes(self, uiInkDraw, uiGlow, path, effect, col, shakeX, appear) -- 1200
	local i = 0 -- 1209
	do -- 1209
		i = 0 -- 1210
		while i < #path - 1 do -- 1210
			local p0 = self:getNodeUiPos(path[i + 1]) -- 1211
			local p1 = self:getNodeUiPos(path[i + 1 + 1]) -- 1212
			local ax = p0.x + shakeX -- 1213
			local ay = p0.y -- 1214
			local bx = p1.x + shakeX -- 1215
			local by = p1.y -- 1216
			if effect == "echo" then -- 1216
				local dx = bx - ax -- 1220
				local dy = by - ay -- 1221
				local len = math.max( -- 1222
					1, -- 1222
					math.sqrt(dx * dx + dy * dy) -- 1222
				) -- 1222
				local nx = -dy / len * 2.2 -- 1223
				local ny = dx / len * 2.2 -- 1224
				uiInkDraw:drawSegment( -- 1225
					Vec2(ax + nx, ay + ny), -- 1225
					Vec2(bx + nx, by + ny), -- 1225
					1.35, -- 1225
					toColor(col, 220 * appear) -- 1225
				) -- 1225
				uiInkDraw:drawSegment( -- 1226
					Vec2(ax - nx, ay - ny), -- 1226
					Vec2(bx - nx, by - ny), -- 1226
					1.35, -- 1226
					toColor(col, 220 * appear) -- 1226
				) -- 1226
			elseif effect == "light" then -- 1226
				uiInkDraw:drawSegment( -- 1229
					Vec2(ax, ay), -- 1229
					Vec2(bx, by), -- 1229
					3.1, -- 1229
					toColor(PALETTE.xuanInk, 195 * appear) -- 1229
				) -- 1229
				uiInkDraw:drawSegment( -- 1230
					Vec2(ax, ay), -- 1230
					Vec2(bx, by), -- 1230
					1.3, -- 1230
					toColor(PALETTE.amberCore, 235 * appear) -- 1230
				) -- 1230
				uiGlow:drawSegment( -- 1231
					Vec2(ax, ay), -- 1231
					Vec2(bx, by), -- 1231
					3.2, -- 1231
					toColor(PALETTE.amber, 55 * appear) -- 1231
				) -- 1231
			else -- 1231
				uiInkDraw:drawSegment( -- 1234
					Vec2(ax, ay), -- 1234
					Vec2(bx, by), -- 1234
					2.8, -- 1234
					toColor(col, 230 * appear) -- 1234
				) -- 1234
			end -- 1234
			i = i + 1 -- 1210
		end -- 1210
	end -- 1210
end -- 1200
function ReloadWheelPlugin.prototype.drawGridNode(self, uiInkDraw, uiArt, uiGlow, spec, nx, ny, inPath, isValidNext, isKbFocus, effAccent, appear) -- 1239
	local baseR = spec.kind == "plain" and 11 or 15 -- 1252
	local strokeCol = inPath and effAccent or (isValidNext and PALETTE.xuanInk or PALETTE.xuanInkSub) -- 1253
	local strokeAlpha = inPath and 245 or (isValidNext and 185 or 115) -- 1254
	if isKbFocus then -- 1254
		local focusCol = (isValidNext or inPath) and PALETTE.rouge or PALETTE.xuanInkSub -- 1258
		uiInkDraw:drawRing( -- 1259
			Vec2(nx, ny), -- 1259
			baseR + 4.5, -- 1259
			baseR + 6.2, -- 1259
			Color(0, 0, 0, 0), -- 1259
			1.1, -- 1259
			toColor(focusCol, 215 * appear) -- 1259
		) -- 1259
	end -- 1259
	if spec.kind == "bell" then -- 1259
		if inPath then -- 1259
			uiInkDraw:drawCircle( -- 1265
				Vec2(nx, ny), -- 1265
				baseR + 1, -- 1265
				toColor(PALETTE.rouge, 36 * appear) -- 1265
			) -- 1265
			uiGlow:drawRing( -- 1266
				Vec2(nx, ny), -- 1266
				baseR + 2, -- 1266
				baseR + 5, -- 1266
				Color(0, 0, 0, 0), -- 1266
				1.2, -- 1266
				toColor(PALETTE.rouge, 110 * appear) -- 1266
			) -- 1266
		end -- 1266
		uiInkDraw:drawRing( -- 1268
			Vec2(nx, ny), -- 1268
			baseR - 1.2, -- 1268
			baseR, -- 1268
			Color(0, 0, 0, 0), -- 1268
			1.1, -- 1268
			toColor(strokeCol, strokeAlpha * appear) -- 1268
		) -- 1268
		____exports.drawReloadPatternGlyph( -- 1269
			uiInkDraw, -- 1269
			nx, -- 1269
			ny, -- 1269
			9.5, -- 1269
			"echo", -- 1269
			inPath and PALETTE.rouge or strokeCol, -- 1269
			appear, -- 1269
			uiArt, -- 1269
			"rw_glyph_bell", -- 1269
			4 -- 1269
		) -- 1269
		return -- 1270
	end -- 1270
	if spec.kind == "lamp" then -- 1270
		if inPath then -- 1270
			uiInkDraw:drawCircle( -- 1276
				Vec2(nx, ny), -- 1276
				baseR + 1, -- 1276
				toColor(PALETTE.amber, 56 * appear) -- 1276
			) -- 1276
			fillRadialGlow( -- 1277
				uiGlow, -- 1277
				nx, -- 1277
				ny, -- 1277
				22, -- 1277
				22, -- 1277
				toColor(PALETTE.amberCore, 72 * appear), -- 1277
				Color(244, 234, 214, 0), -- 1277
				12 -- 1277
			) -- 1277
		end -- 1277
		uiInkDraw:drawRing( -- 1279
			Vec2(nx, ny), -- 1279
			baseR - 1.2, -- 1279
			baseR, -- 1279
			Color(0, 0, 0, 0), -- 1279
			1.1, -- 1279
			toColor(strokeCol, strokeAlpha * appear) -- 1279
		) -- 1279
		____exports.drawReloadPatternGlyph( -- 1280
			uiInkDraw, -- 1280
			nx, -- 1280
			ny, -- 1280
			9.5, -- 1280
			"light", -- 1280
			inPath and PALETTE.xuanInk or strokeCol, -- 1280
			appear, -- 1280
			uiArt, -- 1280
			"rw_glyph_lamp", -- 1280
			4 -- 1280
		) -- 1280
		return -- 1281
	end -- 1281
	if spec.kind == "target" then -- 1281
		drawDiamond( -- 1286
			uiInkDraw, -- 1287
			nx, -- 1288
			ny, -- 1289
			baseR, -- 1290
			baseR, -- 1291
			inPath and toColor(PALETTE.xuanInk, 220 * appear) or Color(0, 0, 0, 0), -- 1292
			1.4, -- 1293
			toColor(inPath and PALETTE.rouge or PALETTE.xuanInk, 230 * appear) -- 1294
		) -- 1294
		drawDiamond( -- 1296
			uiInkDraw, -- 1297
			nx, -- 1298
			ny, -- 1299
			baseR * 0.56, -- 1300
			baseR * 0.56, -- 1301
			toColor(inPath and PALETTE.amberCore or PALETTE.xuanInk, 210 * appear) -- 1302
		) -- 1302
		return -- 1304
	end -- 1304
	if spec.kind == "start" then -- 1304
		uiInkDraw:drawRing( -- 1309
			Vec2(nx, ny), -- 1309
			baseR - 2.2, -- 1309
			baseR, -- 1309
			Color(0, 0, 0, 0), -- 1309
			1.2, -- 1309
			toColor(PALETTE.rouge, 220 * appear) -- 1309
		) -- 1309
		uiInkDraw:drawCircle( -- 1310
			Vec2(nx, ny), -- 1310
			4.8, -- 1310
			toColor(PALETTE.xuanInk, 235 * appear) -- 1310
		) -- 1310
		return -- 1311
	end -- 1311
	if inPath then -- 1311
		uiInkDraw:drawCircle( -- 1316
			Vec2(nx, ny), -- 1316
			6.2, -- 1316
			toColor(effAccent, 235 * appear) -- 1316
		) -- 1316
		uiInkDraw:drawRing( -- 1317
			Vec2(nx, ny), -- 1317
			9.5, -- 1317
			10.8, -- 1317
			Color(0, 0, 0, 0), -- 1317
			1, -- 1317
			toColor(effAccent, 165 * appear) -- 1317
		) -- 1317
	else -- 1317
		uiInkDraw:drawRing( -- 1319
			Vec2(nx, ny), -- 1319
			5.6, -- 1319
			7, -- 1319
			Color(0, 0, 0, 0), -- 1319
			1, -- 1319
			toColor(strokeCol, strokeAlpha * appear) -- 1319
		) -- 1319
	end -- 1319
end -- 1239
function ReloadWheelPlugin.prototype.drawChildFinger(self, uiInkDraw, uiArt, uiGlow, active, path, shakeX, appear) -- 1324
	local fx = 0 -- 1333
	local fy = 0 -- 1334
	if active then -- 1334
		local tipNode = #path > 0 and path[#path] or ____exports.RELOAD_START_NODE -- 1337
		local pos = self:getNodeUiPos(tipNode) -- 1338
		local tapPulse = #path <= 1 and math.sin(self.animTime * 4.8) * 3.5 or 0 -- 1339
		fx = pos.x + shakeX - 2 - tapPulse * 0.3 -- 1340
		fy = pos.y - 2 - tapPulse -- 1341
		if #path <= 1 then -- 1341
			local ringR = 17 + math.sin(self.animTime * 4.2) * 2.5 -- 1344
			uiInkDraw:drawRing( -- 1345
				Vec2(pos.x + shakeX, pos.y), -- 1345
				ringR - 1, -- 1345
				ringR, -- 1345
				Color(0, 0, 0, 0), -- 1345
				1, -- 1345
				toColor(PALETTE.rouge, 130 * appear) -- 1345
			) -- 1345
		end -- 1345
	elseif self.retractAnimT > 0 and #path > 0 then -- 1345
		local prog = math.max( -- 1349
			0, -- 1349
			math.min( -- 1349
				1, -- 1349
				1 - self.retractAnimT / math.max(0.01, self.retractDuration) -- 1349
			) -- 1349
		) -- 1349
		local revFloat = (1 - prog) * (#path - 1) -- 1350
		local idxA = math.max( -- 1351
			0, -- 1351
			math.min( -- 1351
				#path - 1, -- 1351
				math.floor(revFloat) -- 1351
			) -- 1351
		) -- 1351
		local idxB = math.max( -- 1352
			0, -- 1352
			math.min(#path - 1, idxA + 1) -- 1352
		) -- 1352
		local frac = revFloat - idxA -- 1353
		local pA = self:getNodeUiPos(path[idxA + 1]) -- 1354
		local pB = self:getNodeUiPos(path[idxB + 1]) -- 1355
		fx = pA.x + (pB.x - pA.x) * frac + shakeX - prog * 28 -- 1356
		fy = pA.y + (pB.y - pA.y) * frac - prog * 22 -- 1357
	else -- 1357
		return -- 1359
	end -- 1359
	local handSlot = active and #path <= 1 and "fe_reload_hand_tap" or "fe_reload_hand_trace" -- 1363
	if not uiArt:tryPlace( -- 1363
		handSlot, -- 1364
		"rw_child_finger", -- 1364
		math.floor(fx + 0.5), -- 1364
		math.floor(fy + 0.5), -- 1364
		58, -- 1364
		58, -- 1364
		{opacity = 0.96 * appear, layer = 6} -- 1364
	) then -- 1364
		local a255 = math.floor(240 * appear + 0.5) -- 1368
		uiInkDraw:drawCircle( -- 1369
			Vec2(fx - 8, fy - 7), -- 1369
			4.6, -- 1369
			Color(238, 212, 182, a255) -- 1369
		) -- 1369
		uiInkDraw:drawSegment( -- 1370
			Vec2(fx - 6, fy - 5), -- 1370
			Vec2(fx, fy), -- 1370
			2.4, -- 1370
			Color(244, 222, 196, a255) -- 1370
		) -- 1370
	end -- 1370
	uiGlow:drawDot( -- 1372
		Vec2(fx, fy), -- 1372
		3.4, -- 1372
		toColor(PALETTE.amberCore, 80 * appear) -- 1372
	) -- 1372
end -- 1324
function ReloadWheelPlugin.prototype.drawArmedEffectBadge(self, uiDraw, uiInkDraw, uiArt, ctx, effect) -- 1376
	local safe = ctx.safeUi or ZERO_SAFE_INSETS -- 1383
	local bx = 46 + safe.left -- 1384
	local by = ctx.uiH - 134 - safe.top -- 1385
	local col = effect == "echo" and PALETTE.rouge or (effect == "light" and PALETTE.amberCore or PALETTE.cyanCore) -- 1386
	drawSilkVeil( -- 1387
		uiDraw, -- 1387
		uiArt, -- 1387
		"rw_armed_veil", -- 1387
		bx + 54, -- 1387
		by, -- 1387
		142, -- 1387
		30, -- 1387
		PALETTE.inkWash, -- 1387
		0.72, -- 1387
		-1 -- 1387
	) -- 1387
	____exports.drawReloadPatternGlyph( -- 1388
		uiInkDraw, -- 1388
		bx + 12, -- 1388
		by, -- 1388
		9, -- 1388
		effect, -- 1388
		col, -- 1388
		0.96, -- 1388
		uiArt, -- 1388
		"rw_armed_glyph", -- 1388
		4 -- 1388
	) -- 1388
	drawBlossomDot( -- 1389
		uiInkDraw, -- 1389
		uiArt, -- 1389
		"rw_armed_dot", -- 1389
		bx + 28, -- 1389
		by, -- 1389
		6, -- 1389
		col, -- 1389
		0.85, -- 1389
		3 -- 1389
	) -- 1389
	ctx.texts:put( -- 1390
		"xs", -- 1390
		____exports.reloadEffectShortLabel(effect), -- 1390
		bx + 38, -- 1390
		by, -- 1390
		toColor(PALETTE.textBright), -- 1390
		0, -- 1390
		0.5, -- 1390
		"Left", -- 1390
		1, -- 1390
		0.94, -- 1390
		0.08 -- 1390
	) -- 1390
end -- 1376
function ____exports.createReloadWheelPlugin(contract) -- 1394
	return __TS__New(____exports.ReloadWheelPlugin, contract) -- 1395
end -- 1394
return ____exports -- 1394