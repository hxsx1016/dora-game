-- [ts]: frontend.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySetLength = ____lualib.__TS__ArraySetLength -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 12
local BlendFunc = ____Dora.BlendFunc -- 12
local DrawNode = ____Dora.DrawNode -- 12
local Node = ____Dora.Node -- 12
local Vec2 = ____Dora.Vec2 -- 12
local ____platform = require("Script.watch.platform") -- 15
local computeStageViewport = ____platform.computeStageViewport -- 15
local ____adapter = require("Script.watch.fe.adapter") -- 16
local PlayAdapter = ____adapter.PlayAdapter -- 16
local ____assets = require("Script.watch.fe.assets") -- 17
local AssetSlotHost = ____assets.AssetSlotHost -- 17
local ____audio = require("Script.watch.fe.audio") -- 18
local AudioDirector = ____audio.AudioDirector -- 18
local ____camera = require("Script.watch.fe.camera") -- 19
local CameraDirector = ____camera.CameraDirector -- 19
local ____contract = require("Script.watch.fe.contract") -- 20
local DualRouteContract = ____contract.DualRouteContract -- 20
local ____occlusion = require("Script.watch.fe.occlusion") -- 21
local DepthOcclusion = ____occlusion.DepthOcclusion -- 21
local ____stage = require("Script.watch.fe.renderer.stage") -- 23
local StageRenderer = ____stage.StageRenderer -- 23
local ____props = require("Script.watch.fe.renderer.props") -- 24
local PropsRenderer = ____props.PropsRenderer -- 24
local ____actors = require("Script.watch.fe.renderer.actors") -- 25
local ActorsRenderer = ____actors.ActorsRenderer -- 25
local ____vfx = require("Script.watch.fe.renderer.vfx") -- 26
local VfxSystem = ____vfx.VfxSystem -- 26
local ____textpool = require("Script.watch.fe.ui.textpool") -- 27
local TextPool = ____textpool.TextPool -- 27
local ____hud = require("Script.watch.fe.ui.hud") -- 28
local HudRenderer = ____hud.HudRenderer -- 28
local ____narrative = require("Script.watch.fe.ui.narrative") -- 29
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 29
local ____menus = require("Script.watch.fe.ui.menus") -- 30
local MenuRenderer = ____menus.MenuRenderer -- 30
local ____theme = require("Script.watch.fe.theme") -- 31
local PALETTE = ____theme.PALETTE -- 31
local drawSilkVeil = ____theme.drawSilkVeil -- 31
local themeOf = ____theme.themeOf -- 31
local toColor = ____theme.toColor -- 31
local ____ming_audit = require("Script.watch.fe.renderer.ming_audit") -- 32
local MingArtAuditPlugin = ____ming_audit.MingArtAuditPlugin -- 32
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 33
local GateTransitionPlugin = ____gate_transition.GateTransitionPlugin -- 33
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 34
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 34
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 35
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 35
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 36
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 36
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 37
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 37
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 38
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 38
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 39
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 39
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 40
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 40
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 41
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 41
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 42
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 42
____exports.WatchFrontend = __TS__Class() -- 44
local WatchFrontend = ____exports.WatchFrontend -- 44
WatchFrontend.name = "WatchFrontend" -- 44
function WatchFrontend.prototype.____constructor(self, parent) -- 81
	self.occlusion = __TS__New(DepthOcclusion) -- 45
	self.cam = __TS__New(CameraDirector) -- 60
	self.adapter = __TS__New(PlayAdapter) -- 61
	self.contract = __TS__New(DualRouteContract) -- 62
	self.audio = __TS__New(AudioDirector) -- 63
	self.stage = __TS__New(StageRenderer) -- 64
	self.props = __TS__New(PropsRenderer) -- 65
	self.actors = __TS__New(ActorsRenderer) -- 66
	self.vfx = __TS__New(VfxSystem) -- 67
	self.hud = __TS__New(HudRenderer) -- 68
	self.narrative = __TS__New(NarrativeRenderer) -- 69
	self.menus = __TS__New(MenuRenderer) -- 70
	self.plugins = {} -- 72
	self.screen = "title" -- 74
	self.time = 0 -- 75
	self.stageVp = computeStageViewport(1280, 720) -- 77
	self.toastText = "" -- 78
	self.toastTimer = 0 -- 79
	self.layerRoot = Node() -- 82
	self.layerRoot.order = 5 -- 83
	self.layerRoot:addTo(parent) -- 84
	self.audio:attachHost(self.layerRoot) -- 86
	local additive = BlendFunc("SrcAlpha", "One") -- 88
	self.bgDraw = DrawNode() -- 90
	self.bgDraw.order = 10 -- 91
	self.bgDraw:addTo(self.layerRoot) -- 92
	self.bgGlow = DrawNode() -- 94
	self.bgGlow.order = 15 -- 95
	self.bgGlow.blendFunc = additive -- 96
	self.bgGlow:addTo(self.layerRoot) -- 97
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 99
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 100
	self.fgDraw = DrawNode() -- 102
	self.fgDraw.order = 30 -- 103
	self.fgDraw:addTo(self.layerRoot) -- 104
	self.fgGlow = DrawNode() -- 106
	self.fgGlow.order = 35 -- 107
	self.fgGlow.blendFunc = additive -- 108
	self.fgGlow:addTo(self.layerRoot) -- 109
	self.uiLayer = Node() -- 111
	self.uiLayer.order = 40 -- 112
	self.uiLayer:addTo(self.layerRoot) -- 113
	self.uiDraw = DrawNode() -- 115
	self.uiDraw.order = 0 -- 116
	self.uiDraw:addTo(self.uiLayer) -- 117
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 119
	self.uiInkDraw = DrawNode() -- 121
	self.uiInkDraw.order = 4 -- 122
	self.uiInkDraw:addTo(self.uiLayer) -- 123
	self.uiGlow = DrawNode() -- 125
	self.uiGlow.order = 6 -- 126
	self.uiGlow.blendFunc = additive -- 127
	self.uiGlow:addTo(self.uiLayer) -- 128
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 130
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 144
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 145
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 146
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 147
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 148
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 149
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 150
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 151
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 152
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 153
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 154
end -- 81
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 158
	local i = 0 -- 159
	do -- 159
		i = 0 -- 160
		while i < #self.plugins do -- 160
			if self.plugins[i + 1].id == plugin.id then -- 161
				self.plugins[i + 1] = plugin -- 162
				self:syncRuntimeHooks() -- 163
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 164
					plugin:onBindPlay( -- 165
						self.boundPlay, -- 165
						self.contract:peekSnapshot(self.boundPlay) -- 165
					) -- 165
				end -- 165
				return -- 167
			end -- 167
			i = i + 1 -- 160
		end -- 160
	end -- 160
	local ____self_plugins_0 = self.plugins -- 170
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 170
	self:syncRuntimeHooks() -- 171
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 172
		plugin:onBindPlay( -- 173
			self.boundPlay, -- 173
			self.contract:peekSnapshot(self.boundPlay) -- 173
		) -- 173
	end -- 173
