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
local ____adapter = require("Script.watch.fe.adapter") -- 15
local PlayAdapter = ____adapter.PlayAdapter -- 15
local ____assets = require("Script.watch.fe.assets") -- 16
local AssetSlotHost = ____assets.AssetSlotHost -- 16
local ____audio = require("Script.watch.fe.audio") -- 17
local AudioDirector = ____audio.AudioDirector -- 17
local ____camera = require("Script.watch.fe.camera") -- 18
local CameraDirector = ____camera.CameraDirector -- 18
local ____contract = require("Script.watch.fe.contract") -- 19
local DualRouteContract = ____contract.DualRouteContract -- 19
local ____occlusion = require("Script.watch.fe.occlusion") -- 20
local DepthOcclusion = ____occlusion.DepthOcclusion -- 20
local ____stage = require("Script.watch.fe.renderer.stage") -- 22
local StageRenderer = ____stage.StageRenderer -- 22
local ____props = require("Script.watch.fe.renderer.props") -- 23
local PropsRenderer = ____props.PropsRenderer -- 23
local ____actors = require("Script.watch.fe.renderer.actors") -- 24
local ActorsRenderer = ____actors.ActorsRenderer -- 24
local ____vfx = require("Script.watch.fe.renderer.vfx") -- 25
local VfxSystem = ____vfx.VfxSystem -- 25
local ____textpool = require("Script.watch.fe.ui.textpool") -- 26
local TextPool = ____textpool.TextPool -- 26
local ____hud = require("Script.watch.fe.ui.hud") -- 27
local HudRenderer = ____hud.HudRenderer -- 27
local ____narrative = require("Script.watch.fe.ui.narrative") -- 28
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 28
local ____menus = require("Script.watch.fe.ui.menus") -- 29
local MenuRenderer = ____menus.MenuRenderer -- 29
local ____theme = require("Script.watch.fe.theme") -- 30
local PALETTE = ____theme.PALETTE -- 30
local drawSilkVeil = ____theme.drawSilkVeil -- 30
local themeOf = ____theme.themeOf -- 30
local toColor = ____theme.toColor -- 30
local ____ming_audit = require("Script.watch.fe.renderer.ming_audit") -- 31
local MingArtAuditPlugin = ____ming_audit.MingArtAuditPlugin -- 31
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 32
local GateTransitionPlugin = ____gate_transition.GateTransitionPlugin -- 32
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 33
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 33
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 34
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 34
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 35
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 35
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 36
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 36
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 37
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 37
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 38
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 38
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 39
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 39
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 40
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 40
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 41
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 41
____exports.WatchFrontend = __TS__Class() -- 43
local WatchFrontend = ____exports.WatchFrontend -- 43
WatchFrontend.name = "WatchFrontend" -- 43
function WatchFrontend.prototype.____constructor(self, parent) -- 77
	self.occlusion = __TS__New(DepthOcclusion) -- 44
	self.cam = __TS__New(CameraDirector) -- 59
	self.adapter = __TS__New(PlayAdapter) -- 60
	self.contract = __TS__New(DualRouteContract) -- 61
	self.audio = __TS__New(AudioDirector) -- 62
	self.stage = __TS__New(StageRenderer) -- 63
	self.props = __TS__New(PropsRenderer) -- 64
	self.actors = __TS__New(ActorsRenderer) -- 65
	self.vfx = __TS__New(VfxSystem) -- 66
	self.hud = __TS__New(HudRenderer) -- 67
	self.narrative = __TS__New(NarrativeRenderer) -- 68
	self.menus = __TS__New(MenuRenderer) -- 69
	self.plugins = {} -- 71
	self.screen = "title" -- 73
	self.time = 0 -- 74
	self.layerRoot = Node() -- 78
	self.layerRoot.order = 5 -- 79
	self.layerRoot:addTo(parent) -- 80
	self.audio:attachHost(self.layerRoot) -- 82
	local additive = BlendFunc("SrcAlpha", "One") -- 84
	self.bgDraw = DrawNode() -- 86
	self.bgDraw.order = 10 -- 87
	self.bgDraw:addTo(self.layerRoot) -- 88
	self.bgGlow = DrawNode() -- 90
	self.bgGlow.order = 15 -- 91
	self.bgGlow.blendFunc = additive -- 92
	self.bgGlow:addTo(self.layerRoot) -- 93
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 95
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 96
	self.fgDraw = DrawNode() -- 98
	self.fgDraw.order = 30 -- 99
	self.fgDraw:addTo(self.layerRoot) -- 100
	self.fgGlow = DrawNode() -- 102
	self.fgGlow.order = 35 -- 103
	self.fgGlow.blendFunc = additive -- 104
	self.fgGlow:addTo(self.layerRoot) -- 105
	self.uiLayer = Node() -- 107
	self.uiLayer.order = 40 -- 108
	self.uiLayer:addTo(self.layerRoot) -- 109
	self.uiDraw = DrawNode() -- 111
	self.uiDraw.order = 0 -- 112
	self.uiDraw:addTo(self.uiLayer) -- 113
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 115
	self.uiInkDraw = DrawNode() -- 117
	self.uiInkDraw.order = 4 -- 118
	self.uiInkDraw:addTo(self.uiLayer) -- 119
	self.uiGlow = DrawNode() -- 121
	self.uiGlow.order = 6 -- 122
	self.uiGlow.blendFunc = additive -- 123
	self.uiGlow:addTo(self.uiLayer) -- 124
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 126
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 140
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 141
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 142
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 143
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 144
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 145
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 146
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 147
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 148
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 149
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 150
end -- 77
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 154
	local i = 0 -- 155
	do -- 155
		i = 0 -- 156
		while i < #self.plugins do -- 156
			if self.plugins[i + 1].id == plugin.id then -- 156
				self.plugins[i + 1] = plugin -- 158
				self:syncRuntimeHooks() -- 159
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 159
					plugin:onBindPlay( -- 161
						self.boundPlay, -- 161
						self.contract:peekSnapshot(self.boundPlay) -- 161
					) -- 161
				end -- 161
				return -- 163
			end -- 163
			i = i + 1 -- 156
		end -- 156
	end -- 156
	local ____self_plugins_0 = self.plugins -- 156
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 166
	self:syncRuntimeHooks() -- 167
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 167
		plugin:onBindPlay( -- 169
			self.boundPlay, -- 169
			self.contract:peekSnapshot(self.boundPlay) -- 169
		) -- 169
	end -- 169
