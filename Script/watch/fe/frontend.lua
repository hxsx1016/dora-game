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
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 33
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 33
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 34
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 34
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 35
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 35
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 36
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 36
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 37
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 37
____exports.WatchFrontend = __TS__Class() -- 39
local WatchFrontend = ____exports.WatchFrontend -- 39
WatchFrontend.name = "WatchFrontend" -- 39
function WatchFrontend.prototype.____constructor(self, parent) -- 73
	self.occlusion = __TS__New(DepthOcclusion) -- 40
	self.cam = __TS__New(CameraDirector) -- 55
	self.adapter = __TS__New(PlayAdapter) -- 56
	self.contract = __TS__New(DualRouteContract) -- 57
	self.audio = __TS__New(AudioDirector) -- 58
	self.stage = __TS__New(StageRenderer) -- 59
	self.props = __TS__New(PropsRenderer) -- 60
	self.actors = __TS__New(ActorsRenderer) -- 61
	self.vfx = __TS__New(VfxSystem) -- 62
	self.hud = __TS__New(HudRenderer) -- 63
	self.narrative = __TS__New(NarrativeRenderer) -- 64
	self.menus = __TS__New(MenuRenderer) -- 65
	self.plugins = {} -- 67
	self.screen = "title" -- 69
	self.time = 0 -- 70
	self.layerRoot = Node() -- 74
	self.layerRoot.order = 5 -- 75
	self.layerRoot:addTo(parent) -- 76
	self.audio:attachHost(self.layerRoot) -- 78
	local additive = BlendFunc("SrcAlpha", "One") -- 80
	self.bgDraw = DrawNode() -- 82
	self.bgDraw.order = 10 -- 83
	self.bgDraw:addTo(self.layerRoot) -- 84
	self.bgGlow = DrawNode() -- 86
	self.bgGlow.order = 15 -- 87
	self.bgGlow.blendFunc = additive -- 88
	self.bgGlow:addTo(self.layerRoot) -- 89
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 91
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 92
	self.fgDraw = DrawNode() -- 94
	self.fgDraw.order = 30 -- 95
	self.fgDraw:addTo(self.layerRoot) -- 96
	self.fgGlow = DrawNode() -- 98
	self.fgGlow.order = 35 -- 99
	self.fgGlow.blendFunc = additive -- 100
	self.fgGlow:addTo(self.layerRoot) -- 101
	self.uiLayer = Node() -- 103
	self.uiLayer.order = 40 -- 104
	self.uiLayer:addTo(self.layerRoot) -- 105
	self.uiDraw = DrawNode() -- 107
	self.uiDraw.order = 0 -- 108
	self.uiDraw:addTo(self.uiLayer) -- 109
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 111
	self.uiInkDraw = DrawNode() -- 113
	self.uiInkDraw.order = 4 -- 114
	self.uiInkDraw:addTo(self.uiLayer) -- 115
	self.uiGlow = DrawNode() -- 117
	self.uiGlow.order = 6 -- 118
	self.uiGlow.blendFunc = additive -- 119
	self.uiGlow:addTo(self.uiLayer) -- 120
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 122
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 132
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 133
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 134
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 135
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 136
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 137
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 138
end -- 73
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 142
	local i = 0 -- 143
	do -- 143
		i = 0 -- 144
		while i < #self.plugins do -- 144
			if self.plugins[i + 1].id == plugin.id then -- 144
				self.plugins[i + 1] = plugin -- 146
				self:syncRuntimeHooks() -- 147
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 147
					plugin:onBindPlay( -- 149
						self.boundPlay, -- 149
						self.contract:peekSnapshot(self.boundPlay) -- 149
					) -- 149
				end -- 149
				return -- 151
			end -- 151
			i = i + 1 -- 144
		end -- 144
	end -- 144
	local ____self_plugins_0 = self.plugins -- 144
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 154
	self:syncRuntimeHooks() -- 155
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 155
		plugin:onBindPlay( -- 157
			self.boundPlay, -- 157
			self.contract:peekSnapshot(self.boundPlay) -- 157
		) -- 157
	end -- 157
end -- 142
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 162
	local w = 0 -- 163
	local i = 0 -- 164
	do -- 164
		i = 0 -- 165
		while i < #self.plugins do -- 165
			if self.plugins[i + 1].id ~= id then -- 165
				self.plugins[w + 1] = self.plugins[i + 1] -- 167
				w = w + 1 -- 168
			end -- 168
			i = i + 1 -- 165
		end -- 165
	end -- 165
	__TS__ArraySetLength(self.plugins, w) -- 165
	self:syncRuntimeHooks() -- 172