end -- 158
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 178
	local w = 0 -- 179
	local i = 0 -- 180
	do -- 180
		i = 0 -- 181
		while i < #self.plugins do -- 181
			if self.plugins[i + 1].id ~= id then -- 182
				self.plugins[w + 1] = self.plugins[i + 1] -- 183
				w = w + 1 -- 184
			end -- 184
			i = i + 1 -- 181
		end -- 181
	end -- 181
	__TS__ArraySetLength(self.plugins, w) -- 187
	self:syncRuntimeHooks() -- 188
end -- 178
function WatchFrontend.prototype.getPlugin(self, id) -- 192
	local i = 0 -- 193
	do -- 193
		i = 0 -- 194
		while i < #self.plugins do -- 194
			if self.plugins[i + 1].id == id then -- 195
				return self.plugins[i + 1] -- 196
			end -- 196
			i = i + 1 -- 194
		end -- 194
	end -- 194
	return nil -- 199
end -- 192
function WatchFrontend.prototype.getPlugins(self) -- 202
	return self.plugins -- 203
end -- 202
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 211
	local g = _G -- 212
	local ____temp_1 -- 213
	if g.package ~= nil then -- 213
		____temp_1 = g.package.loaded -- 213
	else -- 213
		____temp_1 = nil -- 213
	end -- 213
	local loaded = ____temp_1 -- 213
	if loaded == nil then -- 214
		return -- 215
	end -- 215
	local rawFe = loaded["watch.fe"] -- 217
	if rawFe ~= nil and type(rawFe) == "table" then -- 218
		local watchFe = rawFe -- 219
		if watchFe.contract ~= self.contract then -- 220
			watchFe.contract = self.contract -- 221
			watchFe.audio = self.audio -- 222
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 223
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 224
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 225
		end -- 225
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 227
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 228
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 229
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 230
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 231
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 232
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 233
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 234
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 235
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 236
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 237
	end -- 237
