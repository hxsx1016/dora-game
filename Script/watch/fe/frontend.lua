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
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 332
	local offers = p:getStoryTalentOffers() -- 333
	if #offers == 0 or not input.inside then -- 333
		return false -- 335
	end -- 335
	local uiScale = math.max( -- 337
		0.25, -- 337
		math.min(w / 1280, h / 720) -- 337
	) -- 337
	local uiW = w / uiScale -- 338
	local uiH = h / uiScale -- 339
	local pointer = Vec2(input.mx / uiScale, input.my / uiScale) -- 340
	local boxes = self.hud:talentCardRects(uiW, uiH, #offers) -- 341
	local i = 0 -- 342
	do -- 342
		i = 0 -- 343
		while i < #boxes do -- 343
			if boxes[i + 1]:containsPoint(pointer) then -- 343
				return p:chooseTalent(i) -- 345
			end -- 345
			i = i + 1 -- 343
		end -- 343
	end -- 343
	return false -- 348
end -- 332
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 352
	self:syncRuntimeHooks() -- 353
	self:setVisible(true) -- 354
	if self.boundPlay ~= p then -- 354
		self:bindPlay(p, w, h) -- 356
	end -- 356
	local safeDt = math.min( -- 358
		0.05, -- 358
		math.max(0.001, dt) -- 358
	) -- 358
	self.audio:setPaused(p.paused) -- 359
	local ev -- 361
	local worldDt = 0 -- 362
	local uiDt = 0 -- 363
	if not p.paused then -- 363
		ev = self.adapter:sample(p) -- 367
		self.vfx:ingest(ev, p, self.cam) -- 368
		self.audio:ingestEvents(ev, p) -- 369
	else -- 369
		ev = self.adapter:emptyFrame(p) -- 372
		self.narrative.wipeT = 0 -- 373
	end -- 373
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 376
	if not p.paused then -- 376
		local clampedScale = math.max( -- 378
			0, -- 378
			math.min(2, view.timeScale) -- 378
		) -- 378
		uiDt = safeDt -- 379
		worldDt = safeDt * clampedScale -- 380
	end -- 380
	local uiScale = self:resizeInterface(w, h) -- 383
	local uiW = w / uiScale -- 384
	local uiH = h / uiScale -- 385
	local ctx = { -- 387
		p = p, -- 388
		view = view, -- 389
		events = ev, -- 390
		input = input, -- 391
		cam = self.cam, -- 392
		audio = self.audio, -- 393
		assets = self.worldArt, -- 394
		backdropArt = self.backdropArt, -- 395
		worldArt = self.worldArt, -- 396
		uiArt = self.uiArt, -- 397
		texts = self.texts, -- 398
		worldDt = worldDt, -- 399
		uiDt = uiDt, -- 400
		w = w, -- 401
		h = h, -- 402
		uiW = uiW, -- 403
		uiH = uiH, -- 404
		uiScale = uiScale, -- 405
		paused = p.paused -- 406
	} -- 406
	local i = 0 -- 410
	do -- 410
		i = 0 -- 411
		while i < #self.plugins do -- 411
			local pl = self.plugins[i + 1] -- 412
			if pl.update ~= nil then -- 412
				pl:update(ctx) -- 414
			end -- 414
			i = i + 1 -- 411
		end -- 411
	end -- 411
	if not p.paused then -- 411
		self.time = self.time + worldDt -- 419
		self.cam:update(worldDt, p, w, h) -- 420
		self.actors:update(worldDt, p) -- 421
		self.vfx:update( -- 422
			worldDt, -- 422
			themeOf(p.room.key).ambient -- 422
		) -- 422
		self.hud:update(worldDt, p) -- 423
		self.narrative:update(worldDt, p) -- 424
	else -- 424
		self.cam:update(0, p, w, h) -- 426
	end -- 426
	self:clearAll() -- 429
	local backdropHandled = false -- 432
	do -- 432
		i = 0 -- 433
		while i < #self.plugins do -- 433
			local pl = self.plugins[i + 1] -- 434
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 434
				backdropHandled = true -- 436
			end -- 436
			i = i + 1 -- 433
		end -- 433
	end -- 433
	if not backdropHandled then -- 433
		self.stage:drawBackdrop( -- 440
			self.bgDraw, -- 440
			self.bgGlow, -- 440
			self.backdropArt, -- 440
			p, -- 440
			self.cam, -- 440
			self.time -- 440
		) -- 440
	end -- 440
	local worldHandled = false -- 444
	do -- 444
		i = 0 -- 445
		while i < #self.plugins do -- 445
			local pl = self.plugins[i + 1] -- 446
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 446
				worldHandled = true -- 448
			end -- 448
			i = i + 1 -- 445
		end -- 445
	end -- 445
	if not worldHandled then -- 445
		self.stage:drawPlayableWorld( -- 452
			self.fgDraw, -- 452
			self.fgGlow, -- 452
			self.worldArt, -- 452
			p, -- 452
			self.cam, -- 452
			self.time, -- 452
			self.occlusion, -- 452
			worldDt -- 452
		) -- 452
	end -- 452
	local propsHandled = false -- 456
	do -- 456
		i = 0 -- 457
		while i < #self.plugins do -- 457
			local pl = self.plugins[i + 1] -- 458
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 458
				propsHandled = true -- 460
			end -- 460
			i = i + 1 -- 457
		end -- 457
	end -- 457
	if not propsHandled then -- 457
		self.props:drawAll( -- 464
			self.fgDraw, -- 464
			self.fgGlow, -- 464
			self.worldArt, -- 464
			p, -- 464
			self.cam, -- 464
			self.time, -- 464
			self.occlusion, -- 464
			worldDt -- 464
		) -- 464
	end -- 464
	local suppressAllActors = view.visualMode == "museum" -- 468
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 469
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 473
	if not suppressAllActors then -- 473
		self.actors:drawAll( -- 482
			self.fgDraw, -- 482
			self.fgGlow, -- 482
			self.worldArt, -- 482
			p, -- 482
			self.cam, -- 482
			suppressPartner -- 482
		) -- 482
	end -- 482
	do -- 482
		i = 0 -- 484
		while i < #self.plugins do -- 484
			local pl = self.plugins[i + 1] -- 485
			if pl.drawActorsOverlay ~= nil then -- 485
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 487
			end -- 487
			i = i + 1 -- 484
		end -- 484
	end -- 484
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 492
	self.stage:drawForegroundFraming( -- 495
		self.fgDraw, -- 495
		w, -- 495
		h, -- 495
		p, -- 495
		self.cam -- 495
	) -- 495
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 496
	local action = {type = "none"} -- 499
	if p.paused then -- 499
		action = self.menus:updateAndDrawPause( -- 501
			safeDt, -- 502
			input, -- 503
			self.uiDraw, -- 504
			self.uiInkDraw, -- 505
			self.uiArt, -- 506
			self.uiGlow, -- 507
			self.texts, -- 508
			uiW, -- 509
			uiH, -- 510
			uiScale, -- 511
			view.assistHintsEnabled, -- 512
			function() -- 513
				self.contract:toggleAssistHints() -- 514
			end -- 513
		) -- 513
	else -- 513
		local cutsceneHandled = false -- 519
		do -- 519
			i = 0 -- 520
			while i < #self.plugins do -- 520
				local pl = self.plugins[i + 1] -- 521
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 521
					self.uiDraw, -- 523
					self.uiInkDraw, -- 523
					self.uiArt, -- 523
					self.uiGlow, -- 523
					ctx -- 523
				) then -- 523
					cutsceneHandled = true -- 524
				end -- 524
				i = i + 1 -- 520
			end -- 520
		end -- 520
		if not cutsceneHandled then -- 520
			self.hud:draw( -- 529
				self.uiDraw, -- 530
				self.uiInkDraw, -- 531
				self.uiArt, -- 532
				self.uiGlow, -- 533
				self.texts, -- 534
				p, -- 535
				self.cam, -- 536
				self.vfx, -- 537
				self.narrative.letterbox, -- 538
				uiScale, -- 539
				view.assistHintsEnabled, -- 540
				true -- 541
			) -- 541
			self.narrative:draw( -- 543
				self.uiDraw, -- 544
				self.uiInkDraw, -- 545
				self.uiGlow, -- 546
				self.uiArt, -- 547
				self.texts, -- 548
				p, -- 549
				uiW, -- 550
				uiH, -- 551
				view.assistHintsEnabled -- 552
			) -- 552
		end -- 552
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 556
		do -- 556
			i = 0 -- 557
			while i < #self.plugins do -- 557
				local pl = self.plugins[i + 1] -- 558
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 558
					self.uiDraw, -- 560
					self.uiInkDraw, -- 560
					self.uiArt, -- 560
					self.uiGlow, -- 560
					ctx -- 560
				) then -- 560
					suppressReticle = true -- 561
				end -- 561
				i = i + 1 -- 557
			end -- 557
		end -- 557
		if not suppressReticle then -- 557
			self.hud:drawReticleOverlay( -- 565
				self.uiInkDraw, -- 566
				self.uiArt, -- 567
				self.uiGlow, -- 568
				p, -- 569
				self.cam, -- 570
				self.vfx, -- 571
				self.narrative.letterbox, -- 572
				uiScale -- 573
			) -- 573
		end -- 573
		if view.isRehearsal then -- 573
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 579
			drawSilkVeil( -- 580
				self.uiDraw, -- 580
				self.uiArt, -- 580
				"rehearsal_tag_veil", -- 580
				uiW * 0.5, -- 580
				uiH - 22, -- 580
				168, -- 580
				26, -- 580
				PALETTE.inkWarm, -- 580
				0.74, -- 580
				8 -- 580
			) -- 580
			self.texts:put( -- 581
				"xs", -- 581
				badgeText, -- 581
				uiW * 0.5, -- 581
				uiH - 22, -- 581
				toColor(PALETTE.amberCore), -- 581
				0.5, -- 581
				0.5, -- 581
				"Center", -- 581
				1.2, -- 581
				0.92, -- 581
				0.08 -- 581
			) -- 581
		end -- 581
	end -- 581
	self:finishFrame() -- 585
	return action -- 586
end -- 352
return ____exports -- 352