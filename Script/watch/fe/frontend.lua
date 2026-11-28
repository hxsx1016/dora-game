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
local ____bgm = require("Script.watch.fe.bgm") -- 19
local SoundscapeDirector = ____bgm.SoundscapeDirector -- 19
local ____camera = require("Script.watch.fe.camera") -- 20
local CameraDirector = ____camera.CameraDirector -- 20
local ____contract = require("Script.watch.fe.contract") -- 21
local DualRouteContract = ____contract.DualRouteContract -- 21
local ____occlusion = require("Script.watch.fe.occlusion") -- 22
local DepthOcclusion = ____occlusion.DepthOcclusion -- 22
local ____stage = require("Script.watch.fe.renderer.stage") -- 24
local StageRenderer = ____stage.StageRenderer -- 24
local ____props = require("Script.watch.fe.renderer.props") -- 25
local PropsRenderer = ____props.PropsRenderer -- 25
local ____actors = require("Script.watch.fe.renderer.actors") -- 26
local ActorsRenderer = ____actors.ActorsRenderer -- 26
local ____diorama_grid = require("Script.watch.fe.renderer.diorama_grid") -- 27
local DioramaLayerHost = ____diorama_grid.DioramaLayerHost -- 27
local ____scene_fx = require("Script.watch.fe.renderer.scene_fx") -- 28
local SceneFxSystem = ____scene_fx.SceneFxSystem -- 28
local ____vfx = require("Script.watch.fe.renderer.vfx") -- 29
local VfxSystem = ____vfx.VfxSystem -- 29
local ____escort_world = require("Script.watch.fe.scenes.escort_world") -- 30
local EscortWorldRenderer = ____escort_world.EscortWorldRenderer -- 30
local ____second_half_assets = require("Script.watch.fe.scenes.second_half_assets") -- 31
local ensureSecondHalfAssetsRegistered = ____second_half_assets.ensureSecondHalfAssetsRegistered -- 31
local ____dark_pixel_assets = require("Script.watch.fe.scenes.dark_pixel_assets") -- 32
local ensureDarkPixelAssetsRegistered = ____dark_pixel_assets.ensureDarkPixelAssetsRegistered -- 32
local ____textpool = require("Script.watch.fe.ui.textpool") -- 33
local TextPool = ____textpool.TextPool -- 33
local ____hud = require("Script.watch.fe.ui.hud") -- 34
local HudRenderer = ____hud.HudRenderer -- 34
local ____narrative = require("Script.watch.fe.ui.narrative") -- 35
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 35
local ____menus = require("Script.watch.fe.ui.menus") -- 36
local MenuRenderer = ____menus.MenuRenderer -- 36
local ____theme = require("Script.watch.fe.theme") -- 37
local PALETTE = ____theme.PALETTE -- 37
local drawSilkVeil = ____theme.drawSilkVeil -- 37
local themeOf = ____theme.themeOf -- 37
local toColor = ____theme.toColor -- 37
local ____ming_audit = require("Script.watch.fe.renderer.ming_audit") -- 38
local MingArtAuditPlugin = ____ming_audit.MingArtAuditPlugin -- 38
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 39
local GateTransitionPlugin = ____gate_transition.GateTransitionPlugin -- 39
local ____xiaoman3d = require("Script.watch.fe.scenes.xiaoman3d") -- 40
local Xiaoman3DScene = ____xiaoman3d.Xiaoman3DScene -- 40
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 41
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 41
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 42
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 42
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 43
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 43
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 44
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 44
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 45
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 45
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 46
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 46
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 47
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 47
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 48
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 48
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 49
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 49
local ____roguelike_ui = require("Script.watch.fe.ui.roguelike_ui") -- 50
local computeEscortDeathButtons = ____roguelike_ui.computeEscortDeathButtons -- 50
local RoguelikeUiPlugin = ____roguelike_ui.RoguelikeUiPlugin -- 50
____exports.WatchFrontend = __TS__Class() -- 52
local WatchFrontend = ____exports.WatchFrontend -- 52
WatchFrontend.name = "WatchFrontend" -- 52
function WatchFrontend.prototype.____constructor(self, parent) -- 102
	self.occlusion = __TS__New(DepthOcclusion) -- 53
	self.cam = __TS__New(CameraDirector) -- 76
	self.adapter = __TS__New(PlayAdapter) -- 77
	self.contract = __TS__New( -- 78
		DualRouteContract, -- 78
		function(p) return self:canPickStoryTalent(p) end -- 78
	) -- 78
	self.audio = __TS__New(AudioDirector) -- 79
	self.soundscape = __TS__New(SoundscapeDirector) -- 80
	self.stage = __TS__New(StageRenderer) -- 81
	self.escortWorld = __TS__New(EscortWorldRenderer) -- 82
	self.props = __TS__New(PropsRenderer) -- 83
	self.actors = __TS__New(ActorsRenderer) -- 84
	self.sceneFx = __TS__New(SceneFxSystem) -- 85
	self.vfx = __TS__New(VfxSystem) -- 86
	self.hud = __TS__New(HudRenderer) -- 87
	self.narrative = __TS__New(NarrativeRenderer) -- 88
	self.menus = __TS__New(MenuRenderer) -- 89
	self.plugins = {} -- 92
	self.screen = "title" -- 95
	self.time = 0 -- 96
	self.stageVp = computeStageViewport(1280, 720) -- 98
	self.toastText = "" -- 99
	self.toastTimer = 0 -- 100
	self.layerRoot = Node() -- 103
	self.layerRoot.order = 5 -- 104
	self.layerRoot:addTo(parent) -- 105
	ensureSecondHalfAssetsRegistered() -- 106
	ensureDarkPixelAssetsRegistered() -- 107
	self.xiaoman3d = __TS__New(Xiaoman3DScene, self.layerRoot) -- 108
	self.audio:attachHost(self.layerRoot) -- 110
	self.menus.onUiSound = function(____, kind) -- 111
		self:playMenuUiSound(kind) -- 112
	end -- 111
	self.menus.onAudioSettingsChanged = function(____, inp) -- 114
		self.audio:applyUserVolumes(inp.settings) -- 115
	end -- 114
	local additive = BlendFunc("SrcAlpha", "One") -- 118
	self.bgDraw = DrawNode() -- 120
	self.bgDraw.order = 10 -- 121
	self.bgDraw:addTo(self.layerRoot) -- 122
	self.escortTowerDraw = DrawNode() -- 125
	self.escortTowerDraw.order = 13 -- 126
	self.escortTowerDraw:addTo(self.layerRoot) -- 127
	self.bgGlow = DrawNode() -- 129
	self.bgGlow.order = 15 -- 130
	self.bgGlow.blendFunc = additive -- 131
	self.bgGlow:addTo(self.layerRoot) -- 132
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 134
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 135
	self.groundDraw = DrawNode() -- 137
	self.groundDraw.order = 20 -- 138
	self.groundDraw:addTo(self.layerRoot) -- 139
	self.groundArt = __TS__New(AssetSlotHost, self.layerRoot, 22) -- 140
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 141
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 142
	self.worldOverlayDraw = DrawNode() -- 143
	self.worldOverlayDraw.order = 33 -- 144
	self.worldOverlayDraw:addTo(self.layerRoot) -- 145
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 146
	self.fgDraw = DrawNode() -- 148
	self.fgDraw.order = 30 -- 149
	self.fgDraw:addTo(self.layerRoot) -- 150
	self.fgGlow = DrawNode() -- 152
	self.fgGlow.order = 35 -- 153
	self.fgGlow.blendFunc = additive -- 154
	self.fgGlow:addTo(self.layerRoot) -- 155
	self.uiLayer = Node() -- 157
	self.uiLayer.order = 40 -- 158
	self.uiLayer:addTo(self.layerRoot) -- 159
	self.uiDraw = DrawNode() -- 161
	self.uiDraw.order = 0 -- 162
	self.uiDraw:addTo(self.uiLayer) -- 163
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 165
	self.uiInkDraw = DrawNode() -- 167
	self.uiInkDraw.order = 4 -- 168
	self.uiInkDraw:addTo(self.uiLayer) -- 169
	self.uiGlow = DrawNode() -- 171
	self.uiGlow.order = 6 -- 172
	self.uiGlow.blendFunc = additive -- 173
	self.uiGlow:addTo(self.uiLayer) -- 174
	self.uiMask = DrawNode() -- 176
	self.uiMask.order = 8 -- 177
	self.uiMask:addTo(self.uiLayer) -- 178
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 180
	self.roguelikeUi = __TS__New( -- 184
		RoguelikeUiPlugin, -- 184
		self.contract, -- 185
		function() return self.hud.talentSelected end, -- 186
		function(idx) -- 187
			self.hud.talentSelected = idx -- 188
		end -- 187
	) -- 187
	self.hud.roguelikeUiHandled = true -- 191
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) return self.roguelikeUi:getTalentCardRects( -- 192
		w, -- 193
		h, -- 193
		count, -- 193
		touchMode, -- 193
		safeTop -- 193
	) end -- 193
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 207
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 208
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 209
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 210
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 211
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 212
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 213
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 214
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 215
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 216
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 217
end -- 102
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 221
	local i = 0 -- 222
	do -- 222
		i = 0 -- 223
		while i < #self.plugins do -- 223
			if self.plugins[i + 1].id == plugin.id then -- 223
				self.plugins[i + 1] = plugin -- 225
				self:syncRuntimeHooks() -- 226
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 226
					plugin:onBindPlay( -- 228
						self.boundPlay, -- 228
						self.contract:peekSnapshot(self.boundPlay) -- 228
					) -- 228
				end -- 228
				return -- 230
			end -- 230
			i = i + 1 -- 223
		end -- 223
	end -- 223
	local ____self_plugins_0 = self.plugins -- 223
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 233
	self:syncRuntimeHooks() -- 234
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 234
		plugin:onBindPlay( -- 236
			self.boundPlay, -- 236
			self.contract:peekSnapshot(self.boundPlay) -- 236
		) -- 236
	end -- 236