end -- 211
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 241
	local scale = math.max( -- 242
		0.25, -- 242
		math.min(w / 1280, h / 720) -- 242
	) -- 242
	self.uiLayer.scaleX = scale -- 243
	self.uiLayer.scaleY = scale -- 244
	return scale -- 245
end -- 241
function WatchFrontend.prototype.setVisible(self, v) -- 249
	self.layerRoot.visible = v -- 250
	if not v then -- 251
		self.texts:hideAll() -- 252
	end -- 252
end -- 249
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 257
	self:syncRuntimeHooks() -- 258
	self.boundPlay = p -- 259
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 260
	self.cam:snap(p, w, h) -- 261
	self.adapter:reset(p) -- 262
	self.contract:resetForRoom(p) -- 263
	self.audio:stopRoomTransient() -- 264
	self.actors:reset(p) -- 265
	self.occlusion:reset() -- 266
	self.vfx:reset() -- 267
	self.hud:reset(p) -- 268
	self.narrative:onEnterRoom(p.room.key) -- 269
	if #self.plugins > 0 then -- 271
		local initView = self.contract:peekSnapshot(p) -- 272
		local i = 0 -- 273
		do -- 273
			i = 0 -- 274
			while i < #self.plugins do -- 274
				local pl = self.plugins[i + 1] -- 275
				if pl.onBindPlay ~= nil then -- 276
					pl:onBindPlay(p, initView) -- 277
				end -- 277
				i = i + 1 -- 274
			end -- 274
		end -- 274
	end -- 274
end -- 257
function WatchFrontend.prototype.clearAll(self) -- 283
	self.bgDraw:clear() -- 284
	self.bgGlow:clear() -- 285
	self.fgDraw:clear() -- 286
	self.fgGlow:clear() -- 287
	self.uiDraw:clear() -- 288
	self.uiInkDraw:clear() -- 289
	self.uiGlow:clear() -- 290
	self.backdropArt:beginFrame() -- 291
	self.worldArt:beginFrame() -- 292
	self.uiArt:beginFrame() -- 293
	self.texts:beginFrame() -- 294
end -- 283
function WatchFrontend.prototype.finishFrame(self) -- 297
	self.backdropArt:endFrame() -- 298
	self.worldArt:endFrame() -- 299
	self.uiArt:endFrame() -- 300
	self.texts:endFrame() -- 301
end -- 297
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 305
	self.stageVp = vp -- 306
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 307
end -- 305
function WatchFrontend.prototype.showToast(self, text, duration) -- 311
	if duration == nil then -- 311
		duration = 1.8 -- 311
	end -- 311
	self.toastText = text -- 312
	self.toastTimer = duration -- 313
end -- 311
function WatchFrontend.prototype.getToastText(self) -- 316
	return self.toastTimer > 0 and self.toastText or "" -- 317
end -- 316
function WatchFrontend.prototype.drawToast(self, uiW) -- 320
	if self.toastTimer <= 0 or self.toastText == "" then -- 321
		return -- 322
	end -- 322
	local alpha = math.min(1, self.toastTimer * 2.4) -- 324
	local cx = uiW * 0.5 -- 325
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 326
	drawSilkVeil( -- 327
		self.uiDraw, -- 327
		self.uiArt, -- 327
		"fe_toast_veil", -- 327
		cx, -- 327
		cy, -- 327
		340, -- 327
		38, -- 327
		PALETTE.inkWarm, -- 327
		0.86 * alpha, -- 327
		9 -- 327
	) -- 327
	self.texts:put( -- 328
		"sm", -- 328
		self.toastText, -- 328
		cx, -- 328
		cy, -- 328
		toColor(PALETTE.amberCore), -- 328
		0.5, -- 328
		0.5, -- 328
		"Center", -- 328
		1.4, -- 328
		0.96 * alpha, -- 328
		0.08 -- 328
	) -- 328
end -- 320
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 332
	local offers = p:getStoryTalentOffers() -- 333
	if #offers == 0 then -- 334
		return {} -- 335
	end -- 335
	local uiScale = math.max( -- 337
		0.25, -- 337
		math.min(w / 1280, h / 720) -- 337
	) -- 337
	return self.hud:talentCardRects( -- 338
		w / uiScale, -- 338
		h / uiScale, -- 338
		#offers, -- 338
		touchMode, -- 338
		self.stageVp.safeUi.top -- 338
	) -- 338
