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
local ____vfx = require("Script.watch.fe.renderer.vfx") -- 28
local VfxSystem = ____vfx.VfxSystem -- 28
local ____escort_world = require("Script.watch.fe.scenes.escort_world") -- 29
local EscortWorldRenderer = ____escort_world.EscortWorldRenderer -- 29
local ____second_half_assets = require("Script.watch.fe.scenes.second_half_assets") -- 30
local ensureSecondHalfAssetsRegistered = ____second_half_assets.ensureSecondHalfAssetsRegistered -- 30
local ____dark_pixel_assets = require("Script.watch.fe.scenes.dark_pixel_assets") -- 31
local ensureDarkPixelAssetsRegistered = ____dark_pixel_assets.ensureDarkPixelAssetsRegistered -- 31
local ____textpool = require("Script.watch.fe.ui.textpool") -- 32
local TextPool = ____textpool.TextPool -- 32
local ____hud = require("Script.watch.fe.ui.hud") -- 33
local HudRenderer = ____hud.HudRenderer -- 33
local ____narrative = require("Script.watch.fe.ui.narrative") -- 34
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 34
local ____menus = require("Script.watch.fe.ui.menus") -- 35
local MenuRenderer = ____menus.MenuRenderer -- 35
local ____theme = require("Script.watch.fe.theme") -- 36
local PALETTE = ____theme.PALETTE -- 36
local drawSilkVeil = ____theme.drawSilkVeil -- 36
local themeOf = ____theme.themeOf -- 36
local toColor = ____theme.toColor -- 36
local ____ming_audit = require("Script.watch.fe.renderer.ming_audit") -- 37
local MingArtAuditPlugin = ____ming_audit.MingArtAuditPlugin -- 37
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 38
local GateTransitionPlugin = ____gate_transition.GateTransitionPlugin -- 38
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 39
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 39
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 40
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 40
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 41
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 41
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 42
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 42
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 43
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 43
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 44
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 44
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 45
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 45
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 46
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 46
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 47
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 47
local ____roguelike_ui = require("Script.watch.fe.ui.roguelike_ui") -- 48
local computeEscortDeathButtons = ____roguelike_ui.computeEscortDeathButtons -- 48
local RoguelikeUiPlugin = ____roguelike_ui.RoguelikeUiPlugin -- 48
____exports.WatchFrontend = __TS__Class() -- 50
local WatchFrontend = ____exports.WatchFrontend -- 50
WatchFrontend.name = "WatchFrontend" -- 50
function WatchFrontend.prototype.____constructor(self, parent) -- 98
	self.occlusion = __TS__New(DepthOcclusion) -- 51
	self.cam = __TS__New(CameraDirector) -- 74
	self.adapter = __TS__New(PlayAdapter) -- 75
	self.contract = __TS__New( -- 76
		DualRouteContract, -- 76
		function(p) return self:canPickStoryTalent(p) end -- 76
	) -- 76
	self.audio = __TS__New(AudioDirector) -- 77
	self.soundscape = __TS__New(SoundscapeDirector) -- 78
	self.stage = __TS__New(StageRenderer) -- 79
	self.escortWorld = __TS__New(EscortWorldRenderer) -- 80
	self.props = __TS__New(PropsRenderer) -- 81
	self.actors = __TS__New(ActorsRenderer) -- 82
	self.vfx = __TS__New(VfxSystem) -- 83
	self.hud = __TS__New(HudRenderer) -- 84
	self.narrative = __TS__New(NarrativeRenderer) -- 85
	self.menus = __TS__New(MenuRenderer) -- 86
	self.plugins = {} -- 89
	self.screen = "title" -- 91
	self.time = 0 -- 92
	self.stageVp = computeStageViewport(1280, 720) -- 94
	self.toastText = "" -- 95
	self.toastTimer = 0 -- 96
	self.layerRoot = Node() -- 99
	self.layerRoot.order = 5 -- 100
	self.layerRoot:addTo(parent) -- 101
	ensureSecondHalfAssetsRegistered() -- 102
	ensureDarkPixelAssetsRegistered() -- 103
	self.audio:attachHost(self.layerRoot) -- 105
	self.menus.onUiSound = function(____, kind) -- 106
		self:playMenuUiSound(kind) -- 107
	end -- 106
	self.menus.onAudioSettingsChanged = function(____, inp) -- 109
		self.audio:applyUserVolumes(inp.settings) -- 110
	end -- 109
	local additive = BlendFunc("SrcAlpha", "One") -- 113
	self.bgDraw = DrawNode() -- 115
	self.bgDraw.order = 10 -- 116
	self.bgDraw:addTo(self.layerRoot) -- 117
	self.escortTowerDraw = DrawNode() -- 120
	self.escortTowerDraw.order = 13 -- 121
	self.escortTowerDraw:addTo(self.layerRoot) -- 122
	self.bgGlow = DrawNode() -- 124
	self.bgGlow.order = 15 -- 125
	self.bgGlow.blendFunc = additive -- 126
	self.bgGlow:addTo(self.layerRoot) -- 127
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 129
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 130
	self.groundDraw = DrawNode() -- 132
	self.groundDraw.order = 20 -- 133
	self.groundDraw:addTo(self.layerRoot) -- 134
	self.groundArt = __TS__New(AssetSlotHost, self.layerRoot, 22) -- 135
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 136
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 137
	self.worldOverlayDraw = DrawNode() -- 138
	self.worldOverlayDraw.order = 33 -- 139
	self.worldOverlayDraw:addTo(self.layerRoot) -- 140
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 141
	self.fgDraw = DrawNode() -- 143
	self.fgDraw.order = 30 -- 144
	self.fgDraw:addTo(self.layerRoot) -- 145
	self.fgGlow = DrawNode() -- 147
	self.fgGlow.order = 35 -- 148
	self.fgGlow.blendFunc = additive -- 149
	self.fgGlow:addTo(self.layerRoot) -- 150
	self.uiLayer = Node() -- 152
	self.uiLayer.order = 40 -- 153
	self.uiLayer:addTo(self.layerRoot) -- 154
	self.uiDraw = DrawNode() -- 156
	self.uiDraw.order = 0 -- 157
	self.uiDraw:addTo(self.uiLayer) -- 158
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 160
	self.uiInkDraw = DrawNode() -- 162
	self.uiInkDraw.order = 4 -- 163
	self.uiInkDraw:addTo(self.uiLayer) -- 164
	self.uiGlow = DrawNode() -- 166
	self.uiGlow.order = 6 -- 167
	self.uiGlow.blendFunc = additive -- 168
	self.uiGlow:addTo(self.uiLayer) -- 169
	self.uiMask = DrawNode() -- 171
	self.uiMask.order = 8 -- 172
	self.uiMask:addTo(self.uiLayer) -- 173
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 175
	self.roguelikeUi = __TS__New( -- 179
		RoguelikeUiPlugin, -- 179
		self.contract, -- 180
		function() return self.hud.talentSelected end, -- 181
		function(idx) -- 182
			self.hud.talentSelected = idx -- 183
		end -- 182
	) -- 182
	self.hud.roguelikeUiHandled = true -- 186
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) return self.roguelikeUi:getTalentCardRects( -- 187
		w, -- 188
		h, -- 188
		count, -- 188
		touchMode, -- 188
		safeTop -- 188
	) end -- 188
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 202
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 203
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 204
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 205
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 206
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 207
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 208
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 209
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 210
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 211
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 212
end -- 98
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 216
	local i = 0 -- 217
	do -- 217
		i = 0 -- 218
		while i < #self.plugins do -- 218
			if self.plugins[i + 1].id == plugin.id then -- 218
				self.plugins[i + 1] = plugin -- 220
				self:syncRuntimeHooks() -- 221
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 221
					plugin:onBindPlay( -- 223
						self.boundPlay, -- 223
						self.contract:peekSnapshot(self.boundPlay) -- 223
					) -- 223
				end -- 223
				return -- 225
			end -- 225
			i = i + 1 -- 218
		end -- 218
	end -- 218
	local ____self_plugins_0 = self.plugins -- 218
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 228
	self:syncRuntimeHooks() -- 229
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 229
		plugin:onBindPlay( -- 231
			self.boundPlay, -- 231
			self.contract:peekSnapshot(self.boundPlay) -- 231
		) -- 231
	end -- 231
