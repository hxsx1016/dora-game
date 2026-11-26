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
	self:setVisible(true) -- 303
	self:clearAll() -- 304
	local uiScale = self:resizeInterface(w, h) -- 305
	local act = self.menus:updateAndDrawScreen( -- 306
		dt, -- 307
		self.screen, -- 308
		input, -- 309
		self.stage, -- 310
		self.bgDraw, -- 311
		self.bgGlow, -- 312
		self.backdropArt, -- 313
		self.uiArt, -- 314
		self.uiDraw, -- 315
		self.uiInkDraw, -- 316
		self.uiGlow, -- 317
		self.texts, -- 318
		w, -- 319
		h, -- 320
		uiScale -- 321
	) -- 321
	self:finishFrame() -- 323
	return act -- 324
end -- 301
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 328
	self:syncRuntimeHooks() -- 329
	self:setVisible(true) -- 330
	if self.boundPlay ~= p then -- 330
		self:bindPlay(p, w, h) -- 332
	end -- 332
	local safeDt = math.min( -- 334
		0.05, -- 334
		math.max(0.001, dt) -- 334
	) -- 334
	self.audio:setPaused(p.paused) -- 335
	local ev -- 337
	local worldDt = 0 -- 338
	local uiDt = 0 -- 339
	if not p.paused then -- 339
		ev = self.adapter:sample(p) -- 343
		self.vfx:ingest(ev, p, self.cam) -- 344
		self.audio:ingestEvents(ev, p) -- 345
	else -- 345
		ev = self.adapter:emptyFrame(p) -- 348
		self.narrative.wipeT = 0 -- 349
	end -- 349
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 352
	if not p.paused then -- 352
		local clampedScale = math.max( -- 354
			0, -- 354
			math.min(2, view.timeScale) -- 354
		) -- 354
		uiDt = safeDt -- 355
		worldDt = safeDt * clampedScale -- 356
	end -- 356
	local uiScale = self:resizeInterface(w, h) -- 359
	local uiW = w / uiScale -- 360
	local uiH = h / uiScale -- 361
	local ctx = { -- 363
		p = p, -- 364
		view = view, -- 365
		events = ev, -- 366
		input = input, -- 367
		cam = self.cam, -- 368
		audio = self.audio, -- 369
		assets = self.worldArt, -- 370
		backdropArt = self.backdropArt, -- 371
		worldArt = self.worldArt, -- 372
		uiArt = self.uiArt, -- 373
		texts = self.texts, -- 374
		worldDt = worldDt, -- 375
		uiDt = uiDt, -- 376
		w = w, -- 377
		h = h, -- 378
		uiW = uiW, -- 379
		uiH = uiH, -- 380
		uiScale = uiScale, -- 381
		paused = p.paused -- 382
	} -- 382
	local i = 0 -- 386
	do -- 386
		i = 0 -- 387
		while i < #self.plugins do -- 387
			local pl = self.plugins[i + 1] -- 388
			if pl.update ~= nil then -- 388
				pl:update(ctx) -- 390
			end -- 390
			i = i + 1 -- 387
		end -- 387
	end -- 387
	if not p.paused then -- 387
		self.time = self.time + worldDt -- 395
		self.cam:update(worldDt, p, w, h) -- 396
		self.actors:update(worldDt, p) -- 397
		self.vfx:update( -- 398
			worldDt, -- 398
			themeOf(p.room.key).ambient -- 398
		) -- 398
		self.hud:update(worldDt, p) -- 399
		self.narrative:update(worldDt, p) -- 400
	else -- 400
		self.cam:update(0, p, w, h) -- 402
	end -- 402
	self:clearAll() -- 405
	local backdropHandled = false -- 408
	do -- 408
		i = 0 -- 409
		while i < #self.plugins do -- 409
			local pl = self.plugins[i + 1] -- 410
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 410
				backdropHandled = true -- 412
			end -- 412
			i = i + 1 -- 409
		end -- 409
	end -- 409
	if not backdropHandled then -- 409
		self.stage:drawBackdrop( -- 416
			self.bgDraw, -- 416
			self.bgGlow, -- 416
			self.backdropArt, -- 416
			p, -- 416
			self.cam, -- 416
			self.time -- 416
		) -- 416
	end -- 416
	local worldHandled = false -- 420
	do -- 420
		i = 0 -- 421
		while i < #self.plugins do -- 421
			local pl = self.plugins[i + 1] -- 422
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 422
				worldHandled = true -- 424
			end -- 424
			i = i + 1 -- 421
		end -- 421
	end -- 421
	if not worldHandled then -- 421
		self.stage:drawPlayableWorld( -- 428
			self.fgDraw, -- 428
			self.fgGlow, -- 428
			self.worldArt, -- 428
			p, -- 428
			self.cam, -- 428
			self.time, -- 428
			self.occlusion, -- 428
			worldDt -- 428
		) -- 428
	end -- 428
	local propsHandled = false -- 432
	do -- 432
		i = 0 -- 433
		while i < #self.plugins do -- 433
			local pl = self.plugins[i + 1] -- 434
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 434
				propsHandled = true -- 436
			end -- 436
			i = i + 1 -- 433
		end -- 433
	end -- 433
	if not propsHandled then -- 433
		self.props:drawAll( -- 440
			self.fgDraw, -- 440
			self.fgGlow, -- 440
			self.worldArt, -- 440
			p, -- 440
			self.cam, -- 440
			self.time, -- 440
			self.occlusion, -- 440
			worldDt -- 440
		) -- 440
	end -- 440
	local suppressAllActors = view.visualMode == "museum" -- 444
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 445
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 449
	if not suppressAllActors then -- 449
		self.actors:drawAll( -- 458
			self.fgDraw, -- 458
			self.fgGlow, -- 458
			self.worldArt, -- 458
			p, -- 458
			self.cam, -- 458
			suppressPartner -- 458
		) -- 458
	end -- 458
	do -- 458
		i = 0 -- 460
		while i < #self.plugins do -- 460
			local pl = self.plugins[i + 1] -- 461
			if pl.drawActorsOverlay ~= nil then -- 461
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 463
			end -- 463
			i = i + 1 -- 460
		end -- 460
	end -- 460
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 468
	self.stage:drawForegroundFraming( -- 471
		self.fgDraw, -- 471
		w, -- 471
		h, -- 471
		p, -- 471
		self.cam -- 471
	) -- 471
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 472
	local action = {type = "none"} -- 475
	if p.paused then -- 475
		action = self.menus:updateAndDrawPause( -- 477
			safeDt, -- 478
			input, -- 479
			self.uiDraw, -- 480
			self.uiInkDraw, -- 481
			self.uiArt, -- 482
			self.uiGlow, -- 483
			self.texts, -- 484
			uiW, -- 485
			uiH, -- 486
			uiScale, -- 487
			view.assistHintsEnabled, -- 488
			function() -- 489
				self.contract:toggleAssistHints() -- 490
			end -- 489
		) -- 489
	else -- 489
		local cutsceneHandled = false -- 495
		do -- 495
			i = 0 -- 496
			while i < #self.plugins do -- 496
				local pl = self.plugins[i + 1] -- 497
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 497
					self.uiDraw, -- 499
					self.uiInkDraw, -- 499
					self.uiArt, -- 499
					self.uiGlow, -- 499
					ctx -- 499
				) then -- 499
					cutsceneHandled = true -- 500
				end -- 500
				i = i + 1 -- 496
			end -- 496
		end -- 496
		if not cutsceneHandled then -- 496
			self.hud:draw( -- 505
				self.uiDraw, -- 506
				self.uiInkDraw, -- 507
				self.uiArt, -- 508
				self.uiGlow, -- 509
				self.texts, -- 510
				p, -- 511
				self.cam, -- 512
				self.vfx, -- 513
				self.narrative.letterbox, -- 514
				uiScale, -- 515
				view.assistHintsEnabled, -- 516
				true -- 517
			) -- 517
			self.narrative:draw( -- 519
				self.uiDraw, -- 520
				self.uiInkDraw, -- 521
				self.uiGlow, -- 522
				self.uiArt, -- 523
				self.texts, -- 524
				p, -- 525
				uiW, -- 526
				uiH, -- 527
				view.assistHintsEnabled -- 528
			) -- 528
		end -- 528
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 532
		do -- 532
			i = 0 -- 533
			while i < #self.plugins do -- 533
				local pl = self.plugins[i + 1] -- 534
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 534
					self.uiDraw, -- 536
					self.uiInkDraw, -- 536
					self.uiArt, -- 536
					self.uiGlow, -- 536
					ctx -- 536
				) then -- 536
					suppressReticle = true -- 537
				end -- 537
				i = i + 1 -- 533
			end -- 533
		end -- 533
		if not suppressReticle then -- 533
			self.hud:drawReticleOverlay( -- 541
				self.uiInkDraw, -- 542
				self.uiArt, -- 543
				self.uiGlow, -- 544
				p, -- 545
				self.cam, -- 546
				self.vfx, -- 547
				self.narrative.letterbox, -- 548
				uiScale -- 549
			) -- 549
		end -- 549
		if view.isRehearsal then -- 549
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 555
			drawSilkVeil( -- 556
				self.uiDraw, -- 556
				self.uiArt, -- 556
				"rehearsal_tag_veil", -- 556
				uiW * 0.5, -- 556
				uiH - 22, -- 556
				168, -- 556
				26, -- 556
				PALETTE.inkWarm, -- 556
				0.74, -- 556
				8 -- 556
			) -- 556
			self.texts:put( -- 557
				"xs", -- 557
				badgeText, -- 557
				uiW * 0.5, -- 557
				uiH - 22, -- 557
				toColor(PALETTE.amberCore), -- 557
				0.5, -- 557
				0.5, -- 557
				"Center", -- 557
				1.2, -- 557
				0.92, -- 557
				0.08 -- 557
			) -- 557
		end -- 557
	end -- 557
	self:finishFrame() -- 561
	return action -- 562
end -- 328
return ____exports -- 328