end -- 221
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 241
	local w = 0 -- 242
	local i = 0 -- 243
	do -- 243
		i = 0 -- 244
		while i < #self.plugins do -- 244
			if self.plugins[i + 1].id ~= id then -- 244
				self.plugins[w + 1] = self.plugins[i + 1] -- 246
				w = w + 1 -- 247
			end -- 247
			i = i + 1 -- 244
		end -- 244
	end -- 244
	__TS__ArraySetLength(self.plugins, w) -- 244
	self:syncRuntimeHooks() -- 251
end -- 241
function WatchFrontend.prototype.getPlugin(self, id) -- 255
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 255
		return self.roguelikeUi -- 257
	end -- 257
	local i = 0 -- 259
	do -- 259
		i = 0 -- 260
		while i < #self.plugins do -- 260
			if self.plugins[i + 1].id == id then -- 260
				return self.plugins[i + 1] -- 262
			end -- 262
			i = i + 1 -- 260
		end -- 260
	end -- 260
	return nil -- 265
end -- 255
function WatchFrontend.prototype.getPlugins(self) -- 268
	return self.plugins -- 269
end -- 268
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 277
	local g = _G -- 278
	local ____temp_1 -- 279
	if g.package ~= nil then -- 279
		____temp_1 = g.package.loaded -- 279
	else -- 279
		____temp_1 = nil -- 279
	end -- 279
	local loaded = ____temp_1 -- 279
	if loaded == nil then -- 279
		return -- 281
	end -- 281
	local rawFe = loaded["watch.fe"] -- 283
	if rawFe ~= nil and type(rawFe) == "table" then -- 283
		local watchFe = rawFe -- 285
		if watchFe.contract ~= self.contract then -- 285
			watchFe.contract = self.contract -- 287
			watchFe.audio = self.audio -- 288
			watchFe.soundscape = self.soundscape -- 289
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 290
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 291
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 292
		end -- 292
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 294
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 295
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 296
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 297
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 298
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 299
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 300
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 301
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 302
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 303
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 304
		watchFe.roguelikeUi = self.roguelikeUi -- 305
	end -- 305
