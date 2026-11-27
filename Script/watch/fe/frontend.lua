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
local ____textpool = require("Script.watch.fe.ui.textpool") -- 31
local TextPool = ____textpool.TextPool -- 31
local ____hud = require("Script.watch.fe.ui.hud") -- 32
local HudRenderer = ____hud.HudRenderer -- 32
local ____narrative = require("Script.watch.fe.ui.narrative") -- 33
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 33
local ____menus = require("Script.watch.fe.ui.menus") -- 34
local MenuRenderer = ____menus.MenuRenderer -- 34
local ____theme = require("Script.watch.fe.theme") -- 35
local PALETTE = ____theme.PALETTE -- 35
local drawSilkVeil = ____theme.drawSilkVeil -- 35
local themeOf = ____theme.themeOf -- 35
local toColor = ____theme.toColor -- 35
local ____ming_audit = require("Script.watch.fe.renderer.ming_audit") -- 36
local MingArtAuditPlugin = ____ming_audit.MingArtAuditPlugin -- 36
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 37
local GateTransitionPlugin = ____gate_transition.GateTransitionPlugin -- 37
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 38
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 38
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 39
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 39
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 40
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 40
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 41
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 41
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 42
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 42
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 43
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 43
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 44
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 44
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 45
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 45
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 46
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 46
local ____roguelike_ui = require("Script.watch.fe.ui.roguelike_ui") -- 47
local computeEscortDeathButtons = ____roguelike_ui.computeEscortDeathButtons -- 47
local RoguelikeUiPlugin = ____roguelike_ui.RoguelikeUiPlugin -- 47
____exports.WatchFrontend = __TS__Class() -- 49
local WatchFrontend = ____exports.WatchFrontend -- 49
WatchFrontend.name = "WatchFrontend" -- 49
function WatchFrontend.prototype.____constructor(self, parent) -- 94
	self.occlusion = __TS__New(DepthOcclusion) -- 50
	self.cam = __TS__New(CameraDirector) -- 70
	self.adapter = __TS__New(PlayAdapter) -- 71
	self.contract = __TS__New( -- 72
		DualRouteContract, -- 72
		function(p) return self:canPickStoryTalent(p) end -- 72
	) -- 72
	self.audio = __TS__New(AudioDirector) -- 73
	self.soundscape = __TS__New(SoundscapeDirector) -- 74
	self.stage = __TS__New(StageRenderer) -- 75
	self.escortWorld = __TS__New(EscortWorldRenderer) -- 76
	self.props = __TS__New(PropsRenderer) -- 77
	self.actors = __TS__New(ActorsRenderer) -- 78
	self.vfx = __TS__New(VfxSystem) -- 79
	self.hud = __TS__New(HudRenderer) -- 80
	self.narrative = __TS__New(NarrativeRenderer) -- 81
	self.menus = __TS__New(MenuRenderer) -- 82
	self.plugins = {} -- 85
	self.screen = "title" -- 87
	self.time = 0 -- 88
	self.stageVp = computeStageViewport(1280, 720) -- 90
	self.toastText = "" -- 91
	self.toastTimer = 0 -- 92
	self.layerRoot = Node() -- 95
	self.layerRoot.order = 5 -- 96
	self.layerRoot:addTo(parent) -- 97
	ensureSecondHalfAssetsRegistered() -- 98
	self.audio:attachHost(self.layerRoot) -- 100
	self.menus.onUiSound = function(____, kind) -- 101
		self:playMenuUiSound(kind) -- 102
	end -- 101
	self.menus.onAudioSettingsChanged = function(____, inp) -- 104
		self.audio:applyUserVolumes(inp.settings) -- 105
	end -- 104
	local additive = BlendFunc("SrcAlpha", "One") -- 108
	self.bgDraw = DrawNode() -- 110
	self.bgDraw.order = 10 -- 111
	self.bgDraw:addTo(self.layerRoot) -- 112
	self.escortTowerDraw = DrawNode() -- 115
	self.escortTowerDraw.order = 13 -- 116
	self.escortTowerDraw:addTo(self.layerRoot) -- 117
	self.bgGlow = DrawNode() -- 119
	self.bgGlow.order = 15 -- 120
	self.bgGlow.blendFunc = additive -- 121
	self.bgGlow:addTo(self.layerRoot) -- 122
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 124
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 125
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 126
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 127
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 128
	self.fgDraw = DrawNode() -- 130
	self.fgDraw.order = 30 -- 131
	self.fgDraw:addTo(self.layerRoot) -- 132
	self.fgGlow = DrawNode() -- 134
	self.fgGlow.order = 35 -- 135
	self.fgGlow.blendFunc = additive -- 136
	self.fgGlow:addTo(self.layerRoot) -- 137
	self.uiLayer = Node() -- 139
	self.uiLayer.order = 40 -- 140
	self.uiLayer:addTo(self.layerRoot) -- 141
	self.uiDraw = DrawNode() -- 143
	self.uiDraw.order = 0 -- 144
	self.uiDraw:addTo(self.uiLayer) -- 145
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 147
	self.uiInkDraw = DrawNode() -- 149
	self.uiInkDraw.order = 4 -- 150
	self.uiInkDraw:addTo(self.uiLayer) -- 151
	self.uiGlow = DrawNode() -- 153
	self.uiGlow.order = 6 -- 154
	self.uiGlow.blendFunc = additive -- 155
	self.uiGlow:addTo(self.uiLayer) -- 156
	self.uiMask = DrawNode() -- 158
	self.uiMask.order = 8 -- 159
	self.uiMask:addTo(self.uiLayer) -- 160
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 162
	self.roguelikeUi = __TS__New( -- 166
		RoguelikeUiPlugin, -- 166
		self.contract, -- 167
		function() return self.hud.talentSelected end, -- 168
		function(idx) -- 169
			self.hud.talentSelected = idx -- 170
		end -- 169
	) -- 169
	self.hud.roguelikeUiHandled = true -- 173
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) return self.roguelikeUi:getTalentCardRects( -- 174
		w, -- 175
		h, -- 175
		count, -- 175
		touchMode, -- 175
		safeTop -- 175
	) end -- 175
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 189
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 190
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 191
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 192
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 193
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 194
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 195
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 196
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 197
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 198
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 199
end -- 94
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 203
	local i = 0 -- 204
	do -- 204
		i = 0 -- 205
		while i < #self.plugins do -- 205
			if self.plugins[i + 1].id == plugin.id then -- 205
				self.plugins[i + 1] = plugin -- 207
				self:syncRuntimeHooks() -- 208
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 208
					plugin:onBindPlay( -- 210
						self.boundPlay, -- 210
						self.contract:peekSnapshot(self.boundPlay) -- 210
					) -- 210
				end -- 210
				return -- 212
			end -- 212
			i = i + 1 -- 205
		end -- 205
	end -- 205
	local ____self_plugins_0 = self.plugins -- 205
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 215
	self:syncRuntimeHooks() -- 216
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 216
		plugin:onBindPlay( -- 218
			self.boundPlay, -- 218
			self.contract:peekSnapshot(self.boundPlay) -- 218
		) -- 218
	end -- 218