end -- 216
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 236
	local w = 0 -- 237
	local i = 0 -- 238
	do -- 238
		i = 0 -- 239
		while i < #self.plugins do -- 239
			if self.plugins[i + 1].id ~= id then -- 239
				self.plugins[w + 1] = self.plugins[i + 1] -- 241
				w = w + 1 -- 242
			end -- 242
			i = i + 1 -- 239
		end -- 239
	end -- 239
	__TS__ArraySetLength(self.plugins, w) -- 239
	self:syncRuntimeHooks() -- 246
end -- 236
function WatchFrontend.prototype.getPlugin(self, id) -- 250
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 250
		return self.roguelikeUi -- 252
	end -- 252
	local i = 0 -- 254
	do -- 254
		i = 0 -- 255
		while i < #self.plugins do -- 255
			if self.plugins[i + 1].id == id then -- 255
				return self.plugins[i + 1] -- 257
			end -- 257
			i = i + 1 -- 255
		end -- 255
	end -- 255
	return nil -- 260
end -- 250
function WatchFrontend.prototype.getPlugins(self) -- 263
	return self.plugins -- 264
end -- 263
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 272
	local g = _G -- 273
	local ____temp_1 -- 274
	if g.package ~= nil then -- 274
		____temp_1 = g.package.loaded -- 274
	else -- 274
		____temp_1 = nil -- 274
	end -- 274
	local loaded = ____temp_1 -- 274
	if loaded == nil then -- 274
		return -- 276
	end -- 276
	local rawFe = loaded["watch.fe"] -- 278
	if rawFe ~= nil and type(rawFe) == "table" then -- 278
		local watchFe = rawFe -- 280
		if watchFe.contract ~= self.contract then -- 280
			watchFe.contract = self.contract -- 282
			watchFe.audio = self.audio -- 283
			watchFe.soundscape = self.soundscape -- 284
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 285
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 286
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 287
		end -- 287
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 289
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 290
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 291
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 292
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 293
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 294
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 295
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 296
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 297
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 298
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 299
		watchFe.roguelikeUi = self.roguelikeUi -- 300
	end -- 300