end -- 277
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 309
	local scale = math.max( -- 310
		0.25, -- 310
		math.min(w / 1280, h / 720) -- 310
	) -- 310
	self.uiLayer.scaleX = scale -- 311
	self.uiLayer.scaleY = scale -- 312
	return scale -- 313
end -- 309
function WatchFrontend.prototype.setVisible(self, v) -- 317
	self.layerRoot.visible = v -- 318
	if not v then -- 318
		self.xiaoman3d:hide() -- 320
		self.cam.projection = nil -- 321
		self.texts:hideAll() -- 322
	end -- 322
end -- 317
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 327
	self:syncRuntimeHooks() -- 328
	self.boundPlay = p -- 329
	p.useEscortDeathSummary = true -- 330
	p:openTalentDraft() -- 331
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 332
	self.xiaoman3d:hide() -- 333
	self.cam.projection = nil -- 334
	self.cam:snap(p, w, h) -- 335
	self.adapter:reset(p) -- 336
	self.contract:resetForRoom(p) -- 337
	self.audio:stopRoomTransient() -- 338
	self.soundscape:resetForRoom(p) -- 339
	self.actors:reset(p) -- 340
	self.sceneFx:reset(p.room.key) -- 341
	self.occlusion:reset() -- 342
	self.vfx:reset() -- 343
	self.hud:reset(p) -- 344
	self.narrative:onEnterRoom(p.room.key) -- 345
	local initView = self.contract:peekSnapshot(p) -- 347
	if #self.plugins > 0 then -- 347
		local i = 0 -- 349
		do -- 349
			i = 0 -- 350
			while i < #self.plugins do -- 350
				local pl = self.plugins[i + 1] -- 351
				if pl.onBindPlay ~= nil then -- 351
					pl:onBindPlay(p, initView) -- 353
				end -- 353
				i = i + 1 -- 350
			end -- 350
		end -- 350
	end -- 350
	self.roguelikeUi:onBindPlay(p, initView) -- 357
