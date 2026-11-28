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
local ____controls_config = require("Script.watch.controls_config") -- 15
local saveControlSettings = ____controls_config.saveControlSettings -- 15
local ____platform = require("Script.watch.platform") -- 16
local computeStageViewport = ____platform.computeStageViewport -- 16
local ____adapter = require("Script.watch.fe.adapter") -- 17
local PlayAdapter = ____adapter.PlayAdapter -- 17
local ____assets = require("Script.watch.fe.assets") -- 18
local AssetSlotHost = ____assets.AssetSlotHost -- 18
local ____audio = require("Script.watch.fe.audio") -- 19
local AudioDirector = ____audio.AudioDirector -- 19
local ____bgm = require("Script.watch.fe.bgm") -- 20
local SoundscapeDirector = ____bgm.SoundscapeDirector -- 20
local ____camera = require("Script.watch.fe.camera") -- 21
local CameraDirector = ____camera.CameraDirector -- 21
local ____contract = require("Script.watch.fe.contract") -- 22
local DualRouteContract = ____contract.DualRouteContract -- 22
local ____occlusion = require("Script.watch.fe.occlusion") -- 23
local DepthOcclusion = ____occlusion.DepthOcclusion -- 23
local ____stage = require("Script.watch.fe.renderer.stage") -- 25
local StageRenderer = ____stage.StageRenderer -- 25
local ____props = require("Script.watch.fe.renderer.props") -- 26
local PropsRenderer = ____props.PropsRenderer -- 26
local ____actors = require("Script.watch.fe.renderer.actors") -- 27
local ActorsRenderer = ____actors.ActorsRenderer -- 27
local ____diorama_grid = require("Script.watch.fe.renderer.diorama_grid") -- 28
local DioramaLayerHost = ____diorama_grid.DioramaLayerHost -- 28
local ____scene_fx = require("Script.watch.fe.renderer.scene_fx") -- 29
local SceneFxSystem = ____scene_fx.SceneFxSystem -- 29
local ____vfx = require("Script.watch.fe.renderer.vfx") -- 30
local VfxSystem = ____vfx.VfxSystem -- 30
local ____escort_world = require("Script.watch.fe.scenes.escort_world") -- 31
local EscortWorldRenderer = ____escort_world.EscortWorldRenderer -- 31
local ____second_half_assets = require("Script.watch.fe.scenes.second_half_assets") -- 32
local ensureSecondHalfAssetsRegistered = ____second_half_assets.ensureSecondHalfAssetsRegistered -- 32
local ____dark_pixel_assets = require("Script.watch.fe.scenes.dark_pixel_assets") -- 33
local ensureDarkPixelAssetsRegistered = ____dark_pixel_assets.ensureDarkPixelAssetsRegistered -- 33
local ____textpool = require("Script.watch.fe.ui.textpool") -- 34
local TextPool = ____textpool.TextPool -- 34
local ____hud = require("Script.watch.fe.ui.hud") -- 35
local HudRenderer = ____hud.HudRenderer -- 35
local ____narrative = require("Script.watch.fe.ui.narrative") -- 36
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 36
local ____menus = require("Script.watch.fe.ui.menus") -- 37
local MenuRenderer = ____menus.MenuRenderer -- 37
local ____theme = require("Script.watch.fe.theme") -- 38
local PALETTE = ____theme.PALETTE -- 38
local drawSilkVeil = ____theme.drawSilkVeil -- 38
local themeOf = ____theme.themeOf -- 38
local toColor = ____theme.toColor -- 38
local visualTextWidth = ____theme.visualTextWidth -- 38
local ____ming_audit = require("Script.watch.fe.renderer.ming_audit") -- 39
local MingArtAuditPlugin = ____ming_audit.MingArtAuditPlugin -- 39
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 40
local GateTransitionPlugin = ____gate_transition.GateTransitionPlugin -- 40
local ____xiaoman3d = require("Script.watch.fe.scenes.xiaoman3d") -- 41
local Xiaoman3DScene = ____xiaoman3d.Xiaoman3DScene -- 41
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 42
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 42
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 43
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 43
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 44
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 44
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 45
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 45
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 46
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 46
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 47
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 47
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 48
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 48
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 49
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 49
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 50
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 50
local ____roguelike_ui = require("Script.watch.fe.ui.roguelike_ui") -- 51
local computeEscortDeathButtons = ____roguelike_ui.computeEscortDeathButtons -- 51
local RoguelikeUiPlugin = ____roguelike_ui.RoguelikeUiPlugin -- 51
____exports.WatchFrontend = __TS__Class() -- 53
local WatchFrontend = ____exports.WatchFrontend -- 53
WatchFrontend.name = "WatchFrontend" -- 53
function WatchFrontend.prototype.____constructor(self, parent) -- 103
	self.occlusion = __TS__New(DepthOcclusion) -- 54
	self.cam = __TS__New(CameraDirector) -- 77
	self.adapter = __TS__New(PlayAdapter) -- 78
	self.contract = __TS__New( -- 79
		DualRouteContract, -- 79
		function(p) return self:canPickStoryTalent(p) end -- 79
	) -- 79
	self.audio = __TS__New(AudioDirector) -- 80
	self.soundscape = __TS__New(SoundscapeDirector) -- 81
	self.stage = __TS__New(StageRenderer) -- 82
	self.escortWorld = __TS__New(EscortWorldRenderer) -- 83
	self.props = __TS__New(PropsRenderer) -- 84
	self.actors = __TS__New(ActorsRenderer) -- 85
	self.sceneFx = __TS__New(SceneFxSystem) -- 86
	self.vfx = __TS__New(VfxSystem) -- 87
	self.hud = __TS__New(HudRenderer) -- 88
	self.narrative = __TS__New(NarrativeRenderer) -- 89
	self.menus = __TS__New(MenuRenderer) -- 90
	self.plugins = {} -- 93
	self.screen = "title" -- 96
	self.time = 0 -- 97
	self.stageVp = computeStageViewport(1280, 720) -- 99
	self.toastText = "" -- 100
	self.toastTimer = 0 -- 101
	self.layerRoot = Node() -- 104
	self.layerRoot.order = 5 -- 105
	self.layerRoot:addTo(parent) -- 106
	ensureSecondHalfAssetsRegistered() -- 107
	ensureDarkPixelAssetsRegistered() -- 108
	self.xiaoman3d = __TS__New(Xiaoman3DScene, self.layerRoot) -- 109
	self.audio:attachHost(self.layerRoot) -- 111
	self.menus.onUiSound = function(____, kind) -- 112
		self:playMenuUiSound(kind) -- 113
	end -- 112
	self.menus.onAudioSettingsChanged = function(____, inp) -- 115
		self.audio:applyUserVolumes(inp.settings) -- 116
	end -- 115
	self.menus.onAssistSettingsChanged = function(____, inp) -- 118
		self.contract:setAssistHintsEnabled(inp.settings.assistHints) -- 119
	end -- 118
	local additive = BlendFunc("SrcAlpha", "One") -- 122
	self.bgDraw = DrawNode() -- 124
	self.bgDraw.order = 10 -- 125
	self.bgDraw:addTo(self.layerRoot) -- 126
	self.escortTowerDraw = DrawNode() -- 129
	self.escortTowerDraw.order = 13 -- 130
	self.escortTowerDraw:addTo(self.layerRoot) -- 131
	self.bgGlow = DrawNode() -- 133
	self.bgGlow.order = 15 -- 134
	self.bgGlow.blendFunc = additive -- 135
	self.bgGlow:addTo(self.layerRoot) -- 136
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 138
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 139
	self.groundDraw = DrawNode() -- 141
	self.groundDraw.order = 20 -- 142
	self.groundDraw:addTo(self.layerRoot) -- 143
	self.groundArt = __TS__New(AssetSlotHost, self.layerRoot, 22) -- 144
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 145
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 146
	self.worldOverlayDraw = DrawNode() -- 147
	self.worldOverlayDraw.order = 33 -- 148
	self.worldOverlayDraw:addTo(self.layerRoot) -- 149
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 150
	self.fgDraw = DrawNode() -- 152
	self.fgDraw.order = 30 -- 153
	self.fgDraw:addTo(self.layerRoot) -- 154
	self.fgGlow = DrawNode() -- 156
	self.fgGlow.order = 35 -- 157
	self.fgGlow.blendFunc = additive -- 158
	self.fgGlow:addTo(self.layerRoot) -- 159
	self.uiLayer = Node() -- 161
	self.uiLayer.order = 40 -- 162
	self.uiLayer:addTo(self.layerRoot) -- 163
	self.uiDraw = DrawNode() -- 165
	self.uiDraw.order = 0 -- 166
	self.uiDraw:addTo(self.uiLayer) -- 167
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 169
	self.uiInkDraw = DrawNode() -- 171
	self.uiInkDraw.order = 4 -- 172
	self.uiInkDraw:addTo(self.uiLayer) -- 173
	self.uiGlow = DrawNode() -- 175
	self.uiGlow.order = 6 -- 176
	self.uiGlow.blendFunc = additive -- 177
	self.uiGlow:addTo(self.uiLayer) -- 178
	self.uiMask = DrawNode() -- 180
	self.uiMask.order = 8 -- 181
	self.uiMask:addTo(self.uiLayer) -- 182
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 184
	self.roguelikeUi = __TS__New( -- 188
		RoguelikeUiPlugin, -- 188
		self.contract, -- 189
		function() return self.hud.talentSelected end, -- 190
		function(idx) -- 191
			self.hud.talentSelected = idx -- 192
		end -- 191
	) -- 191
	self.hud.roguelikeUiHandled = true -- 195
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) return self.roguelikeUi:getTalentCardRects( -- 196
		w, -- 197
		h, -- 197
		count, -- 197
		touchMode, -- 197
		safeTop -- 197
	) end -- 197
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 211
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 212
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 213
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 214
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 215
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 216
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 217
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 218
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 219
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 220
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 221
end -- 103
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 225
	local i = 0 -- 226
	do -- 226
		i = 0 -- 227
		while i < #self.plugins do -- 227
			if self.plugins[i + 1].id == plugin.id then -- 227
				self.plugins[i + 1] = plugin -- 229
				self:syncRuntimeHooks() -- 230
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 230
					plugin:onBindPlay( -- 232
						self.boundPlay, -- 232
						self.contract:peekSnapshot(self.boundPlay) -- 232
					) -- 232
				end -- 232
				return -- 234
			end -- 234
			i = i + 1 -- 227
		end -- 227
	end -- 227
	local ____self_plugins_0 = self.plugins -- 227
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 237
	self:syncRuntimeHooks() -- 238
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 238
		plugin:onBindPlay( -- 240
			self.boundPlay, -- 240
			self.contract:peekSnapshot(self.boundPlay) -- 240
		) -- 240
	end -- 240