end -- 272
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 304
	local scale = math.max( -- 305
		0.25, -- 305
		math.min(w / 1280, h / 720) -- 305
	) -- 305
	self.uiLayer.scaleX = scale -- 306
	self.uiLayer.scaleY = scale -- 307
	return scale -- 308
end -- 304
function WatchFrontend.prototype.setVisible(self, v) -- 312
	self.layerRoot.visible = v -- 313
	if not v then -- 313
		self.texts:hideAll() -- 315
	end -- 315
end -- 312
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 320
	self:syncRuntimeHooks() -- 321
	self.boundPlay = p -- 322
	p.useEscortDeathSummary = true -- 323
	p:openTalentDraft() -- 324
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 325
	self.cam:snap(p, w, h) -- 326
	self.adapter:reset(p) -- 327
	self.contract:resetForRoom(p) -- 328
	self.audio:stopRoomTransient() -- 329
	self.soundscape:resetForRoom(p) -- 330
	self.actors:reset(p) -- 331
	self.occlusion:reset() -- 332
	self.vfx:reset() -- 333
	self.hud:reset(p) -- 334
	self.narrative:onEnterRoom(p.room.key) -- 335
	local initView = self.contract:peekSnapshot(p) -- 337
	if #self.plugins > 0 then -- 337
		local i = 0 -- 339
		do -- 339
			i = 0 -- 340
			while i < #self.plugins do -- 340
				local pl = self.plugins[i + 1] -- 341
				if pl.onBindPlay ~= nil then -- 341
					pl:onBindPlay(p, initView) -- 343
				end -- 343
				i = i + 1 -- 340
			end -- 340
		end -- 340
	end -- 340
	self.roguelikeUi:onBindPlay(p, initView) -- 347
end -- 320
function WatchFrontend.prototype.clearAll(self) -- 350
	self.bgDraw:clear() -- 351
	self.escortTowerDraw:clear() -- 352
	self.bgGlow:clear() -- 353
	self.groundDraw:clear() -- 354
	self.fgDraw:clear() -- 355
	self.worldOverlayDraw:clear() -- 356
	self.fgGlow:clear() -- 357
	self.uiDraw:clear() -- 358
	self.uiInkDraw:clear() -- 359
	self.uiGlow:clear() -- 360
	self.uiMask:clear() -- 361
	self.backdropArt:beginFrame() -- 362
	self.groundArt:beginFrame() -- 363
	self.dioramaBg:beginFrame() -- 364
	self.dioramaWorld:beginFrame() -- 365
	self.dioramaFg:beginFrame() -- 366
	self.worldArt:beginFrame() -- 367
	self.uiArt:beginFrame() -- 368
	self.texts:beginFrame() -- 369