end -- 327
function WatchFrontend.prototype.clearAll(self) -- 360
	self.bgDraw:clear() -- 361
	self.escortTowerDraw:clear() -- 362
	self.bgGlow:clear() -- 363
	self.groundDraw:clear() -- 364
	self.fgDraw:clear() -- 365
	self.worldOverlayDraw:clear() -- 366
	self.fgGlow:clear() -- 367
	self.uiDraw:clear() -- 368
	self.uiInkDraw:clear() -- 369
	self.uiGlow:clear() -- 370
	self.uiMask:clear() -- 371
	self.backdropArt:beginFrame() -- 372
	self.groundArt:beginFrame() -- 373
	self.dioramaBg:beginFrame() -- 374
	self.dioramaWorld:beginFrame() -- 375
	self.dioramaFg:beginFrame() -- 376
	self.worldArt:beginFrame() -- 377
	self.uiArt:beginFrame() -- 378
	self.texts:beginFrame() -- 379
end -- 360
function WatchFrontend.prototype.finishFrame(self) -- 382
	self.backdropArt:endFrame() -- 383
	self.groundArt:endFrame() -- 384
	self.dioramaBg:endFrame() -- 385
	self.dioramaWorld:endFrame() -- 386
	self.dioramaFg:endFrame() -- 387
	self.worldArt:endFrame() -- 388
	self.uiArt:endFrame() -- 389
	self.texts:endFrame() -- 390
end -- 382
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 394
	self.stageVp = vp -- 395
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 396
end -- 394
function WatchFrontend.prototype.showToast(self, text, duration) -- 400
	if duration == nil then -- 400
		duration = 1.8 -- 400
	end -- 400
	self.toastText = text -- 401
	self.toastTimer = duration -- 402
end -- 400
function WatchFrontend.prototype.getToastText(self) -- 405
	return self.toastTimer > 0 and self.toastText or "" -- 406
end -- 405
function WatchFrontend.prototype.drawToast(self, uiW) -- 409
	if self.toastTimer <= 0 or self.toastText == "" then -- 409
		return -- 411
	end -- 411
	local alpha = math.min(1, self.toastTimer * 2.4) -- 413
	local cx = uiW * 0.5 -- 414
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 415
	drawSilkVeil( -- 416
		self.uiDraw, -- 416
		self.uiArt, -- 416
		"fe_toast_veil", -- 416
		cx, -- 416
		cy, -- 416
		340, -- 416
		38, -- 416
		PALETTE.inkWarm, -- 416
		0.86 * alpha, -- 416
		9 -- 416
	) -- 416
	self.texts:put( -- 417
		"sm", -- 417
		self.toastText, -- 417
		cx, -- 417
		cy, -- 417
		toColor(PALETTE.amberCore), -- 417
		0.5, -- 417
		0.5, -- 417
		"Center", -- 417
		1.4, -- 417
		0.96 * alpha, -- 417
		0.08 -- 417
	) -- 417
end -- 409
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 420
	return not p.escortFailed and not p.paused and not p.craftBench.active and not p.reloadOpen and self.roguelikeUi:canPickTalent() -- 421
end -- 420
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 425
	local offers = p:getStoryTalentOffers() -- 426
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 426
		return {} -- 428
	end -- 428
	local uiScale = math.max( -- 430
		0.25, -- 430
		math.min(w / 1280, h / 720) -- 430
	) -- 430
	return self.hud:talentCardRects( -- 431
		w / uiScale, -- 431
		h / uiScale, -- 431
		#offers, -- 431
		touchMode, -- 431
		self.stageVp.safeUi.top -- 431
	) -- 431
end -- 425
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 435
	if not p.escortFailed then -- 435
		return nil -- 437
	end -- 437
	local uiScale = math.max( -- 439
		0.25, -- 439
		math.min(w / 1280, h / 720) -- 439
	) -- 439
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 440
end -- 435
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 444
	if not p.escortFailed then -- 444
		return "" -- 446
	end -- 446
	if input.inputMode == "gamepad" and not input.uiPressed then -- 446
		return "" -- 449
	end -- 449
	local useUiPtr = input.uiInside or input.uiPressed -- 451
	local ____useUiPtr_2 -- 452
	if useUiPtr then -- 452
		____useUiPtr_2 = input.uiInside -- 452
	else -- 452
		____useUiPtr_2 = input.inside -- 452
	end -- 452
	local inside = ____useUiPtr_2 -- 452
	if not inside then -- 452
		return "" -- 454
	end -- 454
	local uiScale = math.max( -- 456
		0.25, -- 456
		math.min(w / 1280, h / 720) -- 456
	) -- 456
	local rawX = useUiPtr and input.uiX or input.mx -- 457
	local rawY = useUiPtr and input.uiY or input.my -- 458
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 459
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 460
	if btns.retry:containsPoint(pointer) then -- 460
		self.roguelikeUi.deathSelected = 0 -- 462
		return "retry" -- 463
	end -- 463
	if btns.title:containsPoint(pointer) then -- 463
		self.roguelikeUi.deathSelected = 1 -- 466
		return "title" -- 467
	end -- 467
	return "" -- 469
