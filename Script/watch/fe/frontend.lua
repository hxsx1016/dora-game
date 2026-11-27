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
function WatchFrontend.prototype.____constructor(self, parent) -- 96
	self.occlusion = __TS__New(DepthOcclusion) -- 51
	self.cam = __TS__New(CameraDirector) -- 71
	self.adapter = __TS__New(PlayAdapter) -- 72
	self.contract = __TS__New( -- 73
		DualRouteContract, -- 73
		function(p) return self:canPickStoryTalent(p) end -- 73
	) -- 73
	self.audio = __TS__New(AudioDirector) -- 74
	self.soundscape = __TS__New(SoundscapeDirector) -- 75
	self.stage = __TS__New(StageRenderer) -- 76
	self.escortWorld = __TS__New(EscortWorldRenderer) -- 77
	self.props = __TS__New(PropsRenderer) -- 78
	self.actors = __TS__New(ActorsRenderer) -- 79
	self.sceneFx = __TS__New(SceneFxSystem) -- 80
	self.vfx = __TS__New(VfxSystem) -- 81
	self.hud = __TS__New(HudRenderer) -- 82
	self.narrative = __TS__New(NarrativeRenderer) -- 83
	self.menus = __TS__New(MenuRenderer) -- 84
	self.plugins = {} -- 87
	self.screen = "title" -- 89
	self.time = 0 -- 90
	self.stageVp = computeStageViewport(1280, 720) -- 92
	self.toastText = "" -- 93
	self.toastTimer = 0 -- 94
	self.layerRoot = Node() -- 97
	self.layerRoot.order = 5 -- 98
	self.layerRoot:addTo(parent) -- 99
	ensureSecondHalfAssetsRegistered() -- 100
	self.audio:attachHost(self.layerRoot) -- 102
	self.menus.onUiSound = function(____, kind) -- 103
		self:playMenuUiSound(kind) -- 104
	end -- 103
	self.menus.onAudioSettingsChanged = function(____, inp) -- 106
		self.audio:applyUserVolumes(inp.settings) -- 107
	end -- 106
	local additive = BlendFunc("SrcAlpha", "One") -- 110
	self.bgDraw = DrawNode() -- 112
	self.bgDraw.order = 10 -- 113
	self.bgDraw:addTo(self.layerRoot) -- 114
	self.escortTowerDraw = DrawNode() -- 117
	self.escortTowerDraw.order = 13 -- 118
	self.escortTowerDraw:addTo(self.layerRoot) -- 119
	self.bgGlow = DrawNode() -- 121
	self.bgGlow.order = 15 -- 122
	self.bgGlow.blendFunc = additive -- 123
	self.bgGlow:addTo(self.layerRoot) -- 124
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 126
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 127
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 128
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 129
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 130
	self.fgDraw = DrawNode() -- 132
	self.fgDraw.order = 30 -- 133
	self.fgDraw:addTo(self.layerRoot) -- 134
	self.fgGlow = DrawNode() -- 136
	self.fgGlow.order = 35 -- 137
	self.fgGlow.blendFunc = additive -- 138
	self.fgGlow:addTo(self.layerRoot) -- 139
	self.uiLayer = Node() -- 141
	self.uiLayer.order = 40 -- 142
	self.uiLayer:addTo(self.layerRoot) -- 143
	self.uiDraw = DrawNode() -- 145
	self.uiDraw.order = 0 -- 146
	self.uiDraw:addTo(self.uiLayer) -- 147
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 149
	self.uiInkDraw = DrawNode() -- 151
	self.uiInkDraw.order = 4 -- 152
	self.uiInkDraw:addTo(self.uiLayer) -- 153
	self.uiGlow = DrawNode() -- 155
	self.uiGlow.order = 6 -- 156
	self.uiGlow.blendFunc = additive -- 157
	self.uiGlow:addTo(self.uiLayer) -- 158
	self.uiMask = DrawNode() -- 160
	self.uiMask.order = 8 -- 161
	self.uiMask:addTo(self.uiLayer) -- 162
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 164
	self.roguelikeUi = __TS__New( -- 168
		RoguelikeUiPlugin, -- 168
		self.contract, -- 169
		function() return self.hud.talentSelected end, -- 170
		function(idx) -- 171
			self.hud.talentSelected = idx -- 172
		end -- 171
	) -- 171
	self.hud.roguelikeUiHandled = true -- 175
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) return self.roguelikeUi:getTalentCardRects( -- 176
		w, -- 177
		h, -- 177
		count, -- 177
		touchMode, -- 177
		safeTop -- 177
	) end -- 177
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 191
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 192
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 193
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 194
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 195
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 196
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 197
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 198
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 199
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 200
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 201
end -- 96
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 205
	local i = 0 -- 206
	do -- 206
		i = 0 -- 207
		while i < #self.plugins do -- 207
			if self.plugins[i + 1].id == plugin.id then -- 207
				self.plugins[i + 1] = plugin -- 209
				self:syncRuntimeHooks() -- 210
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 210
					plugin:onBindPlay( -- 212
						self.boundPlay, -- 212
						self.contract:peekSnapshot(self.boundPlay) -- 212
					) -- 212
				end -- 212
				return -- 214
			end -- 214
			i = i + 1 -- 207
		end -- 207
	end -- 207
	local ____self_plugins_0 = self.plugins -- 207
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 217
	self:syncRuntimeHooks() -- 218
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 218
		plugin:onBindPlay( -- 220
			self.boundPlay, -- 220
			self.contract:peekSnapshot(self.boundPlay) -- 220
		) -- 220
	end -- 220