end -- 332
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 342
	self:syncRuntimeHooks() -- 343
	if self.toastTimer > 0 then -- 344
		self.toastTimer = math.max( -- 345
			0, -- 345
			self.toastTimer - math.min( -- 345
				0.05, -- 345
				math.max(0, dt) -- 345
			) -- 345
		) -- 345
	end -- 345
	if self.screen == "title" and self.boundPlay ~= nil then -- 347
		self.audio:stopRoomTransient() -- 348
		self.boundPlay = nil -- 349
	end -- 349
	self:setVisible(true) -- 351
	self:clearAll() -- 352
	local uiScale = self:resizeInterface(w, h) -- 353
	local act = self.menus:updateAndDrawScreen( -- 354
		dt, -- 355
		self.screen, -- 356
		input, -- 357
		self.stage, -- 358
		self.bgDraw, -- 359
		self.bgGlow, -- 360
		self.backdropArt, -- 361
		self.uiArt, -- 362
		self.uiDraw, -- 363
		self.uiInkDraw, -- 364
		self.uiGlow, -- 365
		self.texts, -- 366
		w, -- 367
		h, -- 368
		uiScale, -- 369
		self.stageVp.safeUi -- 370
	) -- 370
	self:drawToast(w / uiScale) -- 372
	self:finishFrame() -- 373
	return act -- 374
end -- 342
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 378
	local offers = p:getStoryTalentOffers() -- 379
	if #offers == 0 then -- 380
		return false -- 381
	end -- 381
	if input.inputMode == "gamepad" and not input.uiPressed then -- 383
		return false -- 384
	end -- 384
	local useUiPtr = input.uiInside or input.uiPressed -- 386
	local ____useUiPtr_2 -- 387
	if useUiPtr then -- 387
		____useUiPtr_2 = input.uiInside -- 387
	else -- 387
		____useUiPtr_2 = input.inside -- 387
	end -- 387
	local inside = ____useUiPtr_2 -- 387
	if not inside then -- 388
		return false -- 389
	end -- 389
	local uiScale = math.max( -- 391
		0.25, -- 391
		math.min(w / 1280, h / 720) -- 391
	) -- 391
	local uiW = w / uiScale -- 392
	local uiH = h / uiScale -- 393
	local rawX = useUiPtr and input.uiX or input.mx -- 394
	local rawY = useUiPtr and input.uiY or input.my -- 395
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 396
	local boxes = self.hud:talentCardRects( -- 397
		uiW, -- 397
		uiH, -- 397
		#offers, -- 397
		input:isTouchMode(), -- 397
		self.stageVp.safeUi.top -- 397
	) -- 397
	local i = 0 -- 398
	do -- 398
		i = 0 -- 399
		while i < #boxes do -- 399
			if boxes[i + 1]:containsPoint(pointer) then -- 400
				return p:chooseTalent(i) -- 401
			end -- 401
			i = i + 1 -- 399
		end -- 399
	end -- 399
	return false -- 404