end -- 203
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 223
	local w = 0 -- 224
	local i = 0 -- 225
	do -- 225
		i = 0 -- 226
		while i < #self.plugins do -- 226
			if self.plugins[i + 1].id ~= id then -- 226
				self.plugins[w + 1] = self.plugins[i + 1] -- 228
				w = w + 1 -- 229
			end -- 229
			i = i + 1 -- 226
		end -- 226
	end -- 226
	__TS__ArraySetLength(self.plugins, w) -- 226
	self:syncRuntimeHooks() -- 233
end -- 223
function WatchFrontend.prototype.getPlugin(self, id) -- 237
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 237
		return self.roguelikeUi -- 239
	end -- 239
	local i = 0 -- 241
	do -- 241
		i = 0 -- 242
		while i < #self.plugins do -- 242
			if self.plugins[i + 1].id == id then -- 242
				return self.plugins[i + 1] -- 244
			end -- 244
			i = i + 1 -- 242
		end -- 242
	end -- 242
	return nil -- 247
end -- 237
function WatchFrontend.prototype.getPlugins(self) -- 250
	return self.plugins -- 251
end -- 250
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 259
	local g = _G -- 260
	local ____temp_1 -- 261
	if g.package ~= nil then -- 261
		____temp_1 = g.package.loaded -- 261
	else -- 261
		____temp_1 = nil -- 261
	end -- 261
	local loaded = ____temp_1 -- 261
	if loaded == nil then -- 261
		return -- 263
	end -- 263
	local rawFe = loaded["watch.fe"] -- 265
	if rawFe ~= nil and type(rawFe) == "table" then -- 265
		local watchFe = rawFe -- 267
		if watchFe.contract ~= self.contract then -- 267
			watchFe.contract = self.contract -- 269
			watchFe.audio = self.audio -- 270
			watchFe.soundscape = self.soundscape -- 271
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 272
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 273
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 274
		end -- 274
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 276
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 277
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 278
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 279
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 280
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 281
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 282
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 283
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 284
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 285
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 286
		watchFe.roguelikeUi = self.roguelikeUi -- 287
	end -- 287
