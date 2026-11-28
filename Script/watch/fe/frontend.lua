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
			visualTextWidth(self.toastText, 18) + 84 -- 420
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
function WatchFrontend.prototype.tryClickHudPause(self, p, input, w, h) -- 426
	if not input:isKbmMode() or p.paused or p.escortFailed or p.craftBench.active or p.reloadOpen or p.talentModalActive or self.roguelikeUi:isLedgerOpen() or self.narrative.letterbox >= 0.5 then -- 426
		return false -- 429
	end -- 429
	local useUiPtr = input.uiInside or input.uiPressed -- 431
	local ____useUiPtr_2 -- 432
	if useUiPtr then -- 432
		____useUiPtr_2 = input.uiInside -- 432
	else -- 432
		____useUiPtr_2 = input.inside -- 432
	end -- 432
	local inside = ____useUiPtr_2 -- 432
	local ____useUiPtr_3 -- 433
	if useUiPtr then -- 433
		____useUiPtr_3 = input.uiPressed -- 433
	else -- 433
		____useUiPtr_3 = input.fire.pressed -- 433
	end -- 433
	local pressed = ____useUiPtr_3 -- 433
	if not inside or not pressed then -- 433
		return false -- 435
	end -- 435
	local uiScale = math.max( -- 437
		0.25, -- 437
		math.min(w / 1280, h / 720) -- 437
	) -- 437
	local rawX = useUiPtr and input.uiX or input.mx -- 438
	local rawY = useUiPtr and input.uiY or input.my -- 439
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 440
	local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 441
	local rect = self.hud:getChapterPauseRect(w / uiScale, h / uiScale, self.stageVp.safeUi, touchOverlayVisible) -- 442
	return rect.width > 0 and rect:containsPoint(pointer) -- 443
end -- 426
function WatchFrontend.prototype.tryClickWorldPrompt(self, p, input, w, h) -- 447
	if not input:isKbmMode() or p.paused or p.escortFailed or p.craftBench.active or p.reloadOpen or p.talentModalActive or self.roguelikeUi:isLedgerOpen() or self.narrative.letterbox >= 0.5 then -- 447
		return "none" -- 450
	end -- 450
	local hit = self.hud:getInteractPromptHit() -- 452
	if hit == nil then -- 452
		return "none" -- 454
	end -- 454
	local useUiPtr = input.uiInside or input.uiPressed or input.uiHeld -- 456
	local ____useUiPtr_4 -- 457
	if useUiPtr then -- 457
		____useUiPtr_4 = input.uiInside -- 457
	else -- 457
		____useUiPtr_4 = input.inside -- 457
	end -- 457
	local inside = ____useUiPtr_4 -- 457
	local ____useUiPtr_5 -- 458
	if useUiPtr then -- 458
		____useUiPtr_5 = input.uiPressed -- 458
	else -- 458
		____useUiPtr_5 = input.fire.pressed -- 458
	end -- 458
	local pressed = ____useUiPtr_5 -- 458
	local ____useUiPtr_6 -- 459
	if useUiPtr then -- 459
		____useUiPtr_6 = input.uiHeld -- 459
	else -- 459
		____useUiPtr_6 = input.fire.held -- 459
	end -- 459
	local held = ____useUiPtr_6 -- 459
	if not inside then -- 459
		return "none" -- 461
	end -- 461
	if hit.mode == "tap" and not pressed then -- 461
		return "none" -- 464
	end -- 464
	if hit.mode == "hold" and not held and not pressed then -- 464
		return "none" -- 467
	end -- 467
	local uiScale = math.max( -- 469
		0.25, -- 469
		math.min(w / 1280, h / 720) -- 469
	) -- 469
	local rawX = useUiPtr and input.uiX or input.mx -- 470
	local rawY = useUiPtr and input.uiY or input.my -- 471
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 472
	return hit.rect:containsPoint(pointer) and hit.mode or "none" -- 473
end -- 447
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 476
	return not p.escortFailed and not p.paused and not p.craftBench.active and not p.reloadOpen and self.roguelikeUi:canPickTalent() -- 477
end -- 476
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 481
	local offers = p:getStoryTalentOffers() -- 482
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 482
		return {} -- 484
	end -- 484
	local uiScale = math.max( -- 486
		0.25, -- 486
		math.min(w / 1280, h / 720) -- 486
	) -- 486
	return self.hud:talentCardRects( -- 487
		w / uiScale, -- 487
		h / uiScale, -- 487
		#offers, -- 487
		touchMode, -- 487
		self.stageVp.safeUi.top -- 487
	) -- 487