end -- 225
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 245
	local w = 0 -- 246
	local i = 0 -- 247
	do -- 247
		i = 0 -- 248
		while i < #self.plugins do -- 248
			if self.plugins[i + 1].id ~= id then -- 248
				self.plugins[w + 1] = self.plugins[i + 1] -- 250
				w = w + 1 -- 251
			end -- 251
			i = i + 1 -- 248
		end -- 248
	end -- 248
	__TS__ArraySetLength(self.plugins, w) -- 248
	self:syncRuntimeHooks() -- 255
end -- 245
function WatchFrontend.prototype.getPlugin(self, id) -- 259
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 259
		return self.roguelikeUi -- 261
	end -- 261
	local i = 0 -- 263
	do -- 263
		i = 0 -- 264
		while i < #self.plugins do -- 264
			if self.plugins[i + 1].id == id then -- 264
				return self.plugins[i + 1] -- 266
			end -- 266
			i = i + 1 -- 264
		end -- 264
	end -- 264
	return nil -- 269
end -- 259
function WatchFrontend.prototype.getPlugins(self) -- 272
	return self.plugins -- 273
end -- 272
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 281
	local g = _G -- 282
	local ____temp_1 -- 283
	if g.package ~= nil then -- 283
		____temp_1 = g.package.loaded -- 283
	else -- 283
		____temp_1 = nil -- 283
	end -- 283
	local loaded = ____temp_1 -- 283
	if loaded == nil then -- 283
		return -- 285
	end -- 285
	local rawFe = loaded["watch.fe"] -- 287
	if rawFe ~= nil and type(rawFe) == "table" then -- 287
		local watchFe = rawFe -- 289
		if watchFe.contract ~= self.contract then -- 289
			watchFe.contract = self.contract -- 291
			watchFe.audio = self.audio -- 292
			watchFe.soundscape = self.soundscape -- 293
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 294
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 295
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 296
		end -- 296
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 298
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 299
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 300
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 301
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 302
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 303
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 304
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 305
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 306
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 307
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 308
		watchFe.roguelikeUi = self.roguelikeUi -- 309
	end -- 309