end -- 378
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 408
	self:syncRuntimeHooks() -- 409
	self:setVisible(true) -- 410
	if self.boundPlay ~= p then -- 411
		self:bindPlay(p, w, h) -- 412
	end -- 412
	local safeDt = math.min( -- 414
		0.05, -- 414
		math.max(0.001, dt) -- 414
	) -- 414
	if self.toastTimer > 0 then -- 415
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 416
	end -- 416
	self.audio:setPaused(p.paused) -- 418
	local ev -- 420
	local worldDt = 0 -- 421
	local uiDt = 0 -- 422
	if not p.paused then -- 424
		ev = self.adapter:sample(p) -- 426
		self.vfx:ingest(ev, p, self.cam) -- 427
		self.audio:ingestEvents(ev, p) -- 428
		local touch = input:getTouch() -- 429
		if touch ~= nil then -- 430
			if ev.playerHit then -- 431
				touch:vibrate(0.036) -- 432
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 433
				touch:vibrate(0.024) -- 434
			elseif ev.coverDeflect then -- 435
				touch:vibrate(0.018) -- 436
			elseif ev.knockPulse then -- 437
				touch:vibrate(0.014) -- 438
			end -- 438
		end -- 438
	else -- 438
		ev = self.adapter:emptyFrame(p) -- 443
		self.narrative.wipeT = 0 -- 444
	end -- 444
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 447
	if not p.paused then -- 448
		local clampedScale = math.max( -- 449
			0, -- 449
			math.min(2, view.timeScale) -- 449
		) -- 449
		uiDt = safeDt -- 450
		worldDt = safeDt * clampedScale -- 451
	end -- 451
	local uiScale = self:resizeInterface(w, h) -- 454
	local uiW = w / uiScale -- 455
	local uiH = h / uiScale -- 456
	local ctx = { -- 458
		p = p, -- 459
		view = view, -- 460
		events = ev, -- 461
		input = input, -- 462
		cam = self.cam, -- 463
		audio = self.audio, -- 464
		assets = self.worldArt, -- 465
		backdropArt = self.backdropArt, -- 466
		worldArt = self.worldArt, -- 467
		uiArt = self.uiArt, -- 468
		texts = self.texts, -- 469
		worldDt = worldDt, -- 470
		uiDt = uiDt, -- 471
		w = w, -- 472
		h = h, -- 473
		uiW = uiW, -- 474
		uiH = uiH, -- 475
		uiScale = uiScale, -- 476
		safeUi = self.stageVp.safeUi, -- 477
		paused = p.paused -- 478
	} -- 478
	local i = 0 -- 482
	do -- 482
		i = 0 -- 483
		while i < #self.plugins do -- 483
			local pl = self.plugins[i + 1] -- 484
			if pl.update ~= nil then -- 485
				pl:update(ctx) -- 486
			end -- 486
			i = i + 1 -- 483
		end -- 483
	end -- 483
	if not p.paused then -- 490
		self.time = self.time + worldDt -- 491
		self.cam:update(worldDt, p, w, h) -- 492
		self.actors:update(worldDt, p) -- 493
		self.vfx:update( -- 494
			worldDt, -- 494
			themeOf(p.room.key).ambient -- 494
		) -- 494
		self.hud:update(safeDt, p) -- 495
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 496
	else -- 496
		self.cam:update(0, p, w, h) -- 498
	end -- 498
	self:clearAll() -- 501
	local backdropHandled = false -- 504
	do -- 504
		i = 0 -- 505
		while i < #self.plugins do -- 505
			local pl = self.plugins[i + 1] -- 506
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 507
				backdropHandled = true -- 508
			end -- 508
			i = i + 1 -- 505
		end -- 505
	end -- 505
	if not backdropHandled then -- 511
		self.stage:drawBackdrop( -- 512
			self.bgDraw, -- 512
			self.bgGlow, -- 512
			self.backdropArt, -- 512
			p, -- 512
			self.cam, -- 512
			self.time -- 512
		) -- 512
	end -- 512
	local worldHandled = false -- 516
	do -- 516
		i = 0 -- 517
		while i < #self.plugins do -- 517
			local pl = self.plugins[i + 1] -- 518
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 519
				worldHandled = true -- 520
			end -- 520
			i = i + 1 -- 517
		end -- 517
	end -- 517
	if not worldHandled then -- 523
		self.stage:drawPlayableWorld( -- 524
			self.fgDraw, -- 524
			self.fgGlow, -- 524
			self.worldArt, -- 524
			p, -- 524
			self.cam, -- 524
			self.time, -- 524
			self.occlusion, -- 524
			worldDt -- 524
		) -- 524
	end -- 524
	local propsHandled = false -- 528
	do -- 528
		i = 0 -- 529
		while i < #self.plugins do -- 529
			local pl = self.plugins[i + 1] -- 530
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 531
				propsHandled = true -- 532
			end -- 532
			i = i + 1 -- 529
		end -- 529
	end -- 529
	if not propsHandled then -- 535
		self.props:drawAll( -- 536
			self.fgDraw, -- 536
			self.fgGlow, -- 536
			self.worldArt, -- 536
			p, -- 536
			self.cam, -- 536
			self.time, -- 536
			self.occlusion, -- 536
			worldDt -- 536
		) -- 536
	end -- 536
	local suppressAllActors = view.visualMode == "museum" -- 540
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 541
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 545
	if not suppressAllActors then -- 553
		self.actors:drawAll( -- 554
			self.fgDraw, -- 554
			self.fgGlow, -- 554
			self.worldArt, -- 554
			p, -- 554
			self.cam, -- 554
			suppressPartner -- 554
		) -- 554
	end -- 554
	do -- 554
		i = 0 -- 556
		while i < #self.plugins do -- 556
			local pl = self.plugins[i + 1] -- 557
			if pl.drawActorsOverlay ~= nil then -- 558
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 559
			end -- 559
			i = i + 1 -- 556
		end -- 556
	end -- 556
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 564
	if view.visualMode == "pixel" then -- 567
		self.stage:drawForegroundFraming( -- 568
			self.fgDraw, -- 568
			w, -- 568
			h, -- 568
			p, -- 568
			self.cam -- 568
		) -- 568
	end -- 568
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 570
	local action = {type = "none"} -- 573
	if p.paused then -- 574
		action = self.menus:updateAndDrawPause( -- 575
			safeDt, -- 576
			input, -- 577
			self.uiDraw, -- 578
			self.uiInkDraw, -- 579
			self.uiArt, -- 580
			self.uiGlow, -- 581
			self.texts, -- 582
			uiW, -- 583
			uiH, -- 584
			uiScale, -- 585
			view.assistHintsEnabled, -- 586
			function() -- 587
				self.contract:toggleAssistHints() -- 588
			end, -- 587
			self.stageVp.safeUi -- 590
		) -- 590
	else -- 590
		local cutsceneHandled = false -- 594
		do -- 594
			i = 0 -- 595
			while i < #self.plugins do -- 595
				local pl = self.plugins[i + 1] -- 596
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 597
					self.uiDraw, -- 598
					self.uiInkDraw, -- 598
					self.uiArt, -- 598
					self.uiGlow, -- 598
					ctx -- 598
				) then -- 598
					cutsceneHandled = true -- 599
				end -- 599
				i = i + 1 -- 595
			end -- 595
		end -- 595
		if not cutsceneHandled then -- 603
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 604
			self.hud:draw( -- 605
				self.uiDraw, -- 606
				self.uiInkDraw, -- 607
				self.uiArt, -- 608
				self.uiGlow, -- 609
				self.texts, -- 610
				p, -- 611
				self.cam, -- 612
				self.vfx, -- 613
				self.narrative.letterbox, -- 614
				uiScale, -- 615
				view.assistHintsEnabled, -- 616
				true, -- 617
				input.inputMode, -- 618
				input.gamepadLayout, -- 619
				self.stageVp.safeUi, -- 620
				input.retryHoldProgress, -- 621
				touchOverlayVisible -- 622
			) -- 622
			self.narrative:draw( -- 624
				self.uiDraw, -- 625
				self.uiInkDraw, -- 626
				self.uiGlow, -- 627
				self.uiArt, -- 628
				self.texts, -- 629
				p, -- 630
				uiW, -- 631
				uiH, -- 632
				view.assistHintsEnabled, -- 633
				input.inputMode, -- 634
				input.gamepadLayout, -- 635
				self.stageVp.safeUi -- 636
			) -- 636
		end -- 636
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 640
		do -- 640
			i = 0 -- 641
			while i < #self.plugins do -- 641
				local pl = self.plugins[i + 1] -- 642
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 643
					self.uiDraw, -- 644
					self.uiInkDraw, -- 644
					self.uiArt, -- 644
					self.uiGlow, -- 644
					ctx -- 644
				) then -- 644
					suppressReticle = true -- 645
				end -- 645
				i = i + 1 -- 641
			end -- 641
		end -- 641
		if not suppressReticle then -- 648
			self.hud:drawReticleOverlay( -- 649
				self.uiInkDraw, -- 650
				self.uiArt, -- 651
				self.uiGlow, -- 652
				p, -- 653
				self.cam, -- 654
				self.vfx, -- 655
				self.narrative.letterbox, -- 656
				uiScale, -- 657
				input:isTouchMode() -- 658
			) -- 658
		end -- 658
		if view.isRehearsal then -- 663
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 664
			drawSilkVeil( -- 665
				self.uiDraw, -- 665
				self.uiArt, -- 665
				"rehearsal_tag_veil", -- 665
				uiW * 0.5, -- 665
				uiH - 22 - self.stageVp.safeUi.top, -- 665
				168, -- 665
				26, -- 665
				PALETTE.inkWarm, -- 665
				0.74, -- 665
				8 -- 665
			) -- 665
			self.texts:put( -- 666
				"xs", -- 666
				badgeText, -- 666
				uiW * 0.5, -- 666
				uiH - 22 - self.stageVp.safeUi.top, -- 666
				toColor(PALETTE.amberCore), -- 666
				0.5, -- 666
				0.5, -- 666
				"Center", -- 666
				1.2, -- 666
				0.92, -- 666
				0.08 -- 666
			) -- 666
		end -- 666
	end -- 666
	self:drawToast(uiW) -- 670
	self:finishFrame() -- 671
	return action -- 672
end -- 408
return ____exports -- 408