end -- 481
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 491
	if not p.escortFailed then -- 491
		return nil -- 493
	end -- 493
	local uiScale = math.max( -- 495
		0.25, -- 495
		math.min(w / 1280, h / 720) -- 495
	) -- 495
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 496
end -- 491
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 500
	if not p.escortFailed then -- 500
		return "" -- 502
	end -- 502
	if input.inputMode == "gamepad" and not input.uiPressed then -- 502
		return "" -- 505
	end -- 505
	local useUiPtr = input.uiInside or input.uiPressed -- 507
	local ____useUiPtr_7 -- 508
	if useUiPtr then -- 508
		____useUiPtr_7 = input.uiInside -- 508
	else -- 508
		____useUiPtr_7 = input.inside -- 508
	end -- 508
	local inside = ____useUiPtr_7 -- 508
	if not inside then -- 508
		return "" -- 510
	end -- 510
	local uiScale = math.max( -- 512
		0.25, -- 512
		math.min(w / 1280, h / 720) -- 512
	) -- 512
	local rawX = useUiPtr and input.uiX or input.mx -- 513
	local rawY = useUiPtr and input.uiY or input.my -- 514
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 515
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 516
	if btns.retry:containsPoint(pointer) then -- 516
		self.roguelikeUi.deathSelected = 0 -- 518
		return "retry" -- 519
	end -- 519
	if btns.title:containsPoint(pointer) then -- 519
		self.roguelikeUi.deathSelected = 1 -- 522
		return "title" -- 523
	end -- 523
	return "" -- 525
end -- 500
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 528
	if kind == "hover" then -- 528
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 530
	elseif kind == "confirm" then -- 530
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 532
	elseif kind == "back" then -- 532
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 534
	elseif kind == "start" then -- 534
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 536
	elseif kind == "pauseOpen" then -- 536
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 538
	elseif kind == "pauseClose" then -- 538
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 540
	elseif kind == "toggle" then -- 540
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 542
	end -- 542
end -- 528
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 547
	self:syncRuntimeHooks() -- 548
	local safeDt = math.min( -- 549
		0.05, -- 549
		math.max(0, dt) -- 549
	) -- 549
	self.time = self.time + safeDt -- 550
	if self.toastTimer > 0 then -- 550
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 552
	end -- 552
	if self.screen == "title" and self.boundPlay ~= nil then -- 552
		self.audio:stopRoomTransient() -- 555
		self.boundPlay = nil -- 556
	end -- 556
	self.audio:update(safeDt) -- 558
	self.xiaoman3d:hide() -- 559
	self.cam.projection = nil -- 560
	self.soundscape:updateMenu(self.screen, self.audio) -- 561
	self:setVisible(true) -- 562
	self:clearAll() -- 563
	local uiScale = self:resizeInterface(w, h) -- 564
	local act = self.menus:updateAndDrawScreen( -- 565
		dt, -- 566
		self.screen, -- 567
		input, -- 568
		self.stage, -- 569
		self.bgDraw, -- 570
		self.bgGlow, -- 571
		self.backdropArt, -- 572
		self.uiArt, -- 573
		self.uiDraw, -- 574
		self.uiInkDraw, -- 575
		self.uiGlow, -- 576
		self.texts, -- 577
		w, -- 578
		h, -- 579
		uiScale, -- 580
		self.stageVp.safeUi -- 581
	) -- 581
	if self.screen == "title" then -- 581
		self.sceneFx:drawTitleAtmosphere( -- 584
			self.bgGlow, -- 584
			self.fgGlow, -- 584
			self.backdropArt, -- 584
			self.worldArt, -- 584
			w, -- 584
			h, -- 584
			self.time -- 584
		) -- 584
	end -- 584
	self:drawToast(w / uiScale) -- 586
	self:finishFrame() -- 587
	return act -- 588