end -- 205
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 225
	local w = 0 -- 226
	local i = 0 -- 227
	do -- 227
		i = 0 -- 228
		while i < #self.plugins do -- 228
			if self.plugins[i + 1].id ~= id then -- 228
				self.plugins[w + 1] = self.plugins[i + 1] -- 230
				w = w + 1 -- 231
			end -- 231
			i = i + 1 -- 228
		end -- 228
	end -- 228
	__TS__ArraySetLength(self.plugins, w) -- 228
	self:syncRuntimeHooks() -- 235
end -- 225
function WatchFrontend.prototype.getPlugin(self, id) -- 239
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 239
		return self.roguelikeUi -- 241
	end -- 241
	local i = 0 -- 243
	do -- 243
		i = 0 -- 244
		while i < #self.plugins do -- 244
			if self.plugins[i + 1].id == id then -- 244
				return self.plugins[i + 1] -- 246
			end -- 246
			i = i + 1 -- 244
		end -- 244
	end -- 244
	return nil -- 249
end -- 239
function WatchFrontend.prototype.getPlugins(self) -- 252
	return self.plugins -- 253
end -- 252
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 261
	local g = _G -- 262
	local ____temp_1 -- 263
	if g.package ~= nil then -- 263
		____temp_1 = g.package.loaded -- 263
	else -- 263
		____temp_1 = nil -- 263
	end -- 263
	local loaded = ____temp_1 -- 263
	if loaded == nil then -- 263
		return -- 265
	end -- 265
	local rawFe = loaded["watch.fe"] -- 267
	if rawFe ~= nil and type(rawFe) == "table" then -- 267
		local watchFe = rawFe -- 269
		if watchFe.contract ~= self.contract then -- 269
			watchFe.contract = self.contract -- 271
			watchFe.audio = self.audio -- 272
			watchFe.soundscape = self.soundscape -- 273
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 274
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 275
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 276
		end -- 276
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 278
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 279
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 280
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 281
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 282
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 283
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 284
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 285
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 286
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 287
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 288
		watchFe.roguelikeUi = self.roguelikeUi -- 289
	end -- 289
end -- 261
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 293
	local scale = math.max( -- 294
		0.25, -- 294
		math.min(w / 1280, h / 720) -- 294
	) -- 294
	self.uiLayer.scaleX = scale -- 295
	self.uiLayer.scaleY = scale -- 296
	return scale -- 297
end -- 293
function WatchFrontend.prototype.setVisible(self, v) -- 301
	self.layerRoot.visible = v -- 302
	if not v then -- 302
		self.texts:hideAll() -- 304
	end -- 304