end -- 281
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 313
	local scale = math.max( -- 314
		0.25, -- 314
		math.min(w / 1280, h / 720) -- 314
	) -- 314
	self.uiLayer.scaleX = scale -- 315
	self.uiLayer.scaleY = scale -- 316
	return scale -- 317
end -- 313
function WatchFrontend.prototype.setVisible(self, v) -- 321
	self.layerRoot.visible = v -- 322
	if not v then -- 322
		self.xiaoman3d:hide() -- 324
		self.cam.projection = nil -- 325
		self.texts:hideAll() -- 326
	end -- 326
end -- 321
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 331
	self:syncRuntimeHooks() -- 332
	self.boundPlay = p -- 333
	p.useEscortDeathSummary = true -- 334
	p:openTalentDraft() -- 335
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 336
	self.xiaoman3d:hide() -- 337
	self.cam.projection = nil -- 338
	self.cam:snap(p, w, h) -- 339
	self.adapter:reset(p) -- 340
	self.contract:resetForRoom(p) -- 341
	self.audio:stopRoomTransient() -- 342
	self.soundscape:resetForRoom(p) -- 343
	self.actors:reset(p) -- 344
	self.sceneFx:reset(p.room.key) -- 345
	self.occlusion:reset() -- 346
	self.vfx:reset() -- 347
	self.hud:reset(p) -- 348
	self.narrative:onEnterRoom(p.room.key) -- 349
	local initView = self.contract:peekSnapshot(p) -- 351
	if #self.plugins > 0 then -- 351
		local i = 0 -- 353
		do -- 353
			i = 0 -- 354
			while i < #self.plugins do -- 354
				local pl = self.plugins[i + 1] -- 355
				if pl.onBindPlay ~= nil then -- 355
					pl:onBindPlay(p, initView) -- 357
				end -- 357
				i = i + 1 -- 354
			end -- 354
		end -- 354
	end -- 354
	self.roguelikeUi:onBindPlay(p, initView) -- 361