end -- 547
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 592
	local offers = p:getStoryTalentOffers() -- 593
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 593
		return false -- 595
	end -- 595
	if input.inputMode == "gamepad" and not input.uiPressed then -- 595
		return false -- 598
	end -- 598
	local useUiPtr = input.uiInside or input.uiPressed -- 600
	local ____useUiPtr_8 -- 601
	if useUiPtr then -- 601
		____useUiPtr_8 = input.uiInside -- 601
	else -- 601
		____useUiPtr_8 = input.inside -- 601
	end -- 601
	local inside = ____useUiPtr_8 -- 601
	if not inside then -- 601
		return false -- 603
	end -- 603
	local uiScale = math.max( -- 605
		0.25, -- 605
		math.min(w / 1280, h / 720) -- 605
	) -- 605
	local uiW = w / uiScale -- 606
	local uiH = h / uiScale -- 607
	local rawX = useUiPtr and input.uiX or input.mx -- 608
	local rawY = useUiPtr and input.uiY or input.my -- 609
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 610
	local boxes = self.hud:talentCardRects( -- 611
		uiW, -- 611
		uiH, -- 611
		#offers, -- 611
		input:isTouchMode(), -- 611
		self.stageVp.safeUi.top -- 611
	) -- 611
	local i = 0 -- 612
	do -- 612
		i = 0 -- 613
		while i < #boxes do -- 613
			if boxes[i + 1]:containsPoint(pointer) then -- 613
				return p:chooseTalent(i) -- 615
			end -- 615
			i = i + 1 -- 613
		end -- 613
	end -- 613
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 619
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 620
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 621
end -- 592
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 626
	self:syncRuntimeHooks() -- 627
	self:setVisible(true) -- 628
	if self.boundPlay ~= p then -- 628
		self:bindPlay(p, w, h) -- 630
	end -- 630
	local safeDt = math.min( -- 632
		0.05, -- 632
		math.max(0.001, dt) -- 632
	) -- 632
	if self.toastTimer > 0 then -- 632
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 634
	end -- 634
	self.audio:setPaused(p.paused) -- 636
	self.audio:setCameraRef( -- 637
		self.cam.x, -- 637
		w / math.max(0.25, self.cam.ppu) -- 637
	) -- 637
	self.audio:update(safeDt) -- 638
	local ev -- 640
	local worldDt = 0 -- 641
	local uiDt = 0 -- 642
	if not p.paused then -- 642
		ev = self.adapter:sample(p) -- 646
		self.vfx:ingest(ev, p, self.cam) -- 647
		self.audio:ingestEvents(ev, p) -- 648
		if ev.playerHit then -- 648
			input:vibrate(0.036) -- 650
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 650
			input:vibrate(0.024) -- 652
		elseif ev.coverDeflect then -- 652
			input:vibrate(0.018) -- 654
		elseif ev.knockPulse then -- 654
			input:vibrate(0.014) -- 656
		end -- 656
	else -- 656
		ev = self.adapter:emptyFrame(p) -- 660
		self.narrative.wipeT = 0 -- 661
	end -- 661
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 664
	if not p.paused then -- 664
		local clampedScale = math.max( -- 666
			0, -- 666
			math.min(2, view.timeScale) -- 666
		) -- 666
		uiDt = safeDt -- 667
		worldDt = safeDt * clampedScale -- 668
	end -- 668
	local uiScale = self:resizeInterface(w, h) -- 671
	local uiW = w / uiScale -- 672
	local uiH = h / uiScale -- 673
	local ctx = { -- 675
		p = p, -- 676
		view = view, -- 677
		events = ev, -- 678
		input = input, -- 679
		cam = self.cam, -- 680
		audio = self.audio, -- 681
		assets = self.worldArt, -- 682
		backdropArt = self.backdropArt, -- 683
		worldArt = self.worldArt, -- 684
		uiArt = self.uiArt, -- 685
		uiMask = self.uiMask, -- 686
		dioramaBg = self.dioramaBg, -- 687
		dioramaWorld = self.dioramaWorld, -- 688
		dioramaFg = self.dioramaFg, -- 689
		texts = self.texts, -- 690
		worldDt = worldDt, -- 691
		uiDt = uiDt, -- 692
		w = w, -- 693
		h = h, -- 694
		uiW = uiW, -- 695
		uiH = uiH, -- 696
		uiScale = uiScale, -- 697
		safeUi = self.stageVp.safeUi, -- 698
		paused = p.paused -- 699
	} -- 699
	local i = 0 -- 703
	do -- 703
		i = 0 -- 704
		while i < #self.plugins do -- 704
			local pl = self.plugins[i + 1] -- 705
			if pl.update ~= nil then -- 705
				pl:update(ctx) -- 707
			end -- 707
			i = i + 1 -- 704
		end -- 704
	end -- 704
	self.roguelikeUi:update(ctx) -- 710
	if not p.paused then -- 710
		self.time = self.time + worldDt -- 713
		self.cam:update(worldDt, p, w, h) -- 714
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 715
		self.audio:setCameraRef( -- 716
			self.cam.x, -- 716
			w / math.max(0.25, self.cam.ppu) -- 716
		) -- 716
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 717
		self.actors:update(worldDt, p) -- 718
		self.vfx:ingestFootsteps(self.actors:drainFootsteps()) -- 719
		if view.visualMode == "pixel" then -- 719
			self.sceneFx:update(worldDt, p, self.cam) -- 721
		end -- 721
		self.vfx:update( -- 723
			worldDt, -- 723
			themeOf(p.room.key).ambient -- 723
		) -- 723
		self.hud:update(safeDt, p) -- 724
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 725
	else -- 725
		self.cam:update(0, p, w, h) -- 727
	end -- 727
	self:clearAll() -- 730
	local use3D = self.xiaoman3d:supports(p, view.visualMode) -- 732
	if use3D then -- 732
		self.xiaoman3d:render( -- 734
			p, -- 734
			self.cam, -- 734
			self.actors, -- 734
			worldDt, -- 734
			w, -- 734
			h, -- 734
			self.stageVp, -- 734
			self.worldOverlayDraw -- 734
		) -- 734
	else -- 734
		self.xiaoman3d:hide() -- 736
		self.cam.projection = nil -- 737
		local backdropHandled = false -- 740
		do -- 740
			i = 0 -- 741
			while i < #self.plugins do -- 741
				local pl = self.plugins[i + 1] -- 742
				if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 742
					backdropHandled = true -- 744
				end -- 744
				i = i + 1 -- 741
			end -- 741
		end -- 741
		if not backdropHandled then -- 741
			self.stage:drawBackdrop( -- 748
				self.bgDraw, -- 748
				self.bgGlow, -- 748
				self.backdropArt, -- 748
				p, -- 748
				self.cam, -- 748
				self.time -- 748
			) -- 748
		end -- 748
		if view.visualMode == "pixel" then -- 748
			self.escortWorld:drawBackdropOverlay( -- 751
				self.bgDraw, -- 751
				self.bgGlow, -- 751
				self.backdropArt, -- 751
				p, -- 751
				self.cam, -- 751
				self.time, -- 751
				self.escortTowerDraw -- 751
			) -- 751
			self.sceneFx:drawBackdropFx( -- 752
				self.bgDraw, -- 752
				self.bgGlow, -- 752
				self.backdropArt, -- 752
				p, -- 752
				self.cam -- 752
			) -- 752
		end -- 752
		local worldHandled = false -- 756
		do -- 756
			i = 0 -- 757
			while i < #self.plugins do -- 757
				local pl = self.plugins[i + 1] -- 758
				if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 758
					worldHandled = true -- 760
				end -- 760
				i = i + 1 -- 757
			end -- 757
		end -- 757
		if not worldHandled then -- 757
			self.stage:drawPlayableWorld( -- 764
				self.groundDraw, -- 765
				self.fgGlow, -- 766
				self.worldArt, -- 767
				p, -- 768
				self.cam, -- 769
				self.time, -- 770
				self.occlusion, -- 771
				worldDt, -- 772
				self.groundArt, -- 773
				self.fgDraw, -- 774
				self.worldOverlayDraw -- 775
			) -- 775
		end -- 775
		local propsHandled = false -- 780
		do -- 780
			i = 0 -- 781
			while i < #self.plugins do -- 781
				local pl = self.plugins[i + 1] -- 782
				if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 782
					propsHandled = true -- 784
				end -- 784
				i = i + 1 -- 781
			end -- 781
		end -- 781
		if not propsHandled then -- 781
			self.props:drawAll( -- 788
				self.fgDraw, -- 788
				self.fgGlow, -- 788
				self.worldArt, -- 788
				p, -- 788
				self.cam, -- 788
				self.time, -- 788
				self.occlusion, -- 788
				worldDt, -- 788
				self.groundArt -- 788
			) -- 788
		end -- 788
		if view.visualMode == "pixel" then -- 788
			self.escortWorld:drawWorldSetpieces( -- 791
				self.fgDraw, -- 791
				self.fgGlow, -- 791
				self.worldArt, -- 791
				p, -- 791
				view, -- 791
				self.cam, -- 791
				self.time -- 791
			) -- 791
			self.sceneFx:drawWorldFx( -- 792
				self.fgDraw, -- 792
				self.fgGlow, -- 792
				self.worldArt, -- 792
				p, -- 792
				self.cam -- 792
			) -- 792
		end -- 792
		if view.visualMode ~= "museum" then -- 792
			local pose -- 797
			for ____, pl in ipairs(self.plugins) do -- 798
				if pl.drawPartyPose ~= nil then -- 798
					pose = pl:drawPartyPose(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 800
					if pose ~= nil then -- 800
						break -- 801
					end -- 801
				end -- 801
			end -- 801
			self.actors:drawAll( -- 804
				self.worldOverlayDraw, -- 804
				self.fgGlow, -- 804
				self.worldArt, -- 804
				p, -- 804
				self.cam, -- 804
				pose -- 804
			) -- 804
		end -- 804
		do -- 804
			i = 0 -- 806
			while i < #self.plugins do -- 806
				local pl = self.plugins[i + 1] -- 807
				if pl.drawActorsOverlay ~= nil then -- 807
					pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 809
				end -- 809
				i = i + 1 -- 806
			end -- 806
		end -- 806
		self.roguelikeUi:drawActorsOverlay(self.worldOverlayDraw, self.fgGlow, self.worldArt, ctx) -- 812
		self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam, p.room.depth ~= nil) -- 815
		if view.visualMode == "pixel" then -- 815
			self.stage:drawForegroundFraming( -- 819
				self.worldOverlayDraw, -- 819
				w, -- 819
				h, -- 819
				p, -- 819
				self.cam -- 819
			) -- 819
			self.escortWorld:drawForegroundFraming( -- 820
				self.worldOverlayDraw, -- 820
				self.fgGlow, -- 820
				self.worldArt, -- 820
				p, -- 820
				self.cam, -- 820
				self.time -- 820
			) -- 820
			self.sceneFx:drawForegroundWeather( -- 821
				self.fgGlow, -- 821
				p, -- 821
				self.cam, -- 821
				w, -- 821
				h -- 821
			) -- 821
		end -- 821
	end -- 821
	self.vfx:drawScreenVfx( -- 824
		self.fgGlow, -- 824
		w, -- 824
		h, -- 824
		p.room.key, -- 824
		view.visualMode ~= "pixel" -- 824
	) -- 824
	local action = {type = "none"} -- 827
	if p.paused then -- 827
		local canSaveCurrent = p.run.source == "official" and not p.run.finished and p.room.key ~= "museum" and not (p.room.key == "tower" and p.phase == "tower-end") -- 829
		action = self.menus:updateAndDrawPause( -- 833
			safeDt, -- 834
			input, -- 835
			self.uiDraw, -- 836
			self.uiInkDraw, -- 837
			self.uiArt, -- 838
			self.uiGlow, -- 839
			self.texts, -- 840
			uiW, -- 841
			uiH, -- 842
			uiScale, -- 843
			view.assistHintsEnabled, -- 844
			function() -- 845
				local next = self.contract:toggleAssistHints() -- 846
				input.settings.assistHints = next -- 847
				saveControlSettings(input.settings) -- 848
			end, -- 845
			self.stageVp.safeUi, -- 850
			p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom(), -- 851
			view.roguelike.active, -- 852
			function() -- 853
				self.roguelikeUi:openLedger() -- 854
			end, -- 853
			canSaveCurrent -- 856
		) -- 856
	else -- 856
		local cutsceneHandled = false -- 860
		do -- 860
			i = 0 -- 861
			while i < #self.plugins do -- 861
				local pl = self.plugins[i + 1] -- 862
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 862
					self.uiDraw, -- 864
					self.uiInkDraw, -- 864
					self.uiArt, -- 864
					self.uiGlow, -- 864
					ctx -- 864
				) then -- 864
					cutsceneHandled = true -- 865
				end -- 865
				i = i + 1 -- 861
			end -- 861
		end -- 861
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 869
		if not cutsceneHandled and not roguelikeModal then -- 869
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 871
			local useHudPtr = input.uiInside or input.uiPressed or input.uiHeld -- 872
			local ____useHudPtr_9 -- 873
			if useHudPtr then -- 873
				____useHudPtr_9 = input.uiInside -- 873
			else -- 873
				____useHudPtr_9 = input.inside -- 873
			end -- 873
			local hudPtrInside = ____useHudPtr_9 -- 873
			local hudPtr = Vec2((useHudPtr and input.uiX or input.mx) / uiScale, (useHudPtr and input.uiY or input.my) / uiScale) -- 874
			self.hud:draw( -- 875
				self.uiDraw, -- 876
				self.uiInkDraw, -- 877
				self.uiArt, -- 878
				self.uiGlow, -- 879
				self.texts, -- 880
				p, -- 881
				self.cam, -- 882
				self.vfx, -- 883
				self.narrative.letterbox, -- 884
				uiScale, -- 885
				view.assistHintsEnabled, -- 886
				true, -- 887
				input.inputMode, -- 888
				input.gamepadLayout, -- 889
				self.stageVp.safeUi, -- 890
				input.retryHoldProgress, -- 891
				touchOverlayVisible, -- 892
				hudPtr, -- 893
				hudPtrInside -- 894
			) -- 894
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 896
			local savedBannerT = self.narrative.bannerT -- 897
			if suppressBanner then -- 897
				self.narrative.bannerT = 0 -- 899
			end -- 899
			self.narrative:draw( -- 901
				self.uiDraw, -- 902
				self.uiInkDraw, -- 903
				self.uiGlow, -- 904
				self.uiArt, -- 905
				self.texts, -- 906
				p, -- 907
				uiW, -- 908
				uiH, -- 909
				view.assistHintsEnabled, -- 910
				input.inputMode, -- 911
				input.gamepadLayout, -- 912
				self.stageVp.safeUi -- 913
			) -- 913
			if suppressBanner then -- 913
				self.narrative.bannerT = savedBannerT -- 916
			end -- 916
		elseif cutsceneHandled then -- 916
			self.narrative:drawCutsceneDialogue( -- 920
				self.uiDraw, -- 921
				self.uiInkDraw, -- 922
				self.uiArt, -- 923
				self.texts, -- 924
				p, -- 925
				uiW, -- 926
				uiH, -- 927
				self.stageVp.safeUi -- 928
			) -- 928
		end -- 928
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 932
		do -- 932
			i = 0 -- 933
			while i < #self.plugins do -- 933
				local pl = self.plugins[i + 1] -- 934
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 934
					self.uiDraw, -- 936
					self.uiInkDraw, -- 936
					self.uiArt, -- 936
					self.uiGlow, -- 936
					ctx -- 936
				) then -- 936
					suppressReticle = true -- 937
				end -- 937
				i = i + 1 -- 933
			end -- 933
		end -- 933
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 933
			self.uiDraw, -- 941
			self.uiInkDraw, -- 941
			self.uiArt, -- 941
			self.uiGlow, -- 941
			ctx -- 941
		) then -- 941
			suppressReticle = true -- 942
		end -- 942
		if not suppressReticle then -- 942
			self.hud:drawReticleOverlay( -- 945
				self.uiInkDraw, -- 946
				self.uiArt, -- 947
				self.uiGlow, -- 948
				p, -- 949
				self.cam, -- 950
				self.vfx, -- 951
				self.narrative.letterbox, -- 952
				uiScale, -- 953
				input:isTouchMode() -- 954
			) -- 954
		end -- 954
		if view.isRehearsal then -- 954
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 960
			drawSilkVeil( -- 961
				self.uiDraw, -- 961
				self.uiArt, -- 961
				"rehearsal_tag_veil", -- 961
				uiW * 0.5, -- 961
				uiH - 22 - self.stageVp.safeUi.top, -- 961
				168, -- 961
				26, -- 961
				PALETTE.inkWarm, -- 961
				0.74, -- 961
				8 -- 961
			) -- 961
			self.texts:put( -- 962
				"xs", -- 962
				badgeText, -- 962
				uiW * 0.5, -- 962
				uiH - 22 - self.stageVp.safeUi.top, -- 962
				toColor(PALETTE.amberCore), -- 962
				0.5, -- 962
				0.5, -- 962
				"Center", -- 962
				1.2, -- 962
				0.92, -- 962
				0.08 -- 962
			) -- 962
		end -- 962
	end -- 962
	self:drawToast(uiW) -- 966
	self:finishFrame() -- 967
	return action -- 968
end -- 626
return ____exports -- 626