end -- 259
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 291
	local scale = math.max( -- 292
		0.25, -- 292
		math.min(w / 1280, h / 720) -- 292
	) -- 292
	self.uiLayer.scaleX = scale -- 293
	self.uiLayer.scaleY = scale -- 294
	return scale -- 295
end -- 291
function WatchFrontend.prototype.setVisible(self, v) -- 299
	self.layerRoot.visible = v -- 300
	if not v then -- 300
		self.texts:hideAll() -- 302
	end -- 302
end -- 299
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 307
	self:syncRuntimeHooks() -- 308
	self.boundPlay = p -- 309
	p.useEscortDeathSummary = true -- 310
	p:openTalentDraft() -- 311
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 312
	self.cam:snap(p, w, h) -- 313
	self.adapter:reset(p) -- 314
	self.contract:resetForRoom(p) -- 315
	self.audio:stopRoomTransient() -- 316
	self.soundscape:resetForRoom(p) -- 317
	self.actors:reset(p) -- 318
	self.occlusion:reset() -- 319
	self.vfx:reset() -- 320
	self.hud:reset(p) -- 321
	self.narrative:onEnterRoom(p.room.key) -- 322
	local initView = self.contract:peekSnapshot(p) -- 324
	if #self.plugins > 0 then -- 324
		local i = 0 -- 326
		do -- 326
			i = 0 -- 327
			while i < #self.plugins do -- 327
				local pl = self.plugins[i + 1] -- 328
				if pl.onBindPlay ~= nil then -- 328
					pl:onBindPlay(p, initView) -- 330
				end -- 330
				i = i + 1 -- 327
			end -- 327
		end -- 327
	end -- 327
	self.roguelikeUi:onBindPlay(p, initView) -- 334
end -- 307
function WatchFrontend.prototype.clearAll(self) -- 337
	self.bgDraw:clear() -- 338
	self.escortTowerDraw:clear() -- 339
	self.bgGlow:clear() -- 340
	self.fgDraw:clear() -- 341
	self.fgGlow:clear() -- 342
	self.uiDraw:clear() -- 343
	self.uiInkDraw:clear() -- 344
	self.uiGlow:clear() -- 345
	self.uiMask:clear() -- 346
	self.backdropArt:beginFrame() -- 347
	self.dioramaBg:beginFrame() -- 348
	self.dioramaWorld:beginFrame() -- 349
	self.dioramaFg:beginFrame() -- 350
	self.worldArt:beginFrame() -- 351
	self.uiArt:beginFrame() -- 352
	self.texts:beginFrame() -- 353
end -- 337
function WatchFrontend.prototype.finishFrame(self) -- 356
	self.backdropArt:endFrame() -- 357
	self.dioramaBg:endFrame() -- 358
	self.dioramaWorld:endFrame() -- 359
	self.dioramaFg:endFrame() -- 360
	self.worldArt:endFrame() -- 361
	self.uiArt:endFrame() -- 362
	self.texts:endFrame() -- 363
