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
			if self.plugins[i + 1].id == plugin.id then -- 160
				self.plugins[i + 1] = plugin -- 162
				self:syncRuntimeHooks() -- 163
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 163
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
	local ____self_plugins_0 = self.plugins -- 160
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 170
	self:syncRuntimeHooks() -- 171
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 171
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
			if self.plugins[i + 1].id ~= id then -- 181
				self.plugins[w + 1] = self.plugins[i + 1] -- 183
				w = w + 1 -- 184
			end -- 184
			i = i + 1 -- 181
		end -- 181
	end -- 181
	__TS__ArraySetLength(self.plugins, w) -- 181
	self:syncRuntimeHooks() -- 188
end -- 178
function WatchFrontend.prototype.getPlugin(self, id) -- 192
	local i = 0 -- 193
	do -- 193
		i = 0 -- 194
		while i < #self.plugins do -- 194
			if self.plugins[i + 1].id == id then -- 194
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
	if loaded == nil then -- 213
		return -- 215
	end -- 215
	local rawFe = loaded["watch.fe"] -- 217
	if rawFe ~= nil and type(rawFe) == "table" then -- 217
		local watchFe = rawFe -- 219
		if watchFe.contract ~= self.contract then -- 219
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
	if not v then -- 250
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
	if #self.plugins > 0 then -- 269
		local initView = self.contract:peekSnapshot(p) -- 272
		local i = 0 -- 273
		do -- 273
			i = 0 -- 274
			while i < #self.plugins do -- 274
				local pl = self.plugins[i + 1] -- 275
				if pl.onBindPlay ~= nil then -- 275
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
	if self.toastTimer <= 0 or self.toastText == "" then -- 320
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
	if #offers == 0 then -- 333
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
	if self.toastTimer > 0 then -- 343
		self.toastTimer = math.max( -- 345
			0, -- 345
			self.toastTimer - math.min( -- 345
				0.05, -- 345
				math.max(0, dt) -- 345
			) -- 345
		) -- 345
	end -- 345
	if self.screen == "title" and self.boundPlay ~= nil then -- 345
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
	if #offers == 0 then -- 379
		return false -- 381
	end -- 381
	local useUiPtr = input.uiInside or input.uiPressed -- 383
	local ____useUiPtr_2 -- 384
	if useUiPtr then -- 384
		____useUiPtr_2 = input.uiInside -- 384
	else -- 384
		____useUiPtr_2 = input.inside -- 384
	end -- 384
	local inside = ____useUiPtr_2 -- 384
	if not inside then -- 384
		return false -- 386
	end -- 386
	local uiScale = math.max( -- 388
		0.25, -- 388
		math.min(w / 1280, h / 720) -- 388
	) -- 388
	local uiW = w / uiScale -- 389
	local uiH = h / uiScale -- 390
	local rawX = useUiPtr and input.uiX or input.mx -- 391
	local rawY = useUiPtr and input.uiY or input.my -- 392
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 393
	local boxes = self.hud:talentCardRects( -- 394
		uiW, -- 394
		uiH, -- 394
		#offers, -- 394
		input:isTouchMode(), -- 394
		self.stageVp.safeUi.top -- 394
	) -- 394
	local i = 0 -- 395
	do -- 395
		i = 0 -- 396
		while i < #boxes do -- 396
			if boxes[i + 1]:containsPoint(pointer) then -- 396
				return p:chooseTalent(i) -- 398
			end -- 398
			i = i + 1 -- 396
		end -- 396
	end -- 396
	return false -- 401