end -- 162
function WatchFrontend.prototype.getPlugin(self, id) -- 176
	local i = 0 -- 177
	do -- 177
		i = 0 -- 178
		while i < #self.plugins do -- 178
			if self.plugins[i + 1].id == id then -- 178
				return self.plugins[i + 1] -- 180
			end -- 180
			i = i + 1 -- 178
		end -- 178
	end -- 178
	return nil -- 183
end -- 176
function WatchFrontend.prototype.getPlugins(self) -- 186
	return self.plugins -- 187
end -- 186
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 195
	local g = _G -- 196
	local ____temp_1 -- 197
	if g.package ~= nil then -- 197
		____temp_1 = g.package.loaded -- 197
	else -- 197
		____temp_1 = nil -- 197
	end -- 197
	local loaded = ____temp_1 -- 197
	if loaded == nil then -- 197
		return -- 199
	end -- 199
	local rawFe = loaded["watch.fe"] -- 201
	if rawFe ~= nil and type(rawFe) == "table" then -- 201
		local watchFe = rawFe -- 203
		if watchFe.contract ~= self.contract then -- 203
			watchFe.contract = self.contract -- 205
			watchFe.audio = self.audio -- 206
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 207
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 208
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 209
		end -- 209
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 211
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 212
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 213
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 214
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 215
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 216
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 217
	end -- 217
end -- 195
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 221
	local scale = math.max( -- 222
		0.25, -- 222
		math.min(w / 1280, h / 720) -- 222
	) -- 222
	self.uiLayer.scaleX = scale -- 223
	self.uiLayer.scaleY = scale -- 224
	return scale -- 225
end -- 221
function WatchFrontend.prototype.setVisible(self, v) -- 229
	self.layerRoot.visible = v -- 230
	if not v then -- 230
		self.texts:hideAll() -- 232
	end -- 232
end -- 229
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 237
	self:syncRuntimeHooks() -- 238
	self.boundPlay = p -- 239
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 240
	self.cam:snap(p, w, h) -- 241
	self.adapter:reset(p) -- 242
	self.contract:resetForRoom(p) -- 243
	self.audio:stopRoomTransient() -- 244
	self.actors:reset(p) -- 245
	self.occlusion:reset() -- 246
	self.vfx:reset() -- 247
	self.hud:reset(p) -- 248
	self.narrative:onEnterRoom(p.room.key) -- 249
	if #self.plugins > 0 then -- 249
		local initView = self.contract:peekSnapshot(p) -- 252
		local i = 0 -- 253
		do -- 253
			i = 0 -- 254
			while i < #self.plugins do -- 254
				local pl = self.plugins[i + 1] -- 255
				if pl.onBindPlay ~= nil then -- 255
					pl:onBindPlay(p, initView) -- 257
				end -- 257
				i = i + 1 -- 254
			end -- 254
		end -- 254
	end -- 254
end -- 237
function WatchFrontend.prototype.clearAll(self) -- 263
	self.bgDraw:clear() -- 264
	self.bgGlow:clear() -- 265
	self.fgDraw:clear() -- 266
	self.fgGlow:clear() -- 267
	self.uiDraw:clear() -- 268
	self.uiInkDraw:clear() -- 269
	self.uiGlow:clear() -- 270
	self.backdropArt:beginFrame() -- 271
	self.worldArt:beginFrame() -- 272
	self.uiArt:beginFrame() -- 273
	self.texts:beginFrame() -- 274
end -- 263
function WatchFrontend.prototype.finishFrame(self) -- 277
	self.backdropArt:endFrame() -- 278
	self.worldArt:endFrame() -- 279
	self.uiArt:endFrame() -- 280
	self.texts:endFrame() -- 281
end -- 277
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 285
	self:syncRuntimeHooks() -- 286
	self:setVisible(true) -- 287
	self:clearAll() -- 288
	local uiScale = self:resizeInterface(w, h) -- 289
	local act = self.menus:updateAndDrawScreen( -- 290
		dt, -- 291
		self.screen, -- 292
		input, -- 293
		self.stage, -- 294
		self.bgDraw, -- 295
		self.bgGlow, -- 296
		self.backdropArt, -- 297
		self.uiArt, -- 298
		self.uiDraw, -- 299
		self.uiInkDraw, -- 300
		self.uiGlow, -- 301
		self.texts, -- 302
		w, -- 303
		h, -- 304
		uiScale -- 305
	) -- 305
	self:finishFrame() -- 307
	return act -- 308