end -- 356
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 367
	self.stageVp = vp -- 368
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 369
end -- 367
function WatchFrontend.prototype.showToast(self, text, duration) -- 373
	if duration == nil then -- 373
		duration = 1.8 -- 373
	end -- 373
	self.toastText = text -- 374
	self.toastTimer = duration -- 375
end -- 373
function WatchFrontend.prototype.getToastText(self) -- 378
	return self.toastTimer > 0 and self.toastText or "" -- 379
end -- 378
function WatchFrontend.prototype.drawToast(self, uiW) -- 382
	if self.toastTimer <= 0 or self.toastText == "" then -- 382
		return -- 384
	end -- 384
	local alpha = math.min(1, self.toastTimer * 2.4) -- 386
	local cx = uiW * 0.5 -- 387
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 388
	drawSilkVeil( -- 389
		self.uiDraw, -- 389
		self.uiArt, -- 389
		"fe_toast_veil", -- 389
		cx, -- 389
		cy, -- 389
		340, -- 389
		38, -- 389
		PALETTE.inkWarm, -- 389
		0.86 * alpha, -- 389
		9 -- 389
	) -- 389
	self.texts:put( -- 390
		"sm", -- 390
		self.toastText, -- 390
		cx, -- 390
		cy, -- 390
		toColor(PALETTE.amberCore), -- 390
		0.5, -- 390
		0.5, -- 390
		"Center", -- 390
		1.4, -- 390
		0.96 * alpha, -- 390
		0.08 -- 390
	) -- 390
end -- 382
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 393
	return not p.escortFailed and not p.paused and not p.craftBench.active and not p.reloadOpen and self.roguelikeUi:canPickTalent() -- 394
end -- 393
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 398
	local offers = p:getStoryTalentOffers() -- 399
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 399
		return {} -- 401
	end -- 401
	local uiScale = math.max( -- 403
		0.25, -- 403
		math.min(w / 1280, h / 720) -- 403
	) -- 403
	return self.hud:talentCardRects( -- 404
		w / uiScale, -- 404
		h / uiScale, -- 404
		#offers, -- 404
		touchMode, -- 404
		self.stageVp.safeUi.top -- 404
	) -- 404
end -- 398
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 408
	if not p.escortFailed then -- 408
		return nil -- 410
	end -- 410
	local uiScale = math.max( -- 412
		0.25, -- 412
		math.min(w / 1280, h / 720) -- 412
	) -- 412
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 413
end -- 408
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 417
	if not p.escortFailed then -- 417
		return "" -- 419
	end -- 419
	if input.inputMode == "gamepad" and not input.uiPressed then -- 419
		return "" -- 422
	end -- 422
	local useUiPtr = input.uiInside or input.uiPressed -- 424
	local ____useUiPtr_2 -- 425
	if useUiPtr then -- 425
		____useUiPtr_2 = input.uiInside -- 425
	else -- 425
		____useUiPtr_2 = input.inside -- 425
	end -- 425
	local inside = ____useUiPtr_2 -- 425
	if not inside then -- 425
		return "" -- 427
	end -- 427
	local uiScale = math.max( -- 429
		0.25, -- 429
		math.min(w / 1280, h / 720) -- 429
	) -- 429
	local rawX = useUiPtr and input.uiX or input.mx -- 430
	local rawY = useUiPtr and input.uiY or input.my -- 431
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 432
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 433
	if btns.retry:containsPoint(pointer) then -- 433
		self.roguelikeUi.deathSelected = 0 -- 435
		return "retry" -- 436
	end -- 436
	if btns.title:containsPoint(pointer) then -- 436
		self.roguelikeUi.deathSelected = 1 -- 439
		return "title" -- 440
	end -- 440
	return "" -- 442
end -- 417
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 445
	if kind == "hover" then -- 445
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 447
	elseif kind == "confirm" then -- 447
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 449
	elseif kind == "back" then -- 449
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 451
	elseif kind == "start" then -- 451
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 453
	elseif kind == "pauseOpen" then -- 453
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 455
	elseif kind == "pauseClose" then -- 455
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 457
	elseif kind == "toggle" then -- 457
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 459
	end -- 459