end -- 350
function WatchFrontend.prototype.finishFrame(self) -- 372
	self.backdropArt:endFrame() -- 373
	self.groundArt:endFrame() -- 374
	self.dioramaBg:endFrame() -- 375
	self.dioramaWorld:endFrame() -- 376
	self.dioramaFg:endFrame() -- 377
	self.worldArt:endFrame() -- 378
	self.uiArt:endFrame() -- 379
	self.texts:endFrame() -- 380
end -- 372
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 384
	self.stageVp = vp -- 385
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 386
end -- 384
function WatchFrontend.prototype.showToast(self, text, duration) -- 390
	if duration == nil then -- 390
		duration = 1.8 -- 390
	end -- 390
	self.toastText = text -- 391
	self.toastTimer = duration -- 392
end -- 390
function WatchFrontend.prototype.getToastText(self) -- 395
	return self.toastTimer > 0 and self.toastText or "" -- 396
end -- 395
function WatchFrontend.prototype.drawToast(self, uiW) -- 399
	if self.toastTimer <= 0 or self.toastText == "" then -- 399
		return -- 401
	end -- 401
	local alpha = math.min(1, self.toastTimer * 2.4) -- 403
	local cx = uiW * 0.5 -- 404
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 405
	drawSilkVeil( -- 406
		self.uiDraw, -- 406
		self.uiArt, -- 406
		"fe_toast_veil", -- 406
		cx, -- 406
		cy, -- 406
		340, -- 406
		38, -- 406
		PALETTE.inkWarm, -- 406
		0.86 * alpha, -- 406
		9 -- 406
	) -- 406
	self.texts:put( -- 407
		"sm", -- 407
		self.toastText, -- 407
		cx, -- 407
		cy, -- 407
		toColor(PALETTE.amberCore), -- 407
		0.5, -- 407
		0.5, -- 407
		"Center", -- 407
		1.4, -- 407
		0.96 * alpha, -- 407
		0.08 -- 407
	) -- 407
end -- 399
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 410
	return not p.escortFailed and not p.paused and not p.craftBench.active and not p.reloadOpen and self.roguelikeUi:canPickTalent() -- 411
end -- 410
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 415
	local offers = p:getStoryTalentOffers() -- 416
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 416
		return {} -- 418
	end -- 418
	local uiScale = math.max( -- 420
		0.25, -- 420
		math.min(w / 1280, h / 720) -- 420
	) -- 420
	return self.hud:talentCardRects( -- 421
		w / uiScale, -- 421
		h / uiScale, -- 421
		#offers, -- 421
		touchMode, -- 421
		self.stageVp.safeUi.top -- 421
	) -- 421
end -- 415
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 425
	if not p.escortFailed then -- 425
		return nil -- 427
	end -- 427
	local uiScale = math.max( -- 429
		0.25, -- 429
		math.min(w / 1280, h / 720) -- 429
	) -- 429
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 430
end -- 425
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 434
	if not p.escortFailed then -- 434
		return "" -- 436
	end -- 436
	if input.inputMode == "gamepad" and not input.uiPressed then -- 436
		return "" -- 439
	end -- 439
	local useUiPtr = input.uiInside or input.uiPressed -- 441
	local ____useUiPtr_2 -- 442
	if useUiPtr then -- 442
		____useUiPtr_2 = input.uiInside -- 442
	else -- 442
		____useUiPtr_2 = input.inside -- 442
	end -- 442
	local inside = ____useUiPtr_2 -- 442
	if not inside then -- 442
		return "" -- 444
	end -- 444
	local uiScale = math.max( -- 446
		0.25, -- 446
		math.min(w / 1280, h / 720) -- 446
	) -- 446
	local rawX = useUiPtr and input.uiX or input.mx -- 447
	local rawY = useUiPtr and input.uiY or input.my -- 448
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 449
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 450
	if btns.retry:containsPoint(pointer) then -- 450
		self.roguelikeUi.deathSelected = 0 -- 452
		return "retry" -- 453
	end -- 453
	if btns.title:containsPoint(pointer) then -- 453
		self.roguelikeUi.deathSelected = 1 -- 456
		return "title" -- 457
	end -- 457
	return "" -- 459