end -- 444
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 472
	if kind == "hover" then -- 472
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 474
	elseif kind == "confirm" then -- 474
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 476
	elseif kind == "back" then -- 476
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 478
	elseif kind == "start" then -- 478
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 480
	elseif kind == "pauseOpen" then -- 480
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 482
	elseif kind == "pauseClose" then -- 482
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 484
	elseif kind == "toggle" then -- 484
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 486
	end -- 486
end -- 472
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 491
	self:syncRuntimeHooks() -- 492
	local safeDt = math.min( -- 493
		0.05, -- 493
		math.max(0, dt) -- 493
	) -- 493
	self.time = self.time + safeDt -- 494
	if self.toastTimer > 0 then -- 494
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 496
	end -- 496
	if self.screen == "title" and self.boundPlay ~= nil then -- 496
		self.audio:stopRoomTransient() -- 499
		self.boundPlay = nil -- 500
	end -- 500
	self.audio:update(safeDt) -- 502
	self.xiaoman3d:hide() -- 503
	self.cam.projection = nil -- 504
	self.soundscape:updateMenu(self.screen, self.audio) -- 505
	self:setVisible(true) -- 506
	self:clearAll() -- 507
	local uiScale = self:resizeInterface(w, h) -- 508
	local act = self.menus:updateAndDrawScreen( -- 509
		dt, -- 510
		self.screen, -- 511
		input, -- 512
		self.stage, -- 513
		self.bgDraw, -- 514
		self.bgGlow, -- 515
		self.backdropArt, -- 516
		self.uiArt, -- 517
		self.uiDraw, -- 518
		self.uiInkDraw, -- 519
		self.uiGlow, -- 520
		self.texts, -- 521
		w, -- 522
		h, -- 523
		uiScale, -- 524
		self.stageVp.safeUi -- 525
	) -- 525
	if self.screen == "title" then -- 525
		self.sceneFx:drawTitleAtmosphere( -- 528
			self.bgGlow, -- 528
			self.fgGlow, -- 528
			self.backdropArt, -- 528
			self.worldArt, -- 528
			w, -- 528
			h, -- 528
			self.time -- 528
		) -- 528
	end -- 528
	self:drawToast(w / uiScale) -- 530
	self:finishFrame() -- 531
	return act -- 532