end -- 154
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 174
	local w = 0 -- 175
	local i = 0 -- 176
	do -- 176
		i = 0 -- 177
		while i < #self.plugins do -- 177
			if self.plugins[i + 1].id ~= id then -- 177
				self.plugins[w + 1] = self.plugins[i + 1] -- 179
				w = w + 1 -- 180
			end -- 180
			i = i + 1 -- 177
		end -- 177
	end -- 177
	__TS__ArraySetLength(self.plugins, w) -- 177
	self:syncRuntimeHooks() -- 184
end -- 174
function WatchFrontend.prototype.getPlugin(self, id) -- 188
	local i = 0 -- 189
	do -- 189
		i = 0 -- 190
		while i < #self.plugins do -- 190
			if self.plugins[i + 1].id == id then -- 190
				return self.plugins[i + 1] -- 192
			end -- 192
			i = i + 1 -- 190
		end -- 190
	end -- 190
	return nil -- 195
end -- 188
function WatchFrontend.prototype.getPlugins(self) -- 198
	return self.plugins -- 199
end -- 198
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 207
	local g = _G -- 208
	local ____temp_1 -- 209
	if g.package ~= nil then -- 209
		____temp_1 = g.package.loaded -- 209
	else -- 209
		____temp_1 = nil -- 209
	end -- 209
	local loaded = ____temp_1 -- 209
	if loaded == nil then -- 209
		return -- 211
	end -- 211
	local rawFe = loaded["watch.fe"] -- 213
	if rawFe ~= nil and type(rawFe) == "table" then -- 213
		local watchFe = rawFe -- 215
		if watchFe.contract ~= self.contract then -- 215
			watchFe.contract = self.contract -- 217
			watchFe.audio = self.audio -- 218
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 219
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 220
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 221
		end -- 221
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 223
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 224
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 225
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 226
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 227
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 228
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 229
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 230
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 231
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 232
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 233
	end -- 233