end -- 434
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 462
	if kind == "hover" then -- 462
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 464
	elseif kind == "confirm" then -- 464
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 466
	elseif kind == "back" then -- 466
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 468
	elseif kind == "start" then -- 468
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 470
	elseif kind == "pauseOpen" then -- 470
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 472
	elseif kind == "pauseClose" then -- 472
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 474
	elseif kind == "toggle" then -- 474
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 476
	end -- 476
end -- 462
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 481
	self:syncRuntimeHooks() -- 482
	local safeDt = math.min( -- 483
		0.05, -- 483
		math.max(0, dt) -- 483
	) -- 483
	if self.toastTimer > 0 then -- 483
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 485
	end -- 485
	if self.screen == "title" and self.boundPlay ~= nil then -- 485
		self.audio:stopRoomTransient() -- 488
		self.boundPlay = nil -- 489
	end -- 489
	self.audio:update(safeDt) -- 491
	self.soundscape:updateMenu(self.screen, self.audio) -- 492
	self:setVisible(true) -- 493
	self:clearAll() -- 494
	local uiScale = self:resizeInterface(w, h) -- 495
	local act = self.menus:updateAndDrawScreen( -- 496
		dt, -- 497
		self.screen, -- 498
		input, -- 499
		self.stage, -- 500
		self.bgDraw, -- 501
		self.bgGlow, -- 502
		self.backdropArt, -- 503
		self.uiArt, -- 504
		self.uiDraw, -- 505
		self.uiInkDraw, -- 506
		self.uiGlow, -- 507
		self.texts, -- 508
		w, -- 509
		h, -- 510
		uiScale, -- 511
		self.stageVp.safeUi -- 512
	) -- 512
	self:drawToast(w / uiScale) -- 514
	self:finishFrame() -- 515
	return act -- 516