end -- 331
function WatchFrontend.prototype.clearAll(self) -- 364
	self.bgDraw:clear() -- 365
	self.escortTowerDraw:clear() -- 366
	self.bgGlow:clear() -- 367
	self.groundDraw:clear() -- 368
	self.fgDraw:clear() -- 369
	self.worldOverlayDraw:clear() -- 370
	self.fgGlow:clear() -- 371
	self.uiDraw:clear() -- 372
	self.uiInkDraw:clear() -- 373
	self.uiGlow:clear() -- 374
	self.uiMask:clear() -- 375
	self.backdropArt:beginFrame() -- 376
	self.groundArt:beginFrame() -- 377
	self.dioramaBg:beginFrame() -- 378
	self.dioramaWorld:beginFrame() -- 379
	self.dioramaFg:beginFrame() -- 380
	self.worldArt:beginFrame() -- 381
	self.uiArt:beginFrame() -- 382
	self.texts:beginFrame() -- 383
end -- 364
function WatchFrontend.prototype.finishFrame(self) -- 386
	self.backdropArt:endFrame() -- 387
	self.groundArt:endFrame() -- 388
	self.dioramaBg:endFrame() -- 389
	self.dioramaWorld:endFrame() -- 390
	self.dioramaFg:endFrame() -- 391
	self.worldArt:endFrame() -- 392
	self.uiArt:endFrame() -- 393
	self.texts:endFrame() -- 394
end -- 386
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 398
	self.stageVp = vp -- 399
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 400
end -- 398
function WatchFrontend.prototype.showToast(self, text, duration) -- 404
	if duration == nil then -- 404
		duration = 1.8 -- 404
	end -- 404
	self.toastText = text -- 405
	self.toastTimer = duration -- 406
end -- 404
function WatchFrontend.prototype.getToastText(self) -- 409
	return self.toastTimer > 0 and self.toastText or "" -- 410
end -- 409
function WatchFrontend.prototype.drawToast(self, uiW) -- 413
	if self.toastTimer <= 0 or self.toastText == "" then -- 413
		return -- 415
	end -- 415
	local alpha = math.min(1, self.toastTimer * 2.4) -- 417
	local cx = uiW * 0.5 -- 418
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 419
	local veilW = math.max( -- 420
		340, -- 420
		math.min( -- 420
			uiW - 80, -- 420
			visualTextWidth(self.toastText, 19) + 64 -- 420
		) -- 420
	) -- 420
	drawSilkVeil( -- 421
		self.uiDraw, -- 421
		self.uiArt, -- 421
		"fe_toast_veil", -- 421
		cx, -- 421
		cy, -- 421
		veilW, -- 421
		40, -- 421
		PALETTE.inkWarm, -- 421
		0.88 * alpha, -- 421
		9 -- 421
	) -- 421
	self.texts:put( -- 422
		"sm", -- 422
		self.toastText, -- 422
		cx, -- 422
		cy, -- 422
		toColor(PALETTE.amberCore), -- 422
		0.5, -- 422
		0.5, -- 422
		"Center", -- 422
		1.4, -- 422
		0.96 * alpha, -- 422
		0.08 -- 422
	) -- 422
end -- 413
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 425
	return not p.escortFailed and not p.paused and not p.craftBench.active and not p.reloadOpen and self.roguelikeUi:canPickTalent() -- 426
end -- 425
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 430
	local offers = p:getStoryTalentOffers() -- 431
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 431
		return {} -- 433
	end -- 433
	local uiScale = math.max( -- 435
		0.25, -- 435
		math.min(w / 1280, h / 720) -- 435
	) -- 435
	return self.hud:talentCardRects( -- 436
		w / uiScale, -- 436
		h / uiScale, -- 436
		#offers, -- 436
		touchMode, -- 436
		self.stageVp.safeUi.top -- 436
	) -- 436
end -- 430
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 440
	if not p.escortFailed then -- 440
		return nil -- 442
	end -- 442
	local uiScale = math.max( -- 444
		0.25, -- 444
		math.min(w / 1280, h / 720) -- 444
	) -- 444
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 445
end -- 440
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 449
	if not p.escortFailed then -- 449
		return "" -- 451
	end -- 451
	if input.inputMode == "gamepad" and not input.uiPressed then -- 451
		return "" -- 454
	end -- 454
	local useUiPtr = input.uiInside or input.uiPressed -- 456
	local ____useUiPtr_2 -- 457
	if useUiPtr then -- 457
		____useUiPtr_2 = input.uiInside -- 457
	else -- 457
		____useUiPtr_2 = input.inside -- 457
	end -- 457
	local inside = ____useUiPtr_2 -- 457
	if not inside then -- 457
		return "" -- 459
	end -- 459
	local uiScale = math.max( -- 461
		0.25, -- 461
		math.min(w / 1280, h / 720) -- 461
	) -- 461
	local rawX = useUiPtr and input.uiX or input.mx -- 462
	local rawY = useUiPtr and input.uiY or input.my -- 463
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 464
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 465
	if btns.retry:containsPoint(pointer) then -- 465
		self.roguelikeUi.deathSelected = 0 -- 467
		return "retry" -- 468
	end -- 468
	if btns.title:containsPoint(pointer) then -- 468
		self.roguelikeUi.deathSelected = 1 -- 471
		return "title" -- 472
	end -- 472
	return "" -- 474