end -- 207
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 237
	local scale = math.max( -- 238
		0.25, -- 238
		math.min(w / 1280, h / 720) -- 238
	) -- 238
	self.uiLayer.scaleX = scale -- 239
	self.uiLayer.scaleY = scale -- 240
	return scale -- 241
end -- 237
function WatchFrontend.prototype.setVisible(self, v) -- 245
	self.layerRoot.visible = v -- 246
	if not v then -- 246
		self.texts:hideAll() -- 248
	end -- 248
end -- 245
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 253
	self:syncRuntimeHooks() -- 254
	self.boundPlay = p -- 255
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 256
	self.cam:snap(p, w, h) -- 257
	self.adapter:reset(p) -- 258
	self.contract:resetForRoom(p) -- 259
	self.audio:stopRoomTransient() -- 260
	self.actors:reset(p) -- 261
	self.occlusion:reset() -- 262
	self.vfx:reset() -- 263
	self.hud:reset(p) -- 264
	self.narrative:onEnterRoom(p.room.key) -- 265
	if #self.plugins > 0 then -- 265
		local initView = self.contract:peekSnapshot(p) -- 268
		local i = 0 -- 269
		do -- 269
			i = 0 -- 270
			while i < #self.plugins do -- 270
				local pl = self.plugins[i + 1] -- 271
				if pl.onBindPlay ~= nil then -- 271
					pl:onBindPlay(p, initView) -- 273
				end -- 273
				i = i + 1 -- 270
			end -- 270
		end -- 270
	end -- 270
end -- 253
function WatchFrontend.prototype.clearAll(self) -- 279
	self.bgDraw:clear() -- 280
	self.bgGlow:clear() -- 281
	self.fgDraw:clear() -- 282
	self.fgGlow:clear() -- 283
	self.uiDraw:clear() -- 284
	self.uiInkDraw:clear() -- 285
	self.uiGlow:clear() -- 286
	self.backdropArt:beginFrame() -- 287
	self.worldArt:beginFrame() -- 288
	self.uiArt:beginFrame() -- 289
	self.texts:beginFrame() -- 290
end -- 279
function WatchFrontend.prototype.finishFrame(self) -- 293
	self.backdropArt:endFrame() -- 294
	self.worldArt:endFrame() -- 295
	self.uiArt:endFrame() -- 296
	self.texts:endFrame() -- 297
end -- 293
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 301
	self:syncRuntimeHooks() -- 302
	if self.screen == "title" and self.boundPlay ~= nil then -- 302
		self.audio:stopRoomTransient() -- 304
		self.boundPlay = nil -- 305
	end -- 305
	self:setVisible(true) -- 307
	self:clearAll() -- 308
	local uiScale = self:resizeInterface(w, h) -- 309
	local act = self.menus:updateAndDrawScreen( -- 310
		dt, -- 311
		self.screen, -- 312
		input, -- 313
		self.stage, -- 314
		self.bgDraw, -- 315
		self.bgGlow, -- 316
		self.backdropArt, -- 317
		self.uiArt, -- 318
		self.uiDraw, -- 319
		self.uiInkDraw, -- 320
		self.uiGlow, -- 321
		self.texts, -- 322
		w, -- 323
		h, -- 324
		uiScale -- 325
	) -- 325
	self:finishFrame() -- 327
	return act -- 328