end -- 285
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 312
	self:syncRuntimeHooks() -- 313
	self:setVisible(true) -- 314
	if self.boundPlay ~= p then -- 314
		self:bindPlay(p, w, h) -- 316
	end -- 316
	local safeDt = math.min( -- 318
		0.05, -- 318
		math.max(0.001, dt) -- 318
	) -- 318
	self.audio:setPaused(p.paused) -- 319
	local ev -- 321
	local worldDt = 0 -- 322
	local uiDt = 0 -- 323
	if not p.paused then -- 323
		ev = self.adapter:sample(p) -- 327
		self.vfx:ingest(ev, p, self.cam) -- 328
		self.audio:ingestEvents(ev, p) -- 329
	else -- 329
		ev = self.adapter:emptyFrame(p) -- 332
		self.narrative.wipeT = 0 -- 333
	end -- 333
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 336
	if not p.paused then -- 336
		local clampedScale = math.max( -- 338
			0, -- 338
			math.min(2, view.timeScale) -- 338
		) -- 338
		uiDt = safeDt -- 339
		worldDt = safeDt * clampedScale -- 340
	end -- 340
	local uiScale = self:resizeInterface(w, h) -- 343
	local uiW = w / uiScale -- 344
	local uiH = h / uiScale -- 345
	local ctx = { -- 347
		p = p, -- 348
		view = view, -- 349
		events = ev, -- 350
		input = input, -- 351
		cam = self.cam, -- 352
		audio = self.audio, -- 353
		assets = self.worldArt, -- 354
		backdropArt = self.backdropArt, -- 355
		worldArt = self.worldArt, -- 356
		uiArt = self.uiArt, -- 357
		texts = self.texts, -- 358
		worldDt = worldDt, -- 359
		uiDt = uiDt, -- 360
		w = w, -- 361
		h = h, -- 362
		uiW = uiW, -- 363
		uiH = uiH, -- 364
		uiScale = uiScale, -- 365
		paused = p.paused -- 366
	} -- 366
	local i = 0 -- 370
	do -- 370
		i = 0 -- 371
		while i < #self.plugins do -- 371
			local pl = self.plugins[i + 1] -- 372
			if pl.update ~= nil then -- 372
				pl:update(ctx) -- 374
			end -- 374
			i = i + 1 -- 371
		end -- 371
	end -- 371
	if not p.paused then -- 371
		self.time = self.time + worldDt -- 379
		self.cam:update(worldDt, p, w, h) -- 380
		self.actors:update(worldDt, p) -- 381
		self.vfx:update( -- 382
			worldDt, -- 382
			themeOf(p.room.key).ambient -- 382
		) -- 382
		self.hud:update(worldDt, p) -- 383
		self.narrative:update(worldDt, p) -- 384
	else -- 384
		self.cam:update(0, p, w, h) -- 386
	end -- 386
	self:clearAll() -- 389
	local backdropHandled = false -- 392
	do -- 392
		i = 0 -- 393
		while i < #self.plugins do -- 393
			local pl = self.plugins[i + 1] -- 394
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 394
				backdropHandled = true -- 396
			end -- 396
			i = i + 1 -- 393
		end -- 393
	end -- 393
	if not backdropHandled then -- 393
		self.stage:drawBackdrop( -- 400
			self.bgDraw, -- 400
			self.bgGlow, -- 400
			self.backdropArt, -- 400
			p, -- 400
			self.cam, -- 400
			self.time -- 400
		) -- 400
	end -- 400
	local worldHandled = false -- 404
	do -- 404
		i = 0 -- 405
		while i < #self.plugins do -- 405
			local pl = self.plugins[i + 1] -- 406
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 406
				worldHandled = true -- 408
			end -- 408
			i = i + 1 -- 405
		end -- 405
	end -- 405
	if not worldHandled then -- 405
		self.stage:drawPlayableWorld( -- 412
			self.fgDraw, -- 412
			self.fgGlow, -- 412
			self.worldArt, -- 412
			p, -- 412
			self.cam, -- 412
			self.time, -- 412
			self.occlusion, -- 412
			worldDt -- 412
		) -- 412
	end -- 412
	local propsHandled = false -- 416
	do -- 416
		i = 0 -- 417
		while i < #self.plugins do -- 417
			local pl = self.plugins[i + 1] -- 418
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 418
				propsHandled = true -- 420
			end -- 420
			i = i + 1 -- 417
		end -- 417
	end -- 417
	if not propsHandled then -- 417
		self.props:drawAll( -- 424
			self.fgDraw, -- 424
			self.fgGlow, -- 424
			self.worldArt, -- 424
			p, -- 424
			self.cam, -- 424
			self.time, -- 424
			self.occlusion, -- 424
			worldDt -- 424
		) -- 424
	end -- 424
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 428
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 432
	self.actors:drawAll( -- 440
		self.fgDraw, -- 440
		self.fgGlow, -- 440
		self.worldArt, -- 440
		p, -- 440
		self.cam, -- 440
		suppressPartner -- 440
	) -- 440
	do -- 440
		i = 0 -- 441
		while i < #self.plugins do -- 441
			local pl = self.plugins[i + 1] -- 442
			if pl.drawActorsOverlay ~= nil then -- 442
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 444
			end -- 444
			i = i + 1 -- 441
		end -- 441
	end -- 441
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 449
	self.stage:drawForegroundFraming( -- 452
		self.fgDraw, -- 452
		w, -- 452
		h, -- 452
		p, -- 452
		self.cam -- 452
	) -- 452
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 453
	local action = {type = "none"} -- 456
	if p.paused then -- 456
		action = self.menus:updateAndDrawPause( -- 458
			safeDt, -- 459
			input, -- 460
			self.uiDraw, -- 461
			self.uiInkDraw, -- 462
			self.uiArt, -- 463
			self.uiGlow, -- 464
			self.texts, -- 465
			uiW, -- 466
			uiH, -- 467
			uiScale, -- 468
			view.assistHintsEnabled, -- 469
			function() -- 470
				self.contract:toggleAssistHints() -- 471
			end -- 470
		) -- 470
	else -- 470
		local cutsceneHandled = false -- 476
		do -- 476
			i = 0 -- 477
			while i < #self.plugins do -- 477
				local pl = self.plugins[i + 1] -- 478
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 478
					self.uiDraw, -- 480
					self.uiInkDraw, -- 480
					self.uiArt, -- 480
					self.uiGlow, -- 480
					ctx -- 480
				) then -- 480
					cutsceneHandled = true -- 481
				end -- 481
				i = i + 1 -- 477
			end -- 477
		end -- 477
		if not cutsceneHandled then -- 477
			self.hud:draw( -- 486
				self.uiDraw, -- 487
				self.uiInkDraw, -- 488
				self.uiArt, -- 489
				self.uiGlow, -- 490
				self.texts, -- 491
				p, -- 492
				self.cam, -- 493
				self.vfx, -- 494
				self.narrative.letterbox, -- 495
				uiScale, -- 496
				view.assistHintsEnabled, -- 497
				true -- 498
			) -- 498
			self.narrative:draw( -- 500
				self.uiDraw, -- 501
				self.uiInkDraw, -- 502
				self.uiGlow, -- 503
				self.uiArt, -- 504
				self.texts, -- 505
				p, -- 506
				uiW, -- 507
				uiH, -- 508
				view.assistHintsEnabled -- 509
			) -- 509
		end -- 509
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 513
		do -- 513
			i = 0 -- 514
			while i < #self.plugins do -- 514
				local pl = self.plugins[i + 1] -- 515
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 515
					self.uiDraw, -- 517
					self.uiInkDraw, -- 517
					self.uiArt, -- 517
					self.uiGlow, -- 517
					ctx -- 517
				) then -- 517
					suppressReticle = true -- 518
				end -- 518
				i = i + 1 -- 514
			end -- 514
		end -- 514
		if not suppressReticle then -- 514
			self.hud:drawReticleOverlay( -- 522
				self.uiInkDraw, -- 523
				self.uiArt, -- 524
				self.uiGlow, -- 525
				p, -- 526
				self.cam, -- 527
				self.vfx, -- 528
				self.narrative.letterbox, -- 529
				uiScale -- 530
			) -- 530
		end -- 530
		if view.isRehearsal then -- 530
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 536
			drawSilkVeil( -- 537
				self.uiDraw, -- 537
				self.uiArt, -- 537
				"rehearsal_tag_veil", -- 537
				uiW * 0.5, -- 537
				uiH - 22, -- 537
				168, -- 537
				26, -- 537
				PALETTE.inkWarm, -- 537
				0.74, -- 537
				8 -- 537
			) -- 537
			self.texts:put( -- 538
				"xs", -- 538
				badgeText, -- 538
				uiW * 0.5, -- 538
				uiH - 22, -- 538
				toColor(PALETTE.amberCore), -- 538
				0.5, -- 538
				0.5, -- 538
				"Center", -- 538
				1.2, -- 538
				0.92, -- 538
				0.08 -- 538
			) -- 538
		end -- 538
	end -- 538
	self:finishFrame() -- 542
	return action -- 543
end -- 312
return ____exports -- 312