end -- 481
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 520
	local offers = p:getStoryTalentOffers() -- 521
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 521
		return false -- 523
	end -- 523
	if input.inputMode == "gamepad" and not input.uiPressed then -- 523
		return false -- 526
	end -- 526
	local useUiPtr = input.uiInside or input.uiPressed -- 528
	local ____useUiPtr_3 -- 529
	if useUiPtr then -- 529
		____useUiPtr_3 = input.uiInside -- 529
	else -- 529
		____useUiPtr_3 = input.inside -- 529
	end -- 529
	local inside = ____useUiPtr_3 -- 529
	if not inside then -- 529
		return false -- 531
	end -- 531
	local uiScale = math.max( -- 533
		0.25, -- 533
		math.min(w / 1280, h / 720) -- 533
	) -- 533
	local uiW = w / uiScale -- 534
	local uiH = h / uiScale -- 535
	local rawX = useUiPtr and input.uiX or input.mx -- 536
	local rawY = useUiPtr and input.uiY or input.my -- 537
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 538
	local boxes = self.hud:talentCardRects( -- 539
		uiW, -- 539
		uiH, -- 539
		#offers, -- 539
		input:isTouchMode(), -- 539
		self.stageVp.safeUi.top -- 539
	) -- 539
	local i = 0 -- 540
	do -- 540
		i = 0 -- 541
		while i < #boxes do -- 541
			if boxes[i + 1]:containsPoint(pointer) then -- 541
				return p:chooseTalent(i) -- 543
			end -- 543
			i = i + 1 -- 541
		end -- 541
	end -- 541
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 547
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 548
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 549
end -- 520
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 554
	self:syncRuntimeHooks() -- 555
	self:setVisible(true) -- 556
	if self.boundPlay ~= p then -- 556
		self:bindPlay(p, w, h) -- 558
	end -- 558
	local safeDt = math.min( -- 560
		0.05, -- 560
		math.max(0.001, dt) -- 560
	) -- 560
	if self.toastTimer > 0 then -- 560
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 562
	end -- 562
	self.audio:setPaused(p.paused) -- 564
	self.audio:setCameraRef( -- 565
		self.cam.x, -- 565
		w / math.max(0.25, self.cam.ppu) -- 565
	) -- 565
	self.audio:update(safeDt) -- 566
	local ev -- 568
	local worldDt = 0 -- 569
	local uiDt = 0 -- 570
	if not p.paused then -- 570
		ev = self.adapter:sample(p) -- 574
		self.vfx:ingest(ev, p, self.cam) -- 575
		self.audio:ingestEvents(ev, p) -- 576
		if ev.playerHit then -- 576
			input:vibrate(0.036) -- 578
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 578
			input:vibrate(0.024) -- 580
		elseif ev.coverDeflect then -- 580
			input:vibrate(0.018) -- 582
		elseif ev.knockPulse then -- 582
			input:vibrate(0.014) -- 584
		end -- 584
	else -- 584
		ev = self.adapter:emptyFrame(p) -- 588
		self.narrative.wipeT = 0 -- 589
	end -- 589
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 592
	if not p.paused then -- 592
		local clampedScale = math.max( -- 594
			0, -- 594
			math.min(2, view.timeScale) -- 594
		) -- 594
		uiDt = safeDt -- 595
		worldDt = safeDt * clampedScale -- 596
	end -- 596
	local uiScale = self:resizeInterface(w, h) -- 599
	local uiW = w / uiScale -- 600
	local uiH = h / uiScale -- 601
	local ctx = { -- 603
		p = p, -- 604
		view = view, -- 605
		events = ev, -- 606
		input = input, -- 607
		cam = self.cam, -- 608
		audio = self.audio, -- 609
		assets = self.worldArt, -- 610
		backdropArt = self.backdropArt, -- 611
		worldArt = self.worldArt, -- 612
		uiArt = self.uiArt, -- 613
		uiMask = self.uiMask, -- 614
		dioramaBg = self.dioramaBg, -- 615
		dioramaWorld = self.dioramaWorld, -- 616
		dioramaFg = self.dioramaFg, -- 617
		texts = self.texts, -- 618
		worldDt = worldDt, -- 619
		uiDt = uiDt, -- 620
		w = w, -- 621
		h = h, -- 622
		uiW = uiW, -- 623
		uiH = uiH, -- 624
		uiScale = uiScale, -- 625
		safeUi = self.stageVp.safeUi, -- 626
		paused = p.paused -- 627
	} -- 627
	local i = 0 -- 631
	do -- 631
		i = 0 -- 632
		while i < #self.plugins do -- 632
			local pl = self.plugins[i + 1] -- 633
			if pl.update ~= nil then -- 633
				pl:update(ctx) -- 635
			end -- 635
			i = i + 1 -- 632
		end -- 632
	end -- 632
	self.roguelikeUi:update(ctx) -- 638
	if not p.paused then -- 638
		self.time = self.time + worldDt -- 641
		self.cam:update(worldDt, p, w, h) -- 642
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 643
		self.audio:setCameraRef( -- 644
			self.cam.x, -- 644
			w / math.max(0.25, self.cam.ppu) -- 644
		) -- 644
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 645
		self.actors:update(worldDt, p) -- 646
		self.vfx:update( -- 647
			worldDt, -- 647
			themeOf(p.room.key).ambient -- 647
		) -- 647
		self.hud:update(safeDt, p) -- 648
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 649
	else -- 649
		self.cam:update(0, p, w, h) -- 651
	end -- 651
	self:clearAll() -- 654
	local backdropHandled = false -- 657
	do -- 657
		i = 0 -- 658
		while i < #self.plugins do -- 658
			local pl = self.plugins[i + 1] -- 659
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 659
				backdropHandled = true -- 661
			end -- 661
			i = i + 1 -- 658
		end -- 658
	end -- 658
	if not backdropHandled then -- 658
		self.stage:drawBackdrop( -- 665
			self.bgDraw, -- 665
			self.bgGlow, -- 665
			self.backdropArt, -- 665
			p, -- 665
			self.cam, -- 665
			self.time -- 665
		) -- 665
	end -- 665
	if view.visualMode == "pixel" then -- 665
		self.escortWorld:drawBackdropOverlay( -- 668
			self.bgDraw, -- 668
			self.bgGlow, -- 668
			self.backdropArt, -- 668
			p, -- 668
			self.cam, -- 668
			self.time, -- 668
			self.escortTowerDraw -- 668
		) -- 668
	end -- 668
	local worldHandled = false -- 672
	do -- 672
		i = 0 -- 673
		while i < #self.plugins do -- 673
			local pl = self.plugins[i + 1] -- 674
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 674
				worldHandled = true -- 676
			end -- 676
			i = i + 1 -- 673
		end -- 673
	end -- 673
	if not worldHandled then -- 673
		self.stage:drawPlayableWorld( -- 680
			self.groundDraw, -- 681
			self.fgGlow, -- 682
			self.worldArt, -- 683
			p, -- 684
			self.cam, -- 685
			self.time, -- 686
			self.occlusion, -- 687
			worldDt, -- 688
			self.groundArt, -- 689
			self.fgDraw, -- 690
			self.worldOverlayDraw -- 691
		) -- 691
	end -- 691
	local propsHandled = false -- 696
	do -- 696
		i = 0 -- 697
		while i < #self.plugins do -- 697
			local pl = self.plugins[i + 1] -- 698
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 698
				propsHandled = true -- 700
			end -- 700
			i = i + 1 -- 697
		end -- 697
	end -- 697
	if not propsHandled then -- 697
		self.props:drawAll( -- 704
			self.groundDraw, -- 704
			self.fgGlow, -- 704
			self.worldArt, -- 704
			p, -- 704
			self.cam, -- 704
			self.time, -- 704
			self.occlusion, -- 704
			worldDt, -- 704
			self.groundArt -- 704
		) -- 704
	end -- 704
	if view.visualMode == "pixel" then -- 704
		self.escortWorld:drawWorldSetpieces( -- 707
			self.fgDraw, -- 707
			self.fgGlow, -- 707
			self.worldArt, -- 707
			p, -- 707
			view, -- 707
			self.cam, -- 707
			self.time -- 707
		) -- 707
	end -- 707
	if view.visualMode ~= "museum" then -- 707
		local pose -- 712
		for ____, pl in ipairs(self.plugins) do -- 713
			if pl.drawPartyPose ~= nil then -- 713
				pose = pl:drawPartyPose(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 715
				if pose ~= nil then -- 715
					break -- 716
				end -- 716
			end -- 716
		end -- 716
		self.actors:drawAll( -- 719
			self.worldOverlayDraw, -- 719
			self.fgGlow, -- 719
			self.worldArt, -- 719
			p, -- 719
			self.cam, -- 719
			pose -- 719
		) -- 719
	end -- 719
	do -- 719
		i = 0 -- 721
		while i < #self.plugins do -- 721
			local pl = self.plugins[i + 1] -- 722
			if pl.drawActorsOverlay ~= nil then -- 722
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 724
			end -- 724
			i = i + 1 -- 721
		end -- 721
	end -- 721
	self.roguelikeUi:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 727
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 730
	if view.visualMode == "pixel" then -- 730
		self.stage:drawForegroundFraming( -- 734
			self.worldOverlayDraw, -- 734
			w, -- 734
			h, -- 734
			p, -- 734
			self.cam -- 734
		) -- 734
		self.escortWorld:drawForegroundFraming( -- 735
			self.worldOverlayDraw, -- 735
			self.fgGlow, -- 735
			self.worldArt, -- 735
			p, -- 735
			self.cam, -- 735
			self.time -- 735
		) -- 735
	end -- 735
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 737
	local action = {type = "none"} -- 740
	if p.paused then -- 740
		action = self.menus:updateAndDrawPause( -- 742
			safeDt, -- 743
			input, -- 744
			self.uiDraw, -- 745
			self.uiInkDraw, -- 746
			self.uiArt, -- 747
			self.uiGlow, -- 748
			self.texts, -- 749
			uiW, -- 750
			uiH, -- 751
			uiScale, -- 752
			view.assistHintsEnabled, -- 753
			function() -- 754
				self.contract:toggleAssistHints() -- 755
			end, -- 754
			self.stageVp.safeUi, -- 757
			p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom(), -- 758
			view.roguelike.active, -- 759
			function() -- 760
				self.roguelikeUi:openLedger() -- 761
			end -- 760
		) -- 760
	else -- 760
		local cutsceneHandled = false -- 766
		do -- 766
			i = 0 -- 767
			while i < #self.plugins do -- 767
				local pl = self.plugins[i + 1] -- 768
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 768
					self.uiDraw, -- 770
					self.uiInkDraw, -- 770
					self.uiArt, -- 770
					self.uiGlow, -- 770
					ctx -- 770
				) then -- 770
					cutsceneHandled = true -- 771
				end -- 771
				i = i + 1 -- 767
			end -- 767
		end -- 767
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 775
		if not cutsceneHandled and not roguelikeModal then -- 775
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 777
			self.hud:draw( -- 778
				self.uiDraw, -- 779
				self.uiInkDraw, -- 780
				self.uiArt, -- 781
				self.uiGlow, -- 782
				self.texts, -- 783
				p, -- 784
				self.cam, -- 785
				self.vfx, -- 786
				self.narrative.letterbox, -- 787
				uiScale, -- 788
				view.assistHintsEnabled, -- 789
				true, -- 790
				input.inputMode, -- 791
				input.gamepadLayout, -- 792
				self.stageVp.safeUi, -- 793
				input.retryHoldProgress, -- 794
				touchOverlayVisible -- 795
			) -- 795
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 797
			local savedBannerT = self.narrative.bannerT -- 798
			if suppressBanner then -- 798
				self.narrative.bannerT = 0 -- 800
			end -- 800
			self.narrative:draw( -- 802
				self.uiDraw, -- 803
				self.uiInkDraw, -- 804
				self.uiGlow, -- 805
				self.uiArt, -- 806
				self.texts, -- 807
				p, -- 808
				uiW, -- 809
				uiH, -- 810
				view.assistHintsEnabled, -- 811
				input.inputMode, -- 812
				input.gamepadLayout, -- 813
				self.stageVp.safeUi -- 814
			) -- 814
			if suppressBanner then -- 814
				self.narrative.bannerT = savedBannerT -- 817
			end -- 817
		elseif cutsceneHandled then -- 817
			self.narrative:drawCutsceneDialogue( -- 821
				self.uiDraw, -- 822
				self.uiInkDraw, -- 823
				self.uiArt, -- 824
				self.texts, -- 825
				p, -- 826
				uiW, -- 827
				uiH, -- 828
				self.stageVp.safeUi -- 829
			) -- 829
		end -- 829
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 833
		do -- 833
			i = 0 -- 834
			while i < #self.plugins do -- 834
				local pl = self.plugins[i + 1] -- 835
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 835
					self.uiDraw, -- 837
					self.uiInkDraw, -- 837
					self.uiArt, -- 837
					self.uiGlow, -- 837
					ctx -- 837
				) then -- 837
					suppressReticle = true -- 838
				end -- 838
				i = i + 1 -- 834
			end -- 834
		end -- 834
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 834
			self.uiDraw, -- 842
			self.uiInkDraw, -- 842
			self.uiArt, -- 842
			self.uiGlow, -- 842
			ctx -- 842
		) then -- 842
			suppressReticle = true -- 843
		end -- 843
		if not suppressReticle then -- 843
			self.hud:drawReticleOverlay( -- 846
				self.uiInkDraw, -- 847
				self.uiArt, -- 848
				self.uiGlow, -- 849
				p, -- 850
				self.cam, -- 851
				self.vfx, -- 852
				self.narrative.letterbox, -- 853
				uiScale, -- 854
				input:isTouchMode() -- 855
			) -- 855
		end -- 855
		if view.isRehearsal then -- 855
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 861
			drawSilkVeil( -- 862
				self.uiDraw, -- 862
				self.uiArt, -- 862
				"rehearsal_tag_veil", -- 862
				uiW * 0.5, -- 862
				uiH - 22 - self.stageVp.safeUi.top, -- 862
				168, -- 862
				26, -- 862
				PALETTE.inkWarm, -- 862
				0.74, -- 862
				8 -- 862
			) -- 862
			self.texts:put( -- 863
				"xs", -- 863
				badgeText, -- 863
				uiW * 0.5, -- 863
				uiH - 22 - self.stageVp.safeUi.top, -- 863
				toColor(PALETTE.amberCore), -- 863
				0.5, -- 863
				0.5, -- 863
				"Center", -- 863
				1.2, -- 863
				0.92, -- 863
				0.08 -- 863
			) -- 863
		end -- 863
	end -- 863
	self:drawToast(uiW) -- 867
	self:finishFrame() -- 868
	return action -- 869
end -- 554
return ____exports -- 554