end -- 301
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 332
	self:syncRuntimeHooks() -- 333
	self:setVisible(true) -- 334
	if self.boundPlay ~= p then -- 334
		self:bindPlay(p, w, h) -- 336
	end -- 336
	local safeDt = math.min( -- 338
		0.05, -- 338
		math.max(0.001, dt) -- 338
	) -- 338
	self.audio:setPaused(p.paused) -- 339
	local ev -- 341
	local worldDt = 0 -- 342
	local uiDt = 0 -- 343
	if not p.paused then -- 343
		ev = self.adapter:sample(p) -- 347
		self.vfx:ingest(ev, p, self.cam) -- 348
		self.audio:ingestEvents(ev, p) -- 349
	else -- 349
		ev = self.adapter:emptyFrame(p) -- 352
		self.narrative.wipeT = 0 -- 353
	end -- 353
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 356
	if not p.paused then -- 356
		local clampedScale = math.max( -- 358
			0, -- 358
			math.min(2, view.timeScale) -- 358
		) -- 358
		uiDt = safeDt -- 359
		worldDt = safeDt * clampedScale -- 360
	end -- 360
	local uiScale = self:resizeInterface(w, h) -- 363
	local uiW = w / uiScale -- 364
	local uiH = h / uiScale -- 365
	local ctx = { -- 367
		p = p, -- 368
		view = view, -- 369
		events = ev, -- 370
		input = input, -- 371
		cam = self.cam, -- 372
		audio = self.audio, -- 373
		assets = self.worldArt, -- 374
		backdropArt = self.backdropArt, -- 375
		worldArt = self.worldArt, -- 376
		uiArt = self.uiArt, -- 377
		texts = self.texts, -- 378
		worldDt = worldDt, -- 379
		uiDt = uiDt, -- 380
		w = w, -- 381
		h = h, -- 382
		uiW = uiW, -- 383
		uiH = uiH, -- 384
		uiScale = uiScale, -- 385
		paused = p.paused -- 386
	} -- 386
	local i = 0 -- 390
	do -- 390
		i = 0 -- 391
		while i < #self.plugins do -- 391
			local pl = self.plugins[i + 1] -- 392
			if pl.update ~= nil then -- 392
				pl:update(ctx) -- 394
			end -- 394
			i = i + 1 -- 391
		end -- 391
	end -- 391
	if not p.paused then -- 391
		self.time = self.time + worldDt -- 399
		self.cam:update(worldDt, p, w, h) -- 400
		self.actors:update(worldDt, p) -- 401
		self.vfx:update( -- 402
			worldDt, -- 402
			themeOf(p.room.key).ambient -- 402
		) -- 402
		self.hud:update(worldDt, p) -- 403
		self.narrative:update(worldDt, p) -- 404
	else -- 404
		self.cam:update(0, p, w, h) -- 406
	end -- 406
	self:clearAll() -- 409
	local backdropHandled = false -- 412
	do -- 412
		i = 0 -- 413
		while i < #self.plugins do -- 413
			local pl = self.plugins[i + 1] -- 414
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 414
				backdropHandled = true -- 416
			end -- 416
			i = i + 1 -- 413
		end -- 413
	end -- 413
	if not backdropHandled then -- 413
		self.stage:drawBackdrop( -- 420
			self.bgDraw, -- 420
			self.bgGlow, -- 420
			self.backdropArt, -- 420
			p, -- 420
			self.cam, -- 420
			self.time -- 420
		) -- 420
	end -- 420
	local worldHandled = false -- 424
	do -- 424
		i = 0 -- 425
		while i < #self.plugins do -- 425
			local pl = self.plugins[i + 1] -- 426
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 426
				worldHandled = true -- 428
			end -- 428
			i = i + 1 -- 425
		end -- 425
	end -- 425
	if not worldHandled then -- 425
		self.stage:drawPlayableWorld( -- 432
			self.fgDraw, -- 432
			self.fgGlow, -- 432
			self.worldArt, -- 432
			p, -- 432
			self.cam, -- 432
			self.time, -- 432
			self.occlusion, -- 432
			worldDt -- 432
		) -- 432
	end -- 432
	local propsHandled = false -- 436
	do -- 436
		i = 0 -- 437
		while i < #self.plugins do -- 437
			local pl = self.plugins[i + 1] -- 438
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 438
				propsHandled = true -- 440
			end -- 440
			i = i + 1 -- 437
		end -- 437
	end -- 437
	if not propsHandled then -- 437
		self.props:drawAll( -- 444
			self.fgDraw, -- 444
			self.fgGlow, -- 444
			self.worldArt, -- 444
			p, -- 444
			self.cam, -- 444
			self.time, -- 444
			self.occlusion, -- 444
			worldDt -- 444
		) -- 444
	end -- 444
	local suppressAllActors = view.visualMode == "museum" -- 448
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 449
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 453
	if not suppressAllActors then -- 453
		self.actors:drawAll( -- 462
			self.fgDraw, -- 462
			self.fgGlow, -- 462
			self.worldArt, -- 462
			p, -- 462
			self.cam, -- 462
			suppressPartner -- 462
		) -- 462
	end -- 462
	do -- 462
		i = 0 -- 464
		while i < #self.plugins do -- 464
			local pl = self.plugins[i + 1] -- 465
			if pl.drawActorsOverlay ~= nil then -- 465
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 467
			end -- 467
			i = i + 1 -- 464
		end -- 464
	end -- 464
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 472
	self.stage:drawForegroundFraming( -- 475
		self.fgDraw, -- 475
		w, -- 475
		h, -- 475
		p, -- 475
		self.cam -- 475
	) -- 475
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 476
	local action = {type = "none"} -- 479
	if p.paused then -- 479
		action = self.menus:updateAndDrawPause( -- 481
			safeDt, -- 482
			input, -- 483
			self.uiDraw, -- 484
			self.uiInkDraw, -- 485
			self.uiArt, -- 486
			self.uiGlow, -- 487
			self.texts, -- 488
			uiW, -- 489
			uiH, -- 490
			uiScale, -- 491
			view.assistHintsEnabled, -- 492
			function() -- 493
				self.contract:toggleAssistHints() -- 494
			end -- 493
		) -- 493
	else -- 493
		local cutsceneHandled = false -- 499
		do -- 499
			i = 0 -- 500
			while i < #self.plugins do -- 500
				local pl = self.plugins[i + 1] -- 501
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 501
					self.uiDraw, -- 503
					self.uiInkDraw, -- 503
					self.uiArt, -- 503
					self.uiGlow, -- 503
					ctx -- 503
				) then -- 503
					cutsceneHandled = true -- 504
				end -- 504
				i = i + 1 -- 500
			end -- 500
		end -- 500
		if not cutsceneHandled then -- 500
			self.hud:draw( -- 509
				self.uiDraw, -- 510
				self.uiInkDraw, -- 511
				self.uiArt, -- 512
				self.uiGlow, -- 513
				self.texts, -- 514
				p, -- 515
				self.cam, -- 516
				self.vfx, -- 517
				self.narrative.letterbox, -- 518
				uiScale, -- 519
				view.assistHintsEnabled, -- 520
				true -- 521
			) -- 521
			self.narrative:draw( -- 523
				self.uiDraw, -- 524
				self.uiInkDraw, -- 525
				self.uiGlow, -- 526
				self.uiArt, -- 527
				self.texts, -- 528
				p, -- 529
				uiW, -- 530
				uiH, -- 531
				view.assistHintsEnabled -- 532
			) -- 532
		end -- 532
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 536
		do -- 536
			i = 0 -- 537
			while i < #self.plugins do -- 537
				local pl = self.plugins[i + 1] -- 538
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 538
					self.uiDraw, -- 540
					self.uiInkDraw, -- 540
					self.uiArt, -- 540
					self.uiGlow, -- 540
					ctx -- 540
				) then -- 540
					suppressReticle = true -- 541
				end -- 541
				i = i + 1 -- 537
			end -- 537
		end -- 537
		if not suppressReticle then -- 537
			self.hud:drawReticleOverlay( -- 545
				self.uiInkDraw, -- 546
				self.uiArt, -- 547
				self.uiGlow, -- 548
				p, -- 549
				self.cam, -- 550
				self.vfx, -- 551
				self.narrative.letterbox, -- 552
				uiScale -- 553
			) -- 553
		end -- 553
		if view.isRehearsal then -- 553
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 559
			drawSilkVeil( -- 560
				self.uiDraw, -- 560
				self.uiArt, -- 560
				"rehearsal_tag_veil", -- 560
				uiW * 0.5, -- 560
				uiH - 22, -- 560
				168, -- 560
				26, -- 560
				PALETTE.inkWarm, -- 560
				0.74, -- 560
				8 -- 560
			) -- 560
			self.texts:put( -- 561
				"xs", -- 561
				badgeText, -- 561
				uiW * 0.5, -- 561
				uiH - 22, -- 561
				toColor(PALETTE.amberCore), -- 561
				0.5, -- 561
				0.5, -- 561
				"Center", -- 561
				1.2, -- 561
				0.92, -- 561
				0.08 -- 561
			) -- 561
		end -- 561
	end -- 561
	self:finishFrame() -- 565
	return action -- 566
end -- 332
return ____exports -- 332