end -- 301
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 309
	self:syncRuntimeHooks() -- 310
	self.boundPlay = p -- 311
	p.useEscortDeathSummary = true -- 312
	p:openTalentDraft() -- 313
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 314
	self.cam:snap(p, w, h) -- 315
	self.adapter:reset(p) -- 316
	self.contract:resetForRoom(p) -- 317
	self.audio:stopRoomTransient() -- 318
	self.soundscape:resetForRoom(p) -- 319
	self.actors:reset(p) -- 320
	self.sceneFx:reset(p.room.key) -- 321
	self.occlusion:reset() -- 322
	self.vfx:reset() -- 323
	self.hud:reset(p) -- 324
	self.narrative:onEnterRoom(p.room.key) -- 325
	local initView = self.contract:peekSnapshot(p) -- 327
	if #self.plugins > 0 then -- 327
		local i = 0 -- 329
		do -- 329
			i = 0 -- 330
			while i < #self.plugins do -- 330
				local pl = self.plugins[i + 1] -- 331
				if pl.onBindPlay ~= nil then -- 331
					pl:onBindPlay(p, initView) -- 333
				end -- 333
				i = i + 1 -- 330
			end -- 330
		end -- 330
	end -- 330
	self.roguelikeUi:onBindPlay(p, initView) -- 337
end -- 309
function WatchFrontend.prototype.clearAll(self) -- 340
	self.bgDraw:clear() -- 341
	self.escortTowerDraw:clear() -- 342
	self.bgGlow:clear() -- 343
	self.fgDraw:clear() -- 344
	self.fgGlow:clear() -- 345
	self.uiDraw:clear() -- 346
	self.uiInkDraw:clear() -- 347
	self.uiGlow:clear() -- 348
	self.uiMask:clear() -- 349
	self.backdropArt:beginFrame() -- 350
	self.dioramaBg:beginFrame() -- 351
	self.dioramaWorld:beginFrame() -- 352
	self.dioramaFg:beginFrame() -- 353
	self.worldArt:beginFrame() -- 354
	self.uiArt:beginFrame() -- 355
	self.texts:beginFrame() -- 356
end -- 340
function WatchFrontend.prototype.finishFrame(self) -- 359
	self.backdropArt:endFrame() -- 360
	self.dioramaBg:endFrame() -- 361
	self.dioramaWorld:endFrame() -- 362
	self.dioramaFg:endFrame() -- 363
	self.worldArt:endFrame() -- 364
	self.uiArt:endFrame() -- 365
	self.texts:endFrame() -- 366
end -- 359
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 370
	self.stageVp = vp -- 371
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 372
end -- 370
function WatchFrontend.prototype.showToast(self, text, duration) -- 376
	if duration == nil then -- 376
		duration = 1.8 -- 376
	end -- 376
	self.toastText = text -- 377
	self.toastTimer = duration -- 378
end -- 376
function WatchFrontend.prototype.getToastText(self) -- 381
	return self.toastTimer > 0 and self.toastText or "" -- 382
end -- 381
function WatchFrontend.prototype.drawToast(self, uiW) -- 385
	if self.toastTimer <= 0 or self.toastText == "" then -- 385
		return -- 387
	end -- 387
	local alpha = math.min(1, self.toastTimer * 2.4) -- 389
	local cx = uiW * 0.5 -- 390
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 391
	drawSilkVeil( -- 392
		self.uiDraw, -- 392
		self.uiArt, -- 392
		"fe_toast_veil", -- 392
		cx, -- 392
		cy, -- 392
		340, -- 392
		38, -- 392
		PALETTE.inkWarm, -- 392
		0.86 * alpha, -- 392
		9 -- 392
	) -- 392
	self.texts:put( -- 393
		"sm", -- 393
		self.toastText, -- 393
		cx, -- 393
		cy, -- 393
		toColor(PALETTE.amberCore), -- 393
		0.5, -- 393
		0.5, -- 393
		"Center", -- 393
		1.4, -- 393
		0.96 * alpha, -- 393
		0.08 -- 393
	) -- 393