end -- 449
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 477
	if kind == "hover" then -- 477
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 479
	elseif kind == "confirm" then -- 479
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 481
	elseif kind == "back" then -- 481
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 483
	elseif kind == "start" then -- 483
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 485
	elseif kind == "pauseOpen" then -- 485
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 487
	elseif kind == "pauseClose" then -- 487
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 489
	elseif kind == "toggle" then -- 489
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 491
	end -- 491
end -- 477
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 496
	self:syncRuntimeHooks() -- 497
	local safeDt = math.min( -- 498
		0.05, -- 498
		math.max(0, dt) -- 498
	) -- 498
	self.time = self.time + safeDt -- 499
	if self.toastTimer > 0 then -- 499
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 501
	end -- 501
	if self.screen == "title" and self.boundPlay ~= nil then -- 501
		self.audio:stopRoomTransient() -- 504
		self.boundPlay = nil -- 505
	end -- 505
	self.audio:update(safeDt) -- 507
	self.xiaoman3d:hide() -- 508
	self.cam.projection = nil -- 509
	self.soundscape:updateMenu(self.screen, self.audio) -- 510
	self:setVisible(true) -- 511
	self:clearAll() -- 512
	local uiScale = self:resizeInterface(w, h) -- 513
	local act = self.menus:updateAndDrawScreen( -- 514
		dt, -- 515
		self.screen, -- 516
		input, -- 517
		self.stage, -- 518
		self.bgDraw, -- 519
		self.bgGlow, -- 520
		self.backdropArt, -- 521
		self.uiArt, -- 522
		self.uiDraw, -- 523
		self.uiInkDraw, -- 524
		self.uiGlow, -- 525
		self.texts, -- 526
		w, -- 527
		h, -- 528
		uiScale, -- 529
		self.stageVp.safeUi -- 530
	) -- 530
	if self.screen == "title" then -- 530
		self.sceneFx:drawTitleAtmosphere( -- 533
			self.bgGlow, -- 533
			self.fgGlow, -- 533
			self.backdropArt, -- 533
			self.worldArt, -- 533
			w, -- 533
			h, -- 533
			self.time -- 533
		) -- 533
	end -- 533
	self:drawToast(w / uiScale) -- 535
	self:finishFrame() -- 536
	return act -- 537