end -- 445
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 464
	self:syncRuntimeHooks() -- 465
	local safeDt = math.min( -- 466
		0.05, -- 466
		math.max(0, dt) -- 466
	) -- 466
	if self.toastTimer > 0 then -- 466
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 468
	end -- 468
	if self.screen == "title" and self.boundPlay ~= nil then -- 468
		self.audio:stopRoomTransient() -- 471
		self.boundPlay = nil -- 472
	end -- 472
	self.audio:update(safeDt) -- 474
	self.soundscape:updateMenu(self.screen, self.audio) -- 475
	self:setVisible(true) -- 476
	self:clearAll() -- 477
	local uiScale = self:resizeInterface(w, h) -- 478
	local act = self.menus:updateAndDrawScreen( -- 479
		dt, -- 480
		self.screen, -- 481
		input, -- 482
		self.stage, -- 483
		self.bgDraw, -- 484
		self.bgGlow, -- 485
		self.backdropArt, -- 486
		self.uiArt, -- 487
		self.uiDraw, -- 488
		self.uiInkDraw, -- 489
		self.uiGlow, -- 490
		self.texts, -- 491
		w, -- 492
		h, -- 493
		uiScale, -- 494
		self.stageVp.safeUi -- 495
	) -- 495
	self:drawToast(w / uiScale) -- 497
	self:finishFrame() -- 498
	return act -- 499