end -- 385
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 396
	return not p.escortFailed and not p.paused and not p.craftBench.active and not p.reloadOpen and self.roguelikeUi:canPickTalent() -- 397
end -- 396
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 401
	local offers = p:getStoryTalentOffers() -- 402
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 402
		return {} -- 404
	end -- 404
	local uiScale = math.max( -- 406
		0.25, -- 406
		math.min(w / 1280, h / 720) -- 406
	) -- 406
	return self.hud:talentCardRects( -- 407
		w / uiScale, -- 407
		h / uiScale, -- 407
		#offers, -- 407
		touchMode, -- 407
		self.stageVp.safeUi.top -- 407
	) -- 407
end -- 401
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 411
	if not p.escortFailed then -- 411
		return nil -- 413
	end -- 413
	local uiScale = math.max( -- 415
		0.25, -- 415
		math.min(w / 1280, h / 720) -- 415
	) -- 415
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 416
end -- 411
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 420
	if not p.escortFailed then -- 420
		return "" -- 422
	end -- 422
	if input.inputMode == "gamepad" and not input.uiPressed then -- 422
		return "" -- 425
	end -- 425
	local useUiPtr = input.uiInside or input.uiPressed -- 427
	local ____useUiPtr_2 -- 428
	if useUiPtr then -- 428
		____useUiPtr_2 = input.uiInside -- 428
	else -- 428
		____useUiPtr_2 = input.inside -- 428
	end -- 428
	local inside = ____useUiPtr_2 -- 428
	if not inside then -- 428
		return "" -- 430
	end -- 430
	local uiScale = math.max( -- 432
		0.25, -- 432
		math.min(w / 1280, h / 720) -- 432
	) -- 432
	local rawX = useUiPtr and input.uiX or input.mx -- 433
	local rawY = useUiPtr and input.uiY or input.my -- 434
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 435
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 436
	if btns.retry:containsPoint(pointer) then -- 436
		self.roguelikeUi.deathSelected = 0 -- 438
		return "retry" -- 439
	end -- 439
	if btns.title:containsPoint(pointer) then -- 439
		self.roguelikeUi.deathSelected = 1 -- 442
		return "title" -- 443
	end -- 443
	return "" -- 445
end -- 420
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 448
	if kind == "hover" then -- 448
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 450
	elseif kind == "confirm" then -- 450
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 452
	elseif kind == "back" then -- 452
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 454
	elseif kind == "start" then -- 454
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 456
	elseif kind == "pauseOpen" then -- 456
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 458
	elseif kind == "pauseClose" then -- 458
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 460
	elseif kind == "toggle" then -- 460
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 462
	end -- 462
end -- 448
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 467
	self:syncRuntimeHooks() -- 468
	local safeDt = math.min( -- 469
		0.05, -- 469
		math.max(0, dt) -- 469
	) -- 469
	self.time = self.time + safeDt -- 470
	if self.toastTimer > 0 then -- 470
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 472
	end -- 472
	if self.screen == "title" and self.boundPlay ~= nil then -- 472
		self.audio:stopRoomTransient() -- 475
		self.boundPlay = nil -- 476
	end -- 476
	self.audio:update(safeDt) -- 478
	self.soundscape:updateMenu(self.screen, self.audio) -- 479
	self:setVisible(true) -- 480
	self:clearAll() -- 481
	local uiScale = self:resizeInterface(w, h) -- 482
	local act = self.menus:updateAndDrawScreen( -- 483
		dt, -- 484
		self.screen, -- 485
		input, -- 486
		self.stage, -- 487
		self.bgDraw, -- 488
		self.bgGlow, -- 489
		self.backdropArt, -- 490
		self.uiArt, -- 491
		self.uiDraw, -- 492
		self.uiInkDraw, -- 493
		self.uiGlow, -- 494
		self.texts, -- 495
		w, -- 496
		h, -- 497
		uiScale, -- 498
		self.stageVp.safeUi -- 499
	) -- 499
	if self.screen == "title" then -- 499
		self.sceneFx:drawTitleAtmosphere( -- 502
			self.bgGlow, -- 502
			self.fgGlow, -- 502
			self.backdropArt, -- 502
			self.worldArt, -- 502
			w, -- 502
			h, -- 502
			self.time -- 502
		) -- 502
	end -- 502
	self:drawToast(w / uiScale) -- 504
	self:finishFrame() -- 505
	return act -- 506