end -- 491
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 536
	local offers = p:getStoryTalentOffers() -- 537
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 537
		return false -- 539
	end -- 539
	if input.inputMode == "gamepad" and not input.uiPressed then -- 539
		return false -- 542
	end -- 542
	local useUiPtr = input.uiInside or input.uiPressed -- 544
	local ____useUiPtr_3 -- 545
	if useUiPtr then -- 545
		____useUiPtr_3 = input.uiInside -- 545
	else -- 545
		____useUiPtr_3 = input.inside -- 545
	end -- 545
	local inside = ____useUiPtr_3 -- 545
	if not inside then -- 545
		return false -- 547
	end -- 547
	local uiScale = math.max( -- 549
		0.25, -- 549
		math.min(w / 1280, h / 720) -- 549
	) -- 549
	local uiW = w / uiScale -- 550
	local uiH = h / uiScale -- 551
	local rawX = useUiPtr and input.uiX or input.mx -- 552
	local rawY = useUiPtr and input.uiY or input.my -- 553
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 554
	local boxes = self.hud:talentCardRects( -- 555
		uiW, -- 555
		uiH, -- 555
		#offers, -- 555
		input:isTouchMode(), -- 555
		self.stageVp.safeUi.top -- 555
	) -- 555
	local i = 0 -- 556
	do -- 556
		i = 0 -- 557
		while i < #boxes do -- 557
			if boxes[i + 1]:containsPoint(pointer) then -- 557
				return p:chooseTalent(i) -- 559
			end -- 559
			i = i + 1 -- 557
		end -- 557
	end -- 557
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 563
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 564
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 565
end -- 536
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 570
	self:syncRuntimeHooks() -- 571
	self:setVisible(true) -- 572
	if self.boundPlay ~= p then -- 572
		self:bindPlay(p, w, h) -- 574
	end -- 574
	local safeDt = math.min( -- 576
		0.05, -- 576
		math.max(0.001, dt) -- 576
	) -- 576
	if self.toastTimer > 0 then -- 576
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 578
	end -- 578
	self.audio:setPaused(p.paused) -- 580
	self.audio:setCameraRef( -- 581
		self.cam.x, -- 581
		w / math.max(0.25, self.cam.ppu) -- 581
	) -- 581
	self.audio:update(safeDt) -- 582
	local ev -- 584
	local worldDt = 0 -- 585
	local uiDt = 0 -- 586
	if not p.paused then -- 586
		ev = self.adapter:sample(p) -- 590
		self.vfx:ingest(ev, p, self.cam) -- 591
		self.audio:ingestEvents(ev, p) -- 592
		if ev.playerHit then -- 592
			input:vibrate(0.036) -- 594
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 594
			input:vibrate(0.024) -- 596
		elseif ev.coverDeflect then -- 596
			input:vibrate(0.018) -- 598
		elseif ev.knockPulse then -- 598
			input:vibrate(0.014) -- 600
		end -- 600
	else -- 600
		ev = self.adapter:emptyFrame(p) -- 604
		self.narrative.wipeT = 0 -- 605
	end -- 605
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 608
	if not p.paused then -- 608
		local clampedScale = math.max( -- 610
			0, -- 610
			math.min(2, view.timeScale) -- 610
		) -- 610
		uiDt = safeDt -- 611
		worldDt = safeDt * clampedScale -- 612
	end -- 612
	local uiScale = self:resizeInterface(w, h) -- 615
	local uiW = w / uiScale -- 616
	local uiH = h / uiScale -- 617
	local ctx = { -- 619
		p = p, -- 620
		view = view, -- 621
		events = ev, -- 622
		input = input, -- 623
		cam = self.cam, -- 624
		audio = self.audio, -- 625
		assets = self.worldArt, -- 626
		backdropArt = self.backdropArt, -- 627
		worldArt = self.worldArt, -- 628
		uiArt = self.uiArt, -- 629
		uiMask = self.uiMask, -- 630
		dioramaBg = self.dioramaBg, -- 631
		dioramaWorld = self.dioramaWorld, -- 632
		dioramaFg = self.dioramaFg, -- 633
		texts = self.texts, -- 634
		worldDt = worldDt, -- 635
		uiDt = uiDt, -- 636
		w = w, -- 637
		h = h, -- 638
		uiW = uiW, -- 639
		uiH = uiH, -- 640
		uiScale = uiScale, -- 641
		safeUi = self.stageVp.safeUi, -- 642
		paused = p.paused -- 643
	} -- 643
	local i = 0 -- 647
	do -- 647
		i = 0 -- 648
		while i < #self.plugins do -- 648
			local pl = self.plugins[i + 1] -- 649
			if pl.update ~= nil then -- 649
				pl:update(ctx) -- 651
			end -- 651
			i = i + 1 -- 648
		end -- 648
	end -- 648
	self.roguelikeUi:update(ctx) -- 654
	if not p.paused then -- 654
		self.time = self.time + worldDt -- 657
		self.cam:update(worldDt, p, w, h) -- 658
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 659
		self.audio:setCameraRef( -- 660
			self.cam.x, -- 660
			w / math.max(0.25, self.cam.ppu) -- 660
		) -- 660
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 661
		self.actors:update(worldDt, p) -- 662
		self.vfx:ingestFootsteps(self.actors:drainFootsteps()) -- 663
		if view.visualMode == "pixel" then -- 663
			self.sceneFx:update(worldDt, p, self.cam) -- 665
		end -- 665
		self.vfx:update( -- 667
			worldDt, -- 667
			themeOf(p.room.key).ambient -- 667
		) -- 667
		self.hud:update(safeDt, p) -- 668
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 669
	else -- 669
		self.cam:update(0, p, w, h) -- 671
	end -- 671
	self:clearAll() -- 674
	local use3D = self.xiaoman3d:supports(p, view.visualMode) -- 676
	if use3D then -- 676
		self.xiaoman3d:render( -- 678
			p, -- 678
			self.cam, -- 678
			self.actors, -- 678
			worldDt, -- 678
			w, -- 678
			h, -- 678
			self.stageVp -- 678
		) -- 678
	else -- 678
		self.xiaoman3d:hide() -- 680
		self.cam.projection = nil -- 681
		local backdropHandled = false -- 684
		do -- 684
			i = 0 -- 685
			while i < #self.plugins do -- 685
				local pl = self.plugins[i + 1] -- 686
				if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 686
					backdropHandled = true -- 688
				end -- 688
				i = i + 1 -- 685
			end -- 685
		end -- 685
		if not backdropHandled then -- 685
			self.stage:drawBackdrop( -- 692
				self.bgDraw, -- 692
				self.bgGlow, -- 692
				self.backdropArt, -- 692
				p, -- 692
				self.cam, -- 692
				self.time -- 692
			) -- 692
		end -- 692
		if view.visualMode == "pixel" then -- 692
			self.escortWorld:drawBackdropOverlay( -- 695
				self.bgDraw, -- 695
				self.bgGlow, -- 695
				self.backdropArt, -- 695
				p, -- 695
				self.cam, -- 695
				self.time, -- 695
				self.escortTowerDraw -- 695
			) -- 695
			self.sceneFx:drawBackdropFx( -- 696
				self.bgDraw, -- 696
				self.bgGlow, -- 696
				self.backdropArt, -- 696
				p, -- 696
				self.cam -- 696
			) -- 696
		end -- 696
		local worldHandled = false -- 700
		do -- 700
			i = 0 -- 701
			while i < #self.plugins do -- 701
				local pl = self.plugins[i + 1] -- 702
				if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 702
					worldHandled = true -- 704
				end -- 704
				i = i + 1 -- 701
			end -- 701
		end -- 701
		if not worldHandled then -- 701
			self.stage:drawPlayableWorld( -- 708
				self.groundDraw, -- 709
				self.fgGlow, -- 710
				self.worldArt, -- 711
				p, -- 712
				self.cam, -- 713
				self.time, -- 714
				self.occlusion, -- 715
				worldDt, -- 716
				self.groundArt, -- 717
				self.fgDraw, -- 718
				self.worldOverlayDraw -- 719
			) -- 719
		end -- 719
		local propsHandled = false -- 724
		do -- 724
			i = 0 -- 725
			while i < #self.plugins do -- 725
				local pl = self.plugins[i + 1] -- 726
				if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 726
					propsHandled = true -- 728
				end -- 728
				i = i + 1 -- 725
			end -- 725
		end -- 725
		if not propsHandled then -- 725
			self.props:drawAll( -- 732
				self.fgDraw, -- 732
				self.fgGlow, -- 732
				self.worldArt, -- 732
				p, -- 732
				self.cam, -- 732
				self.time, -- 732
				self.occlusion, -- 732
				worldDt, -- 732
				self.groundArt -- 732
			) -- 732
		end -- 732
		if view.visualMode == "pixel" then -- 732
			self.escortWorld:drawWorldSetpieces( -- 735
				self.fgDraw, -- 735
				self.fgGlow, -- 735
				self.worldArt, -- 735
				p, -- 735
				view, -- 735
				self.cam, -- 735
				self.time -- 735
			) -- 735
			self.sceneFx:drawWorldFx( -- 736
				self.fgDraw, -- 736
				self.fgGlow, -- 736
				self.worldArt, -- 736
				p, -- 736
				self.cam -- 736
			) -- 736
		end -- 736
		if view.visualMode ~= "museum" then -- 736
			local pose -- 741
			for ____, pl in ipairs(self.plugins) do -- 742
				if pl.drawPartyPose ~= nil then -- 742
					pose = pl:drawPartyPose(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 744
					if pose ~= nil then -- 744
						break -- 745
					end -- 745
				end -- 745
			end -- 745
			self.actors:drawAll( -- 748
				self.worldOverlayDraw, -- 748
				self.fgGlow, -- 748
				self.worldArt, -- 748
				p, -- 748
				self.cam, -- 748
				pose -- 748
			) -- 748
		end -- 748
		do -- 748
			i = 0 -- 750
			while i < #self.plugins do -- 750
				local pl = self.plugins[i + 1] -- 751
				if pl.drawActorsOverlay ~= nil then -- 751
					pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 753
				end -- 753
				i = i + 1 -- 750
			end -- 750
		end -- 750
		self.roguelikeUi:drawActorsOverlay(self.worldOverlayDraw, self.fgGlow, self.worldArt, ctx) -- 756
		self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam, p.room.depth ~= nil) -- 759
		if view.visualMode == "pixel" then -- 759
			self.stage:drawForegroundFraming( -- 763
				self.worldOverlayDraw, -- 763
				w, -- 763
				h, -- 763
				p, -- 763
				self.cam -- 763
			) -- 763
			self.escortWorld:drawForegroundFraming( -- 764
				self.worldOverlayDraw, -- 764
				self.fgGlow, -- 764
				self.worldArt, -- 764
				p, -- 764
				self.cam, -- 764
				self.time -- 764
			) -- 764
			self.sceneFx:drawForegroundWeather( -- 765
				self.fgGlow, -- 765
				p, -- 765
				self.cam, -- 765
				w, -- 765
				h -- 765
			) -- 765
		end -- 765
	end -- 765
	self.vfx:drawScreenVfx( -- 768
		self.fgGlow, -- 768
		w, -- 768
		h, -- 768
		p.room.key, -- 768
		view.visualMode ~= "pixel" -- 768
	) -- 768
	local action = {type = "none"} -- 771
	if p.paused then -- 771
		action = self.menus:updateAndDrawPause( -- 773
			safeDt, -- 774
			input, -- 775
			self.uiDraw, -- 776
			self.uiInkDraw, -- 777
			self.uiArt, -- 778
			self.uiGlow, -- 779
			self.texts, -- 780
			uiW, -- 781
			uiH, -- 782
			uiScale, -- 783
			view.assistHintsEnabled, -- 784
			function() -- 785
				self.contract:toggleAssistHints() -- 786
			end, -- 785
			self.stageVp.safeUi, -- 788
			p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom(), -- 789
			view.roguelike.active, -- 790
			function() -- 791
				self.roguelikeUi:openLedger() -- 792
			end -- 791
		) -- 791
	else -- 791
		local cutsceneHandled = false -- 797
		do -- 797
			i = 0 -- 798
			while i < #self.plugins do -- 798
				local pl = self.plugins[i + 1] -- 799
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 799
					self.uiDraw, -- 801
					self.uiInkDraw, -- 801
					self.uiArt, -- 801
					self.uiGlow, -- 801
					ctx -- 801
				) then -- 801
					cutsceneHandled = true -- 802
				end -- 802
				i = i + 1 -- 798
			end -- 798
		end -- 798
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 806
		if not cutsceneHandled and not roguelikeModal then -- 806
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 808
			self.hud:draw( -- 809
				self.uiDraw, -- 810
				self.uiInkDraw, -- 811
				self.uiArt, -- 812
				self.uiGlow, -- 813
				self.texts, -- 814
				p, -- 815
				self.cam, -- 816
				self.vfx, -- 817
				self.narrative.letterbox, -- 818
				uiScale, -- 819
				view.assistHintsEnabled, -- 820
				true, -- 821
				input.inputMode, -- 822
				input.gamepadLayout, -- 823
				self.stageVp.safeUi, -- 824
				input.retryHoldProgress, -- 825
				touchOverlayVisible -- 826
			) -- 826
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 828
			local savedBannerT = self.narrative.bannerT -- 829
			if suppressBanner then -- 829
				self.narrative.bannerT = 0 -- 831
			end -- 831
			self.narrative:draw( -- 833
				self.uiDraw, -- 834
				self.uiInkDraw, -- 835
				self.uiGlow, -- 836
				self.uiArt, -- 837
				self.texts, -- 838
				p, -- 839
				uiW, -- 840
				uiH, -- 841
				view.assistHintsEnabled, -- 842
				input.inputMode, -- 843
				input.gamepadLayout, -- 844
				self.stageVp.safeUi -- 845
			) -- 845
			if suppressBanner then -- 845
				self.narrative.bannerT = savedBannerT -- 848
			end -- 848
		elseif cutsceneHandled then -- 848
			self.narrative:drawCutsceneDialogue( -- 852
				self.uiDraw, -- 853
				self.uiInkDraw, -- 854
				self.uiArt, -- 855
				self.texts, -- 856
				p, -- 857
				uiW, -- 858
				uiH, -- 859
				self.stageVp.safeUi -- 860
			) -- 860
		end -- 860
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 864
		do -- 864
			i = 0 -- 865
			while i < #self.plugins do -- 865
				local pl = self.plugins[i + 1] -- 866
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 866
					self.uiDraw, -- 868
					self.uiInkDraw, -- 868
					self.uiArt, -- 868
					self.uiGlow, -- 868
					ctx -- 868
				) then -- 868
					suppressReticle = true -- 869
				end -- 869
				i = i + 1 -- 865
			end -- 865
		end -- 865
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 865
			self.uiDraw, -- 873
			self.uiInkDraw, -- 873
			self.uiArt, -- 873
			self.uiGlow, -- 873
			ctx -- 873
		) then -- 873
			suppressReticle = true -- 874
		end -- 874
		if not suppressReticle then -- 874
			self.hud:drawReticleOverlay( -- 877
				self.uiInkDraw, -- 878
				self.uiArt, -- 879
				self.uiGlow, -- 880
				p, -- 881
				self.cam, -- 882
				self.vfx, -- 883
				self.narrative.letterbox, -- 884
				uiScale, -- 885
				input:isTouchMode() -- 886
			) -- 886
		end -- 886
		if view.isRehearsal then -- 886
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 892
			drawSilkVeil( -- 893
				self.uiDraw, -- 893
				self.uiArt, -- 893
				"rehearsal_tag_veil", -- 893
				uiW * 0.5, -- 893
				uiH - 22 - self.stageVp.safeUi.top, -- 893
				168, -- 893
				26, -- 893
				PALETTE.inkWarm, -- 893
				0.74, -- 893
				8 -- 893
			) -- 893
			self.texts:put( -- 894
				"xs", -- 894
				badgeText, -- 894
				uiW * 0.5, -- 894
				uiH - 22 - self.stageVp.safeUi.top, -- 894
				toColor(PALETTE.amberCore), -- 894
				0.5, -- 894
				0.5, -- 894
				"Center", -- 894
				1.2, -- 894
				0.92, -- 894
				0.08 -- 894
			) -- 894
		end -- 894
	end -- 894
	self:drawToast(uiW) -- 898
	self:finishFrame() -- 899
	return action -- 900
end -- 570
return ____exports -- 570