end -- 378
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 405
	self:syncRuntimeHooks() -- 406
	self:setVisible(true) -- 407
	if self.boundPlay ~= p then -- 407
		self:bindPlay(p, w, h) -- 409
	end -- 409
	local safeDt = math.min( -- 411
		0.05, -- 411
		math.max(0.001, dt) -- 411
	) -- 411
	if self.toastTimer > 0 then -- 411
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 413
	end -- 413
	self.audio:setPaused(p.paused) -- 415
	local ev -- 417
	local worldDt = 0 -- 418
	local uiDt = 0 -- 419
	if not p.paused then -- 419
		ev = self.adapter:sample(p) -- 423
		self.vfx:ingest(ev, p, self.cam) -- 424
		self.audio:ingestEvents(ev, p) -- 425
		local touch = input:getTouch() -- 426
		if touch ~= nil then -- 426
			if ev.playerHit then -- 426
				touch:vibrate(0.036) -- 429
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 429
				touch:vibrate(0.024) -- 431
			elseif ev.coverDeflect then -- 431
				touch:vibrate(0.018) -- 433
			elseif ev.knockPulse then -- 433
				touch:vibrate(0.014) -- 435
			end -- 435
		end -- 435
	else -- 435
		ev = self.adapter:emptyFrame(p) -- 440
		self.narrative.wipeT = 0 -- 441
	end -- 441
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 444
	if not p.paused then -- 444
		local clampedScale = math.max( -- 446
			0, -- 446
			math.min(2, view.timeScale) -- 446
		) -- 446
		uiDt = safeDt -- 447
		worldDt = safeDt * clampedScale -- 448
	end -- 448
	local uiScale = self:resizeInterface(w, h) -- 451
	local uiW = w / uiScale -- 452
	local uiH = h / uiScale -- 453
	local ctx = { -- 455
		p = p, -- 456
		view = view, -- 457
		events = ev, -- 458
		input = input, -- 459
		cam = self.cam, -- 460
		audio = self.audio, -- 461
		assets = self.worldArt, -- 462
		backdropArt = self.backdropArt, -- 463
		worldArt = self.worldArt, -- 464
		uiArt = self.uiArt, -- 465
		texts = self.texts, -- 466
		worldDt = worldDt, -- 467
		uiDt = uiDt, -- 468
		w = w, -- 469
		h = h, -- 470
		uiW = uiW, -- 471
		uiH = uiH, -- 472
		uiScale = uiScale, -- 473
		safeUi = self.stageVp.safeUi, -- 474
		paused = p.paused -- 475
	} -- 475
	local i = 0 -- 479
	do -- 479
		i = 0 -- 480
		while i < #self.plugins do -- 480
			local pl = self.plugins[i + 1] -- 481
			if pl.update ~= nil then -- 481
				pl:update(ctx) -- 483
			end -- 483
			i = i + 1 -- 480
		end -- 480
	end -- 480
	if not p.paused then -- 480
		self.time = self.time + worldDt -- 488
		self.cam:update(worldDt, p, w, h) -- 489
		self.actors:update(worldDt, p) -- 490
		self.vfx:update( -- 491
			worldDt, -- 491
			themeOf(p.room.key).ambient -- 491
		) -- 491
		self.hud:update(worldDt, p) -- 492
		self.narrative:update(worldDt, p) -- 493
	else -- 493
		self.cam:update(0, p, w, h) -- 495
	end -- 495
	self:clearAll() -- 498
	local backdropHandled = false -- 501
	do -- 501
		i = 0 -- 502
		while i < #self.plugins do -- 502
			local pl = self.plugins[i + 1] -- 503
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 503
				backdropHandled = true -- 505
			end -- 505
			i = i + 1 -- 502
		end -- 502
	end -- 502
	if not backdropHandled then -- 502
		self.stage:drawBackdrop( -- 509
			self.bgDraw, -- 509
			self.bgGlow, -- 509
			self.backdropArt, -- 509
			p, -- 509
			self.cam, -- 509
			self.time -- 509
		) -- 509
	end -- 509
	local worldHandled = false -- 513
	do -- 513
		i = 0 -- 514
		while i < #self.plugins do -- 514
			local pl = self.plugins[i + 1] -- 515
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 515
				worldHandled = true -- 517
			end -- 517
			i = i + 1 -- 514
		end -- 514
	end -- 514
	if not worldHandled then -- 514
		self.stage:drawPlayableWorld( -- 521
			self.fgDraw, -- 521
			self.fgGlow, -- 521
			self.worldArt, -- 521
			p, -- 521
			self.cam, -- 521
			self.time, -- 521
			self.occlusion, -- 521
			worldDt -- 521
		) -- 521
	end -- 521
	local propsHandled = false -- 525
	do -- 525
		i = 0 -- 526
		while i < #self.plugins do -- 526
			local pl = self.plugins[i + 1] -- 527
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 527
				propsHandled = true -- 529
			end -- 529
			i = i + 1 -- 526
		end -- 526
	end -- 526
	if not propsHandled then -- 526
		self.props:drawAll( -- 533
			self.fgDraw, -- 533
			self.fgGlow, -- 533
			self.worldArt, -- 533
			p, -- 533
			self.cam, -- 533
			self.time, -- 533
			self.occlusion, -- 533
			worldDt -- 533
		) -- 533
	end -- 533
	local suppressAllActors = view.visualMode == "museum" -- 537
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 538
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 542
	if not suppressAllActors then -- 542
		self.actors:drawAll( -- 551
			self.fgDraw, -- 551
			self.fgGlow, -- 551
			self.worldArt, -- 551
			p, -- 551
			self.cam, -- 551
			suppressPartner -- 551
		) -- 551
	end -- 551
	do -- 551
		i = 0 -- 553
		while i < #self.plugins do -- 553
			local pl = self.plugins[i + 1] -- 554
			if pl.drawActorsOverlay ~= nil then -- 554
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 556
			end -- 556
			i = i + 1 -- 553
		end -- 553
	end -- 553
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 561
	self.stage:drawForegroundFraming( -- 564
		self.fgDraw, -- 564
		w, -- 564
		h, -- 564
		p, -- 564
		self.cam -- 564
	) -- 564
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 565
	local action = {type = "none"} -- 568
	if p.paused then -- 568
		action = self.menus:updateAndDrawPause( -- 570
			safeDt, -- 571
			input, -- 572
			self.uiDraw, -- 573
			self.uiInkDraw, -- 574
			self.uiArt, -- 575
			self.uiGlow, -- 576
			self.texts, -- 577
			uiW, -- 578
			uiH, -- 579
			uiScale, -- 580
			view.assistHintsEnabled, -- 581
			function() -- 582
				self.contract:toggleAssistHints() -- 583
			end, -- 582
			self.stageVp.safeUi -- 585
		) -- 585
	else -- 585
		local cutsceneHandled = false -- 589
		do -- 589
			i = 0 -- 590
			while i < #self.plugins do -- 590
				local pl = self.plugins[i + 1] -- 591
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 591
					self.uiDraw, -- 593
					self.uiInkDraw, -- 593
					self.uiArt, -- 593
					self.uiGlow, -- 593
					ctx -- 593
				) then -- 593
					cutsceneHandled = true -- 594
				end -- 594
				i = i + 1 -- 590
			end -- 590
		end -- 590
		if not cutsceneHandled then -- 590
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 599
			self.hud:draw( -- 600
				self.uiDraw, -- 601
				self.uiInkDraw, -- 602
				self.uiArt, -- 603
				self.uiGlow, -- 604
				self.texts, -- 605
				p, -- 606
				self.cam, -- 607
				self.vfx, -- 608
				self.narrative.letterbox, -- 609
				uiScale, -- 610
				view.assistHintsEnabled, -- 611
				true, -- 612
				input.inputMode, -- 613
				input.gamepadLayout, -- 614
				self.stageVp.safeUi, -- 615
				input.retryHoldProgress, -- 616
				touchOverlayVisible -- 617
			) -- 617
			self.narrative:draw( -- 619
				self.uiDraw, -- 620
				self.uiInkDraw, -- 621
				self.uiGlow, -- 622
				self.uiArt, -- 623
				self.texts, -- 624
				p, -- 625
				uiW, -- 626
				uiH, -- 627
				view.assistHintsEnabled, -- 628
				input.inputMode, -- 629
				input.gamepadLayout, -- 630
				self.stageVp.safeUi -- 631
			) -- 631
		end -- 631
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 635
		do -- 635
			i = 0 -- 636
			while i < #self.plugins do -- 636
				local pl = self.plugins[i + 1] -- 637
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 637
					self.uiDraw, -- 639
					self.uiInkDraw, -- 639
					self.uiArt, -- 639
					self.uiGlow, -- 639
					ctx -- 639
				) then -- 639
					suppressReticle = true -- 640
				end -- 640
				i = i + 1 -- 636
			end -- 636
		end -- 636
		if not suppressReticle then -- 636
			self.hud:drawReticleOverlay( -- 644
				self.uiInkDraw, -- 645
				self.uiArt, -- 646
				self.uiGlow, -- 647
				p, -- 648
				self.cam, -- 649
				self.vfx, -- 650
				self.narrative.letterbox, -- 651
				uiScale, -- 652
				input:isTouchMode() -- 653
			) -- 653
		end -- 653
		if view.isRehearsal then -- 653
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 659
			drawSilkVeil( -- 660
				self.uiDraw, -- 660
				self.uiArt, -- 660
				"rehearsal_tag_veil", -- 660
				uiW * 0.5, -- 660
				uiH - 22 - self.stageVp.safeUi.top, -- 660
				168, -- 660
				26, -- 660
				PALETTE.inkWarm, -- 660
				0.74, -- 660
				8 -- 660
			) -- 660
			self.texts:put( -- 661
				"xs", -- 661
				badgeText, -- 661
				uiW * 0.5, -- 661
				uiH - 22 - self.stageVp.safeUi.top, -- 661
				toColor(PALETTE.amberCore), -- 661
				0.5, -- 661
				0.5, -- 661
				"Center", -- 661
				1.2, -- 661
				0.92, -- 661
				0.08 -- 661
			) -- 661
		end -- 661
	end -- 661
	self:drawToast(uiW) -- 665
	self:finishFrame() -- 666
	return action -- 667
end -- 405
return ____exports -- 405