end -- 496
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 541
	local offers = p:getStoryTalentOffers() -- 542
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 542
		return false -- 544
	end -- 544
	if input.inputMode == "gamepad" and not input.uiPressed then -- 544
		return false -- 547
	end -- 547
	local useUiPtr = input.uiInside or input.uiPressed -- 549
	local ____useUiPtr_3 -- 550
	if useUiPtr then -- 550
		____useUiPtr_3 = input.uiInside -- 550
	else -- 550
		____useUiPtr_3 = input.inside -- 550
	end -- 550
	local inside = ____useUiPtr_3 -- 550
	if not inside then -- 550
		return false -- 552
	end -- 552
	local uiScale = math.max( -- 554
		0.25, -- 554
		math.min(w / 1280, h / 720) -- 554
	) -- 554
	local uiW = w / uiScale -- 555
	local uiH = h / uiScale -- 556
	local rawX = useUiPtr and input.uiX or input.mx -- 557
	local rawY = useUiPtr and input.uiY or input.my -- 558
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 559
	local boxes = self.hud:talentCardRects( -- 560
		uiW, -- 560
		uiH, -- 560
		#offers, -- 560
		input:isTouchMode(), -- 560
		self.stageVp.safeUi.top -- 560
	) -- 560
	local i = 0 -- 561
	do -- 561
		i = 0 -- 562
		while i < #boxes do -- 562
			if boxes[i + 1]:containsPoint(pointer) then -- 562
				return p:chooseTalent(i) -- 564
			end -- 564
			i = i + 1 -- 562
		end -- 562
	end -- 562
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 568
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 569
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 570
end -- 541
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 575
	self:syncRuntimeHooks() -- 576
	self:setVisible(true) -- 577
	if self.boundPlay ~= p then -- 577
		self:bindPlay(p, w, h) -- 579
	end -- 579
	local safeDt = math.min( -- 581
		0.05, -- 581
		math.max(0.001, dt) -- 581
	) -- 581
	if self.toastTimer > 0 then -- 581
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 583
	end -- 583
	self.audio:setPaused(p.paused) -- 585
	self.audio:setCameraRef( -- 586
		self.cam.x, -- 586
		w / math.max(0.25, self.cam.ppu) -- 586
	) -- 586
	self.audio:update(safeDt) -- 587
	local ev -- 589
	local worldDt = 0 -- 590
	local uiDt = 0 -- 591
	if not p.paused then -- 591
		ev = self.adapter:sample(p) -- 595
		self.vfx:ingest(ev, p, self.cam) -- 596
		self.audio:ingestEvents(ev, p) -- 597
		if ev.playerHit then -- 597
			input:vibrate(0.036) -- 599
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 599
			input:vibrate(0.024) -- 601
		elseif ev.coverDeflect then -- 601
			input:vibrate(0.018) -- 603
		elseif ev.knockPulse then -- 603
			input:vibrate(0.014) -- 605
		end -- 605
	else -- 605
		ev = self.adapter:emptyFrame(p) -- 609
		self.narrative.wipeT = 0 -- 610
	end -- 610
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 613
	if not p.paused then -- 613
		local clampedScale = math.max( -- 615
			0, -- 615
			math.min(2, view.timeScale) -- 615
		) -- 615
		uiDt = safeDt -- 616
		worldDt = safeDt * clampedScale -- 617
	end -- 617
	local uiScale = self:resizeInterface(w, h) -- 620
	local uiW = w / uiScale -- 621
	local uiH = h / uiScale -- 622
	local ctx = { -- 624
		p = p, -- 625
		view = view, -- 626
		events = ev, -- 627
		input = input, -- 628
		cam = self.cam, -- 629
		audio = self.audio, -- 630
		assets = self.worldArt, -- 631
		backdropArt = self.backdropArt, -- 632
		worldArt = self.worldArt, -- 633
		uiArt = self.uiArt, -- 634
		uiMask = self.uiMask, -- 635
		dioramaBg = self.dioramaBg, -- 636
		dioramaWorld = self.dioramaWorld, -- 637
		dioramaFg = self.dioramaFg, -- 638
		texts = self.texts, -- 639
		worldDt = worldDt, -- 640
		uiDt = uiDt, -- 641
		w = w, -- 642
		h = h, -- 643
		uiW = uiW, -- 644
		uiH = uiH, -- 645
		uiScale = uiScale, -- 646
		safeUi = self.stageVp.safeUi, -- 647
		paused = p.paused -- 648
	} -- 648
	local i = 0 -- 652
	do -- 652
		i = 0 -- 653
		while i < #self.plugins do -- 653
			local pl = self.plugins[i + 1] -- 654
			if pl.update ~= nil then -- 654
				pl:update(ctx) -- 656
			end -- 656
			i = i + 1 -- 653
		end -- 653
	end -- 653
	self.roguelikeUi:update(ctx) -- 659
	if not p.paused then -- 659
		self.time = self.time + worldDt -- 662
		self.cam:update(worldDt, p, w, h) -- 663
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 664
		self.audio:setCameraRef( -- 665
			self.cam.x, -- 665
			w / math.max(0.25, self.cam.ppu) -- 665
		) -- 665
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 666
		self.actors:update(worldDt, p) -- 667
		self.vfx:ingestFootsteps(self.actors:drainFootsteps()) -- 668
		if view.visualMode == "pixel" then -- 668
			self.sceneFx:update(worldDt, p, self.cam) -- 670
		end -- 670
		self.vfx:update( -- 672
			worldDt, -- 672
			themeOf(p.room.key).ambient -- 672
		) -- 672
		self.hud:update(safeDt, p) -- 673
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 674
	else -- 674
		self.cam:update(0, p, w, h) -- 676
	end -- 676
	self:clearAll() -- 679
	local use3D = self.xiaoman3d:supports(p, view.visualMode) -- 681
	if use3D then -- 681
		self.xiaoman3d:render( -- 683
			p, -- 683
			self.cam, -- 683
			self.actors, -- 683
			worldDt, -- 683
			w, -- 683
			h, -- 683
			self.stageVp -- 683
		) -- 683
	else -- 683
		self.xiaoman3d:hide() -- 685
		self.cam.projection = nil -- 686
		local backdropHandled = false -- 689
		do -- 689
			i = 0 -- 690
			while i < #self.plugins do -- 690
				local pl = self.plugins[i + 1] -- 691
				if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 691
					backdropHandled = true -- 693
				end -- 693
				i = i + 1 -- 690
			end -- 690
		end -- 690
		if not backdropHandled then -- 690
			self.stage:drawBackdrop( -- 697
				self.bgDraw, -- 697
				self.bgGlow, -- 697
				self.backdropArt, -- 697
				p, -- 697
				self.cam, -- 697
				self.time -- 697
			) -- 697
		end -- 697
		if view.visualMode == "pixel" then -- 697
			self.escortWorld:drawBackdropOverlay( -- 700
				self.bgDraw, -- 700
				self.bgGlow, -- 700
				self.backdropArt, -- 700
				p, -- 700
				self.cam, -- 700
				self.time, -- 700
				self.escortTowerDraw -- 700
			) -- 700
			self.sceneFx:drawBackdropFx( -- 701
				self.bgDraw, -- 701
				self.bgGlow, -- 701
				self.backdropArt, -- 701
				p, -- 701
				self.cam -- 701
			) -- 701
		end -- 701
		local worldHandled = false -- 705
		do -- 705
			i = 0 -- 706
			while i < #self.plugins do -- 706
				local pl = self.plugins[i + 1] -- 707
				if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 707
					worldHandled = true -- 709
				end -- 709
				i = i + 1 -- 706
			end -- 706
		end -- 706
		if not worldHandled then -- 706
			self.stage:drawPlayableWorld( -- 713
				self.groundDraw, -- 714
				self.fgGlow, -- 715
				self.worldArt, -- 716
				p, -- 717
				self.cam, -- 718
				self.time, -- 719
				self.occlusion, -- 720
				worldDt, -- 721
				self.groundArt, -- 722
				self.fgDraw, -- 723
				self.worldOverlayDraw -- 724
			) -- 724
		end -- 724
		local propsHandled = false -- 729
		do -- 729
			i = 0 -- 730
			while i < #self.plugins do -- 730
				local pl = self.plugins[i + 1] -- 731
				if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 731
					propsHandled = true -- 733
				end -- 733
				i = i + 1 -- 730
			end -- 730
		end -- 730
		if not propsHandled then -- 730
			self.props:drawAll( -- 737
				self.fgDraw, -- 737
				self.fgGlow, -- 737
				self.worldArt, -- 737
				p, -- 737
				self.cam, -- 737
				self.time, -- 737
				self.occlusion, -- 737
				worldDt, -- 737
				self.groundArt -- 737
			) -- 737
		end -- 737
		if view.visualMode == "pixel" then -- 737
			self.escortWorld:drawWorldSetpieces( -- 740
				self.fgDraw, -- 740
				self.fgGlow, -- 740
				self.worldArt, -- 740
				p, -- 740
				view, -- 740
				self.cam, -- 740
				self.time -- 740
			) -- 740
			self.sceneFx:drawWorldFx( -- 741
				self.fgDraw, -- 741
				self.fgGlow, -- 741
				self.worldArt, -- 741
				p, -- 741
				self.cam -- 741
			) -- 741
		end -- 741
		if view.visualMode ~= "museum" then -- 741
			local pose -- 746
			for ____, pl in ipairs(self.plugins) do -- 747
				if pl.drawPartyPose ~= nil then -- 747
					pose = pl:drawPartyPose(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 749
					if pose ~= nil then -- 749
						break -- 750
					end -- 750
				end -- 750
			end -- 750
			self.actors:drawAll( -- 753
				self.worldOverlayDraw, -- 753
				self.fgGlow, -- 753
				self.worldArt, -- 753
				p, -- 753
				self.cam, -- 753
				pose -- 753
			) -- 753
		end -- 753
		do -- 753
			i = 0 -- 755
			while i < #self.plugins do -- 755
				local pl = self.plugins[i + 1] -- 756
				if pl.drawActorsOverlay ~= nil then -- 756
					pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 758
				end -- 758
				i = i + 1 -- 755
			end -- 755
		end -- 755
		self.roguelikeUi:drawActorsOverlay(self.worldOverlayDraw, self.fgGlow, self.worldArt, ctx) -- 761
		self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam, p.room.depth ~= nil) -- 764
		if view.visualMode == "pixel" then -- 764
			self.stage:drawForegroundFraming( -- 768
				self.worldOverlayDraw, -- 768
				w, -- 768
				h, -- 768
				p, -- 768
				self.cam -- 768
			) -- 768
			self.escortWorld:drawForegroundFraming( -- 769
				self.worldOverlayDraw, -- 769
				self.fgGlow, -- 769
				self.worldArt, -- 769
				p, -- 769
				self.cam, -- 769
				self.time -- 769
			) -- 769
			self.sceneFx:drawForegroundWeather( -- 770
				self.fgGlow, -- 770
				p, -- 770
				self.cam, -- 770
				w, -- 770
				h -- 770
			) -- 770
		end -- 770
	end -- 770
	self.vfx:drawScreenVfx( -- 773
		self.fgGlow, -- 773
		w, -- 773
		h, -- 773
		p.room.key, -- 773
		view.visualMode ~= "pixel" -- 773
	) -- 773
	local action = {type = "none"} -- 776
	if p.paused then -- 776
		local canSaveCurrent = p.run.source == "official" and not p.run.finished and p.room.key ~= "museum" and not (p.room.key == "tower" and p.phase == "tower-end") -- 778
		action = self.menus:updateAndDrawPause( -- 782
			safeDt, -- 783
			input, -- 784
			self.uiDraw, -- 785
			self.uiInkDraw, -- 786
			self.uiArt, -- 787
			self.uiGlow, -- 788
			self.texts, -- 789
			uiW, -- 790
			uiH, -- 791
			uiScale, -- 792
			view.assistHintsEnabled, -- 793
			function() -- 794
				local next = self.contract:toggleAssistHints() -- 795
				input.settings.assistHints = next -- 796
				saveControlSettings(input.settings) -- 797
			end, -- 794
			self.stageVp.safeUi, -- 799
			p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom(), -- 800
			view.roguelike.active, -- 801
			function() -- 802
				self.roguelikeUi:openLedger() -- 803
			end, -- 802
			canSaveCurrent -- 805
		) -- 805
	else -- 805
		local cutsceneHandled = false -- 809
		do -- 809
			i = 0 -- 810
			while i < #self.plugins do -- 810
				local pl = self.plugins[i + 1] -- 811
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 811
					self.uiDraw, -- 813
					self.uiInkDraw, -- 813
					self.uiArt, -- 813
					self.uiGlow, -- 813
					ctx -- 813
				) then -- 813
					cutsceneHandled = true -- 814
				end -- 814
				i = i + 1 -- 810
			end -- 810
		end -- 810
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 818
		if not cutsceneHandled and not roguelikeModal then -- 818
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 820
			self.hud:draw( -- 821
				self.uiDraw, -- 822
				self.uiInkDraw, -- 823
				self.uiArt, -- 824
				self.uiGlow, -- 825
				self.texts, -- 826
				p, -- 827
				self.cam, -- 828
				self.vfx, -- 829
				self.narrative.letterbox, -- 830
				uiScale, -- 831
				view.assistHintsEnabled, -- 832
				true, -- 833
				input.inputMode, -- 834
				input.gamepadLayout, -- 835
				self.stageVp.safeUi, -- 836
				input.retryHoldProgress, -- 837
				touchOverlayVisible -- 838
			) -- 838
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 840
			local savedBannerT = self.narrative.bannerT -- 841
			if suppressBanner then -- 841
				self.narrative.bannerT = 0 -- 843
			end -- 843
			self.narrative:draw( -- 845
				self.uiDraw, -- 846
				self.uiInkDraw, -- 847
				self.uiGlow, -- 848
				self.uiArt, -- 849
				self.texts, -- 850
				p, -- 851
				uiW, -- 852
				uiH, -- 853
				view.assistHintsEnabled, -- 854
				input.inputMode, -- 855
				input.gamepadLayout, -- 856
				self.stageVp.safeUi -- 857
			) -- 857
			if suppressBanner then -- 857
				self.narrative.bannerT = savedBannerT -- 860
			end -- 860
		elseif cutsceneHandled then -- 860
			self.narrative:drawCutsceneDialogue( -- 864
				self.uiDraw, -- 865
				self.uiInkDraw, -- 866
				self.uiArt, -- 867
				self.texts, -- 868
				p, -- 869
				uiW, -- 870
				uiH, -- 871
				self.stageVp.safeUi -- 872
			) -- 872
		end -- 872
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 876
		do -- 876
			i = 0 -- 877
			while i < #self.plugins do -- 877
				local pl = self.plugins[i + 1] -- 878
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 878
					self.uiDraw, -- 880
					self.uiInkDraw, -- 880
					self.uiArt, -- 880
					self.uiGlow, -- 880
					ctx -- 880
				) then -- 880
					suppressReticle = true -- 881
				end -- 881
				i = i + 1 -- 877
			end -- 877
		end -- 877
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 877
			self.uiDraw, -- 885
			self.uiInkDraw, -- 885
			self.uiArt, -- 885
			self.uiGlow, -- 885
			ctx -- 885
		) then -- 885
			suppressReticle = true -- 886
		end -- 886
		if not suppressReticle then -- 886
			self.hud:drawReticleOverlay( -- 889
				self.uiInkDraw, -- 890
				self.uiArt, -- 891
				self.uiGlow, -- 892
				p, -- 893
				self.cam, -- 894
				self.vfx, -- 895
				self.narrative.letterbox, -- 896
				uiScale, -- 897
				input:isTouchMode() -- 898
			) -- 898
		end -- 898
		if view.isRehearsal then -- 898
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 904
			drawSilkVeil( -- 905
				self.uiDraw, -- 905
				self.uiArt, -- 905
				"rehearsal_tag_veil", -- 905
				uiW * 0.5, -- 905
				uiH - 22 - self.stageVp.safeUi.top, -- 905
				168, -- 905
				26, -- 905
				PALETTE.inkWarm, -- 905
				0.74, -- 905
				8 -- 905
			) -- 905
			self.texts:put( -- 906
				"xs", -- 906
				badgeText, -- 906
				uiW * 0.5, -- 906
				uiH - 22 - self.stageVp.safeUi.top, -- 906
				toColor(PALETTE.amberCore), -- 906
				0.5, -- 906
				0.5, -- 906
				"Center", -- 906
				1.2, -- 906
				0.92, -- 906
				0.08 -- 906
			) -- 906
		end -- 906
	end -- 906
	self:drawToast(uiW) -- 910
	self:finishFrame() -- 911
	return action -- 912
end -- 575
return ____exports -- 575