end -- 467
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 510
	local offers = p:getStoryTalentOffers() -- 511
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 511
		return false -- 513
	end -- 513
	if input.inputMode == "gamepad" and not input.uiPressed then -- 513
		return false -- 516
	end -- 516
	local useUiPtr = input.uiInside or input.uiPressed -- 518
	local ____useUiPtr_3 -- 519
	if useUiPtr then -- 519
		____useUiPtr_3 = input.uiInside -- 519
	else -- 519
		____useUiPtr_3 = input.inside -- 519
	end -- 519
	local inside = ____useUiPtr_3 -- 519
	if not inside then -- 519
		return false -- 521
	end -- 521
	local uiScale = math.max( -- 523
		0.25, -- 523
		math.min(w / 1280, h / 720) -- 523
	) -- 523
	local uiW = w / uiScale -- 524
	local uiH = h / uiScale -- 525
	local rawX = useUiPtr and input.uiX or input.mx -- 526
	local rawY = useUiPtr and input.uiY or input.my -- 527
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 528
	local boxes = self.hud:talentCardRects( -- 529
		uiW, -- 529
		uiH, -- 529
		#offers, -- 529
		input:isTouchMode(), -- 529
		self.stageVp.safeUi.top -- 529
	) -- 529
	local i = 0 -- 530
	do -- 530
		i = 0 -- 531
		while i < #boxes do -- 531
			if boxes[i + 1]:containsPoint(pointer) then -- 531
				return p:chooseTalent(i) -- 533
			end -- 533
			i = i + 1 -- 531
		end -- 531
	end -- 531
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 537
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 538
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 539
end -- 510
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 544
	self:syncRuntimeHooks() -- 545
	self:setVisible(true) -- 546
	if self.boundPlay ~= p then -- 546
		self:bindPlay(p, w, h) -- 548
	end -- 548
	local safeDt = math.min( -- 550
		0.05, -- 550
		math.max(0.001, dt) -- 550
	) -- 550
	if self.toastTimer > 0 then -- 550
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 552
	end -- 552
	self.audio:setPaused(p.paused) -- 554
	self.audio:setCameraRef( -- 555
		self.cam.x, -- 555
		w / math.max(0.25, self.cam.ppu) -- 555
	) -- 555
	self.audio:update(safeDt) -- 556
	local ev -- 558
	local worldDt = 0 -- 559
	local uiDt = 0 -- 560
	if not p.paused then -- 560
		ev = self.adapter:sample(p) -- 564
		self.vfx:ingest(ev, p, self.cam) -- 565
		self.audio:ingestEvents(ev, p) -- 566
		if ev.playerHit then -- 566
			input:vibrate(0.036) -- 568
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 568
			input:vibrate(0.024) -- 570
		elseif ev.coverDeflect then -- 570
			input:vibrate(0.018) -- 572
		elseif ev.knockPulse then -- 572
			input:vibrate(0.014) -- 574
		end -- 574
	else -- 574
		ev = self.adapter:emptyFrame(p) -- 578
		self.narrative.wipeT = 0 -- 579
	end -- 579
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 582
	if not p.paused then -- 582
		local clampedScale = math.max( -- 584
			0, -- 584
			math.min(2, view.timeScale) -- 584
		) -- 584
		uiDt = safeDt -- 585
		worldDt = safeDt * clampedScale -- 586
	end -- 586
	local uiScale = self:resizeInterface(w, h) -- 589
	local uiW = w / uiScale -- 590
	local uiH = h / uiScale -- 591
	local ctx = { -- 593
		p = p, -- 594
		view = view, -- 595
		events = ev, -- 596
		input = input, -- 597
		cam = self.cam, -- 598
		audio = self.audio, -- 599
		assets = self.worldArt, -- 600
		backdropArt = self.backdropArt, -- 601
		worldArt = self.worldArt, -- 602
		uiArt = self.uiArt, -- 603
		uiMask = self.uiMask, -- 604
		dioramaBg = self.dioramaBg, -- 605
		dioramaWorld = self.dioramaWorld, -- 606
		dioramaFg = self.dioramaFg, -- 607
		texts = self.texts, -- 608
		worldDt = worldDt, -- 609
		uiDt = uiDt, -- 610
		w = w, -- 611
		h = h, -- 612
		uiW = uiW, -- 613
		uiH = uiH, -- 614
		uiScale = uiScale, -- 615
		safeUi = self.stageVp.safeUi, -- 616
		paused = p.paused -- 617
	} -- 617
	local i = 0 -- 621
	do -- 621
		i = 0 -- 622
		while i < #self.plugins do -- 622
			local pl = self.plugins[i + 1] -- 623
			if pl.update ~= nil then -- 623
				pl:update(ctx) -- 625
			end -- 625
			i = i + 1 -- 622
		end -- 622
	end -- 622
	self.roguelikeUi:update(ctx) -- 628
	if not p.paused then -- 628
		self.time = self.time + worldDt -- 631
		self.cam:update(worldDt, p, w, h) -- 632
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 633
		self.audio:setCameraRef( -- 634
			self.cam.x, -- 634
			w / math.max(0.25, self.cam.ppu) -- 634
		) -- 634
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 635
		self.actors:update(worldDt, p) -- 636
		self.vfx:ingestFootsteps(self.actors:drainFootsteps()) -- 637
		self.sceneFx:update(worldDt, p, self.cam) -- 638
		self.vfx:update( -- 639
			worldDt, -- 639
			themeOf(p.room.key).ambient -- 639
		) -- 639
		self.hud:update(safeDt, p) -- 640
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 641
	else -- 641
		self.cam:update(0, p, w, h) -- 643
	end -- 643
	self:clearAll() -- 646
	local backdropHandled = false -- 649
	do -- 649
		i = 0 -- 650
		while i < #self.plugins do -- 650
			local pl = self.plugins[i + 1] -- 651
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 651
				backdropHandled = true -- 653
			end -- 653
			i = i + 1 -- 650
		end -- 650
	end -- 650
	if not backdropHandled then -- 650
		self.stage:drawBackdrop( -- 657
			self.bgDraw, -- 657
			self.bgGlow, -- 657
			self.backdropArt, -- 657
			p, -- 657
			self.cam, -- 657
			self.time -- 657
		) -- 657
	end -- 657
	if view.visualMode == "pixel" then -- 657
		self.escortWorld:drawBackdropOverlay( -- 660
			self.bgDraw, -- 660
			self.bgGlow, -- 660
			self.backdropArt, -- 660
			p, -- 660
			self.cam, -- 660
			self.time, -- 660
			self.escortTowerDraw -- 660
		) -- 660
		self.sceneFx:drawBackdropFx( -- 661
			self.bgDraw, -- 661
			self.bgGlow, -- 661
			self.backdropArt, -- 661
			p, -- 661
			self.cam -- 661
		) -- 661
	end -- 661
	local worldHandled = false -- 665
	do -- 665
		i = 0 -- 666
		while i < #self.plugins do -- 666
			local pl = self.plugins[i + 1] -- 667
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 667
				worldHandled = true -- 669
			end -- 669
			i = i + 1 -- 666
		end -- 666
	end -- 666
	if not worldHandled then -- 666
		self.stage:drawPlayableWorld( -- 673
			self.fgDraw, -- 673
			self.fgGlow, -- 673
			self.worldArt, -- 673
			p, -- 673
			self.cam, -- 673
			self.time, -- 673
			self.occlusion, -- 673
			worldDt -- 673
		) -- 673
	end -- 673
	local propsHandled = false -- 677
	do -- 677
		i = 0 -- 678
		while i < #self.plugins do -- 678
			local pl = self.plugins[i + 1] -- 679
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 679
				propsHandled = true -- 681
			end -- 681
			i = i + 1 -- 678
		end -- 678
	end -- 678
	if not propsHandled then -- 678
		self.props:drawAll( -- 685
			self.fgDraw, -- 685
			self.fgGlow, -- 685
			self.worldArt, -- 685
			p, -- 685
			self.cam, -- 685
			self.time, -- 685
			self.occlusion, -- 685
			worldDt -- 685
		) -- 685
	end -- 685
	if view.visualMode == "pixel" then -- 685
		self.escortWorld:drawWorldSetpieces( -- 688
			self.fgDraw, -- 688
			self.fgGlow, -- 688
			self.worldArt, -- 688
			p, -- 688
			view, -- 688
			self.cam, -- 688
			self.time -- 688
		) -- 688
		self.sceneFx:drawWorldFx( -- 689
			self.fgDraw, -- 689
			self.fgGlow, -- 689
			self.worldArt, -- 689
			p, -- 689
			self.cam -- 689
		) -- 689
	end -- 689
	if view.visualMode ~= "museum" then -- 689
		local pose -- 694
		for ____, pl in ipairs(self.plugins) do -- 695
			if pl.drawPartyPose ~= nil then -- 695
				pose = pl:drawPartyPose(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 697
				if pose ~= nil then -- 697
					break -- 698
				end -- 698
			end -- 698
		end -- 698
		self.actors:drawAll( -- 701
			self.fgDraw, -- 701
			self.fgGlow, -- 701
			self.worldArt, -- 701
			p, -- 701
			self.cam, -- 701
			pose -- 701
		) -- 701
	end -- 701
	do -- 701
		i = 0 -- 703
		while i < #self.plugins do -- 703
			local pl = self.plugins[i + 1] -- 704
			if pl.drawActorsOverlay ~= nil then -- 704
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 706
			end -- 706
			i = i + 1 -- 703
		end -- 703
	end -- 703
	self.roguelikeUi:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 709
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 712
	if view.visualMode == "pixel" then -- 712
		self.stage:drawForegroundFraming( -- 716
			self.fgDraw, -- 716
			w, -- 716
			h, -- 716
			p, -- 716
			self.cam -- 716
		) -- 716
		self.escortWorld:drawForegroundFraming( -- 717
			self.fgDraw, -- 717
			self.fgGlow, -- 717
			self.worldArt, -- 717
			p, -- 717
			self.cam, -- 717
			self.time -- 717
		) -- 717
		self.sceneFx:drawForegroundWeather( -- 718
			self.fgGlow, -- 718
			p, -- 718
			self.cam, -- 718
			w, -- 718
			h -- 718
		) -- 718
	end -- 718
	self.vfx:drawScreenVfx( -- 720
		self.fgGlow, -- 720
		w, -- 720
		h, -- 720
		p.room.key, -- 720
		view.visualMode ~= "pixel" -- 720
	) -- 720
	local action = {type = "none"} -- 723
	if p.paused then -- 723
		action = self.menus:updateAndDrawPause( -- 725
			safeDt, -- 726
			input, -- 727
			self.uiDraw, -- 728
			self.uiInkDraw, -- 729
			self.uiArt, -- 730
			self.uiGlow, -- 731
			self.texts, -- 732
			uiW, -- 733
			uiH, -- 734
			uiScale, -- 735
			view.assistHintsEnabled, -- 736
			function() -- 737
				self.contract:toggleAssistHints() -- 738
			end, -- 737
			self.stageVp.safeUi, -- 740
			p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom(), -- 741
			view.roguelike.active, -- 742
			function() -- 743
				self.roguelikeUi:openLedger() -- 744
			end -- 743
		) -- 743
	else -- 743
		local cutsceneHandled = false -- 749
		do -- 749
			i = 0 -- 750
			while i < #self.plugins do -- 750
				local pl = self.plugins[i + 1] -- 751
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 751
					self.uiDraw, -- 753
					self.uiInkDraw, -- 753
					self.uiArt, -- 753
					self.uiGlow, -- 753
					ctx -- 753
				) then -- 753
					cutsceneHandled = true -- 754
				end -- 754
				i = i + 1 -- 750
			end -- 750
		end -- 750
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 758
		if not cutsceneHandled and not roguelikeModal then -- 758
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 760
			self.hud:draw( -- 761
				self.uiDraw, -- 762
				self.uiInkDraw, -- 763
				self.uiArt, -- 764
				self.uiGlow, -- 765
				self.texts, -- 766
				p, -- 767
				self.cam, -- 768
				self.vfx, -- 769
				self.narrative.letterbox, -- 770
				uiScale, -- 771
				view.assistHintsEnabled, -- 772
				true, -- 773
				input.inputMode, -- 774
				input.gamepadLayout, -- 775
				self.stageVp.safeUi, -- 776
				input.retryHoldProgress, -- 777
				touchOverlayVisible -- 778
			) -- 778
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 780
			local savedBannerT = self.narrative.bannerT -- 781
			if suppressBanner then -- 781
				self.narrative.bannerT = 0 -- 783
			end -- 783
			self.narrative:draw( -- 785
				self.uiDraw, -- 786
				self.uiInkDraw, -- 787
				self.uiGlow, -- 788
				self.uiArt, -- 789
				self.texts, -- 790
				p, -- 791
				uiW, -- 792
				uiH, -- 793
				view.assistHintsEnabled, -- 794
				input.inputMode, -- 795
				input.gamepadLayout, -- 796
				self.stageVp.safeUi -- 797
			) -- 797
			if suppressBanner then -- 797
				self.narrative.bannerT = savedBannerT -- 800
			end -- 800
		elseif cutsceneHandled then -- 800
			self.narrative:drawCutsceneDialogue( -- 804
				self.uiDraw, -- 805
				self.uiInkDraw, -- 806
				self.uiArt, -- 807
				self.texts, -- 808
				p, -- 809
				uiW, -- 810
				uiH, -- 811
				self.stageVp.safeUi -- 812
			) -- 812
		end -- 812
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 816
		do -- 816
			i = 0 -- 817
			while i < #self.plugins do -- 817
				local pl = self.plugins[i + 1] -- 818
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 818
					self.uiDraw, -- 820
					self.uiInkDraw, -- 820
					self.uiArt, -- 820
					self.uiGlow, -- 820
					ctx -- 820
				) then -- 820
					suppressReticle = true -- 821
				end -- 821
				i = i + 1 -- 817
			end -- 817
		end -- 817
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 817
			self.uiDraw, -- 825
			self.uiInkDraw, -- 825
			self.uiArt, -- 825
			self.uiGlow, -- 825
			ctx -- 825
		) then -- 825
			suppressReticle = true -- 826
		end -- 826
		if not suppressReticle then -- 826
			self.hud:drawReticleOverlay( -- 829
				self.uiInkDraw, -- 830
				self.uiArt, -- 831
				self.uiGlow, -- 832
				p, -- 833
				self.cam, -- 834
				self.vfx, -- 835
				self.narrative.letterbox, -- 836
				uiScale, -- 837
				input:isTouchMode() -- 838
			) -- 838
		end -- 838
		if view.isRehearsal then -- 838
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 844
			drawSilkVeil( -- 845
				self.uiDraw, -- 845
				self.uiArt, -- 845
				"rehearsal_tag_veil", -- 845
				uiW * 0.5, -- 845
				uiH - 22 - self.stageVp.safeUi.top, -- 845
				168, -- 845
				26, -- 845
				PALETTE.inkWarm, -- 845
				0.74, -- 845
				8 -- 845
			) -- 845
			self.texts:put( -- 846
				"xs", -- 846
				badgeText, -- 846
				uiW * 0.5, -- 846
				uiH - 22 - self.stageVp.safeUi.top, -- 846
				toColor(PALETTE.amberCore), -- 846
				0.5, -- 846
				0.5, -- 846
				"Center", -- 846
				1.2, -- 846
				0.92, -- 846
				0.08 -- 846
			) -- 846
		end -- 846
	end -- 846
	self:drawToast(uiW) -- 850
	self:finishFrame() -- 851
	return action -- 852
end -- 544
return ____exports -- 544