end -- 464
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 503
	local offers = p:getStoryTalentOffers() -- 504
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 504
		return false -- 506
	end -- 506
	if input.inputMode == "gamepad" and not input.uiPressed then -- 506
		return false -- 509
	end -- 509
	local useUiPtr = input.uiInside or input.uiPressed -- 511
	local ____useUiPtr_3 -- 512
	if useUiPtr then -- 512
		____useUiPtr_3 = input.uiInside -- 512
	else -- 512
		____useUiPtr_3 = input.inside -- 512
	end -- 512
	local inside = ____useUiPtr_3 -- 512
	if not inside then -- 512
		return false -- 514
	end -- 514
	local uiScale = math.max( -- 516
		0.25, -- 516
		math.min(w / 1280, h / 720) -- 516
	) -- 516
	local uiW = w / uiScale -- 517
	local uiH = h / uiScale -- 518
	local rawX = useUiPtr and input.uiX or input.mx -- 519
	local rawY = useUiPtr and input.uiY or input.my -- 520
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 521
	local boxes = self.hud:talentCardRects( -- 522
		uiW, -- 522
		uiH, -- 522
		#offers, -- 522
		input:isTouchMode(), -- 522
		self.stageVp.safeUi.top -- 522
	) -- 522
	local i = 0 -- 523
	do -- 523
		i = 0 -- 524
		while i < #boxes do -- 524
			if boxes[i + 1]:containsPoint(pointer) then -- 524
				return p:chooseTalent(i) -- 526
			end -- 526
			i = i + 1 -- 524
		end -- 524
	end -- 524
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 530
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 531
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 532
end -- 503
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 537
	self:syncRuntimeHooks() -- 538
	self:setVisible(true) -- 539
	if self.boundPlay ~= p then -- 539
		self:bindPlay(p, w, h) -- 541
	end -- 541
	local safeDt = math.min( -- 543
		0.05, -- 543
		math.max(0.001, dt) -- 543
	) -- 543
	if self.toastTimer > 0 then -- 543
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 545
	end -- 545
	self.audio:setPaused(p.paused) -- 547
	self.audio:setCameraRef( -- 548
		self.cam.x, -- 548
		w / math.max(0.25, self.cam.ppu) -- 548
	) -- 548
	self.audio:update(safeDt) -- 549
	local ev -- 551
	local worldDt = 0 -- 552
	local uiDt = 0 -- 553
	if not p.paused then -- 553
		ev = self.adapter:sample(p) -- 557
		self.vfx:ingest(ev, p, self.cam) -- 558
		self.audio:ingestEvents(ev, p) -- 559
		if ev.playerHit then -- 559
			input:vibrate(0.036) -- 561
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 561
			input:vibrate(0.024) -- 563
		elseif ev.coverDeflect then -- 563
			input:vibrate(0.018) -- 565
		elseif ev.knockPulse then -- 565
			input:vibrate(0.014) -- 567
		end -- 567
	else -- 567
		ev = self.adapter:emptyFrame(p) -- 571
		self.narrative.wipeT = 0 -- 572
	end -- 572
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 575
	if not p.paused then -- 575
		local clampedScale = math.max( -- 577
			0, -- 577
			math.min(2, view.timeScale) -- 577
		) -- 577
		uiDt = safeDt -- 578
		worldDt = safeDt * clampedScale -- 579
	end -- 579
	local uiScale = self:resizeInterface(w, h) -- 582
	local uiW = w / uiScale -- 583
	local uiH = h / uiScale -- 584
	local ctx = { -- 586
		p = p, -- 587
		view = view, -- 588
		events = ev, -- 589
		input = input, -- 590
		cam = self.cam, -- 591
		audio = self.audio, -- 592
		assets = self.worldArt, -- 593
		backdropArt = self.backdropArt, -- 594
		worldArt = self.worldArt, -- 595
		uiArt = self.uiArt, -- 596
		uiMask = self.uiMask, -- 597
		dioramaBg = self.dioramaBg, -- 598
		dioramaWorld = self.dioramaWorld, -- 599
		dioramaFg = self.dioramaFg, -- 600
		texts = self.texts, -- 601
		worldDt = worldDt, -- 602
		uiDt = uiDt, -- 603
		w = w, -- 604
		h = h, -- 605
		uiW = uiW, -- 606
		uiH = uiH, -- 607
		uiScale = uiScale, -- 608
		safeUi = self.stageVp.safeUi, -- 609
		paused = p.paused -- 610
	} -- 610
	local i = 0 -- 614
	do -- 614
		i = 0 -- 615
		while i < #self.plugins do -- 615
			local pl = self.plugins[i + 1] -- 616
			if pl.update ~= nil then -- 616
				pl:update(ctx) -- 618
			end -- 618
			i = i + 1 -- 615
		end -- 615
	end -- 615
	self.roguelikeUi:update(ctx) -- 621
	if not p.paused then -- 621
		self.time = self.time + worldDt -- 624
		self.cam:update(worldDt, p, w, h) -- 625
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 626
		self.audio:setCameraRef( -- 627
			self.cam.x, -- 627
			w / math.max(0.25, self.cam.ppu) -- 627
		) -- 627
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 628
		self.actors:update(worldDt, p) -- 629
		self.vfx:update( -- 630
			worldDt, -- 630
			themeOf(p.room.key).ambient -- 630
		) -- 630
		self.hud:update(safeDt, p) -- 631
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 632
	else -- 632
		self.cam:update(0, p, w, h) -- 634
	end -- 634
	self:clearAll() -- 637
	local backdropHandled = false -- 640
	do -- 640
		i = 0 -- 641
		while i < #self.plugins do -- 641
			local pl = self.plugins[i + 1] -- 642
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 642
				backdropHandled = true -- 644
			end -- 644
			i = i + 1 -- 641
		end -- 641
	end -- 641
	if not backdropHandled then -- 641
		self.stage:drawBackdrop( -- 648
			self.bgDraw, -- 648
			self.bgGlow, -- 648
			self.backdropArt, -- 648
			p, -- 648
			self.cam, -- 648
			self.time -- 648
		) -- 648
	end -- 648
	if view.visualMode == "pixel" then -- 648
		self.escortWorld:drawBackdropOverlay( -- 651
			self.bgDraw, -- 651
			self.bgGlow, -- 651
			self.backdropArt, -- 651
			p, -- 651
			self.cam, -- 651
			self.time, -- 651
			self.escortTowerDraw -- 651
		) -- 651
	end -- 651
	local worldHandled = false -- 655
	do -- 655
		i = 0 -- 656
		while i < #self.plugins do -- 656
			local pl = self.plugins[i + 1] -- 657
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 657
				worldHandled = true -- 659
			end -- 659
			i = i + 1 -- 656
		end -- 656
	end -- 656
	if not worldHandled then -- 656
		self.stage:drawPlayableWorld( -- 663
			self.fgDraw, -- 663
			self.fgGlow, -- 663
			self.worldArt, -- 663
			p, -- 663
			self.cam, -- 663
			self.time, -- 663
			self.occlusion, -- 663
			worldDt -- 663
		) -- 663
	end -- 663
	local propsHandled = false -- 667
	do -- 667
		i = 0 -- 668
		while i < #self.plugins do -- 668
			local pl = self.plugins[i + 1] -- 669
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 669
				propsHandled = true -- 671
			end -- 671
			i = i + 1 -- 668
		end -- 668
	end -- 668
	if not propsHandled then -- 668
		self.props:drawAll( -- 675
			self.fgDraw, -- 675
			self.fgGlow, -- 675
			self.worldArt, -- 675
			p, -- 675
			self.cam, -- 675
			self.time, -- 675
			self.occlusion, -- 675
			worldDt -- 675
		) -- 675
	end -- 675
	if view.visualMode == "pixel" then -- 675
		self.escortWorld:drawWorldSetpieces( -- 678
			self.fgDraw, -- 678
			self.fgGlow, -- 678
			self.worldArt, -- 678
			p, -- 678
			view, -- 678
			self.cam, -- 678
			self.time -- 678
		) -- 678
	end -- 678
	if view.visualMode ~= "museum" then -- 678
		local pose -- 683
		for ____, pl in ipairs(self.plugins) do -- 684
			if pl.drawPartyPose ~= nil then -- 684
				pose = pl:drawPartyPose(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 686
				if pose ~= nil then -- 686
					break -- 687
				end -- 687
			end -- 687
		end -- 687
		self.actors:drawAll( -- 690
			self.fgDraw, -- 690
			self.fgGlow, -- 690
			self.worldArt, -- 690
			p, -- 690
			self.cam, -- 690
			pose -- 690
		) -- 690
	end -- 690
	do -- 690
		i = 0 -- 692
		while i < #self.plugins do -- 692
			local pl = self.plugins[i + 1] -- 693
			if pl.drawActorsOverlay ~= nil then -- 693
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 695
			end -- 695
			i = i + 1 -- 692
		end -- 692
	end -- 692
	self.roguelikeUi:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 698
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 701
	if view.visualMode == "pixel" then -- 701
		self.stage:drawForegroundFraming( -- 705
			self.fgDraw, -- 705
			w, -- 705
			h, -- 705
			p, -- 705
			self.cam -- 705
		) -- 705
		self.escortWorld:drawForegroundFraming( -- 706
			self.fgDraw, -- 706
			self.fgGlow, -- 706
			self.worldArt, -- 706
			p, -- 706
			self.cam, -- 706
			self.time -- 706
		) -- 706
	end -- 706
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 708
	local action = {type = "none"} -- 711
	if p.paused then -- 711
		action = self.menus:updateAndDrawPause( -- 713
			safeDt, -- 714
			input, -- 715
			self.uiDraw, -- 716
			self.uiInkDraw, -- 717
			self.uiArt, -- 718
			self.uiGlow, -- 719
			self.texts, -- 720
			uiW, -- 721
			uiH, -- 722
			uiScale, -- 723
			view.assistHintsEnabled, -- 724
			function() -- 725
				self.contract:toggleAssistHints() -- 726
			end, -- 725
			self.stageVp.safeUi, -- 728
			p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom(), -- 729
			view.roguelike.active, -- 730
			function() -- 731
				self.roguelikeUi:openLedger() -- 732
			end -- 731
		) -- 731
	else -- 731
		local cutsceneHandled = false -- 737
		do -- 737
			i = 0 -- 738
			while i < #self.plugins do -- 738
				local pl = self.plugins[i + 1] -- 739
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 739
					self.uiDraw, -- 741
					self.uiInkDraw, -- 741
					self.uiArt, -- 741
					self.uiGlow, -- 741
					ctx -- 741
				) then -- 741
					cutsceneHandled = true -- 742
				end -- 742
				i = i + 1 -- 738
			end -- 738
		end -- 738
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 746
		if not cutsceneHandled and not roguelikeModal then -- 746
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 748
			self.hud:draw( -- 749
				self.uiDraw, -- 750
				self.uiInkDraw, -- 751
				self.uiArt, -- 752
				self.uiGlow, -- 753
				self.texts, -- 754
				p, -- 755
				self.cam, -- 756
				self.vfx, -- 757
				self.narrative.letterbox, -- 758
				uiScale, -- 759
				view.assistHintsEnabled, -- 760
				true, -- 761
				input.inputMode, -- 762
				input.gamepadLayout, -- 763
				self.stageVp.safeUi, -- 764
				input.retryHoldProgress, -- 765
				touchOverlayVisible -- 766
			) -- 766
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 768
			local savedBannerT = self.narrative.bannerT -- 769
			if suppressBanner then -- 769
				self.narrative.bannerT = 0 -- 771
			end -- 771
			self.narrative:draw( -- 773
				self.uiDraw, -- 774
				self.uiInkDraw, -- 775
				self.uiGlow, -- 776
				self.uiArt, -- 777
				self.texts, -- 778
				p, -- 779
				uiW, -- 780
				uiH, -- 781
				view.assistHintsEnabled, -- 782
				input.inputMode, -- 783
				input.gamepadLayout, -- 784
				self.stageVp.safeUi -- 785
			) -- 785
			if suppressBanner then -- 785
				self.narrative.bannerT = savedBannerT -- 788
			end -- 788
		elseif cutsceneHandled then -- 788
			self.narrative:drawCutsceneDialogue( -- 792
				self.uiDraw, -- 793
				self.uiInkDraw, -- 794
				self.uiArt, -- 795
				self.texts, -- 796
				p, -- 797
				uiW, -- 798
				uiH, -- 799
				self.stageVp.safeUi -- 800
			) -- 800
		end -- 800
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 804
		do -- 804
			i = 0 -- 805
			while i < #self.plugins do -- 805
				local pl = self.plugins[i + 1] -- 806
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 806
					self.uiDraw, -- 808
					self.uiInkDraw, -- 808
					self.uiArt, -- 808
					self.uiGlow, -- 808
					ctx -- 808
				) then -- 808
					suppressReticle = true -- 809
				end -- 809
				i = i + 1 -- 805
			end -- 805
		end -- 805
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 805
			self.uiDraw, -- 813
			self.uiInkDraw, -- 813
			self.uiArt, -- 813
			self.uiGlow, -- 813
			ctx -- 813
		) then -- 813
			suppressReticle = true -- 814
		end -- 814
		if not suppressReticle then -- 814
			self.hud:drawReticleOverlay( -- 817
				self.uiInkDraw, -- 818
				self.uiArt, -- 819
				self.uiGlow, -- 820
				p, -- 821
				self.cam, -- 822
				self.vfx, -- 823
				self.narrative.letterbox, -- 824
				uiScale, -- 825
				input:isTouchMode() -- 826
			) -- 826
		end -- 826
		if view.isRehearsal then -- 826
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 832
			drawSilkVeil( -- 833
				self.uiDraw, -- 833
				self.uiArt, -- 833
				"rehearsal_tag_veil", -- 833
				uiW * 0.5, -- 833
				uiH - 22 - self.stageVp.safeUi.top, -- 833
				168, -- 833
				26, -- 833
				PALETTE.inkWarm, -- 833
				0.74, -- 833
				8 -- 833
			) -- 833
			self.texts:put( -- 834
				"xs", -- 834
				badgeText, -- 834
				uiW * 0.5, -- 834
				uiH - 22 - self.stageVp.safeUi.top, -- 834
				toColor(PALETTE.amberCore), -- 834
				0.5, -- 834
				0.5, -- 834
				"Center", -- 834
				1.2, -- 834
				0.92, -- 834
				0.08 -- 834
			) -- 834
		end -- 834
	end -- 834
	self:drawToast(uiW) -- 838
	self:finishFrame() -- 839
	return action -- 840
end -- 537
return ____exports -- 537