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
local ____xiaoman3d = require("Script.watch.fe.scenes.xiaoman3d") -- 38
local Xiaoman3DScene = ____xiaoman3d.Xiaoman3DScene -- 38
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
	self.vfx = __TS__New(VfxSystem) -- 80
	self.hud = __TS__New(HudRenderer) -- 81
	self.narrative = __TS__New(NarrativeRenderer) -- 82
	self.menus = __TS__New(MenuRenderer) -- 83
	self.plugins = {} -- 86
	self.screen = "title" -- 89
	self.time = 0 -- 90
	self.stageVp = computeStageViewport(1280, 720) -- 92
	self.toastText = "" -- 93
	self.toastTimer = 0 -- 94
	self.layerRoot = Node() -- 97
	self.layerRoot.order = 5 -- 98
	self.layerRoot:addTo(parent) -- 99
	ensureSecondHalfAssetsRegistered() -- 100
	self.xiaoman3d = __TS__New(Xiaoman3DScene, self.layerRoot) -- 101
	self.audio:attachHost(self.layerRoot) -- 103
	self.menus.onUiSound = function(____, kind) -- 104
		self:playMenuUiSound(kind) -- 105
	end -- 104
	self.menus.onAudioSettingsChanged = function(____, inp) -- 107
		self.audio:applyUserVolumes(inp.settings) -- 108
	end -- 107
	local additive = BlendFunc("SrcAlpha", "One") -- 111
	self.bgDraw = DrawNode() -- 113
	self.bgDraw.order = 10 -- 114
	self.bgDraw:addTo(self.layerRoot) -- 115
	self.escortTowerDraw = DrawNode() -- 118
	self.escortTowerDraw.order = 13 -- 119
	self.escortTowerDraw:addTo(self.layerRoot) -- 120
	self.bgGlow = DrawNode() -- 122
	self.bgGlow.order = 15 -- 123
	self.bgGlow.blendFunc = additive -- 124
	self.bgGlow:addTo(self.layerRoot) -- 125
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 127
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 128
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 129
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 130
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 131
	self.fgDraw = DrawNode() -- 133
	self.fgDraw.order = 30 -- 134
	self.fgDraw:addTo(self.layerRoot) -- 135
	self.fgGlow = DrawNode() -- 137
	self.fgGlow.order = 35 -- 138
	self.fgGlow.blendFunc = additive -- 139
	self.fgGlow:addTo(self.layerRoot) -- 140
	self.uiLayer = Node() -- 142
	self.uiLayer.order = 40 -- 143
	self.uiLayer:addTo(self.layerRoot) -- 144
	self.uiDraw = DrawNode() -- 146
	self.uiDraw.order = 0 -- 147
	self.uiDraw:addTo(self.uiLayer) -- 148
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 150
	self.uiInkDraw = DrawNode() -- 152
	self.uiInkDraw.order = 4 -- 153
	self.uiInkDraw:addTo(self.uiLayer) -- 154
	self.uiGlow = DrawNode() -- 156
	self.uiGlow.order = 6 -- 157
	self.uiGlow.blendFunc = additive -- 158
	self.uiGlow:addTo(self.uiLayer) -- 159
	self.uiMask = DrawNode() -- 161
	self.uiMask.order = 8 -- 162
	self.uiMask:addTo(self.uiLayer) -- 163
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 165
	self.roguelikeUi = __TS__New( -- 169
		RoguelikeUiPlugin, -- 169
		self.contract, -- 170
		function() return self.hud.talentSelected end, -- 171
		function(idx) -- 172
			self.hud.talentSelected = idx -- 173
		end -- 172
	) -- 172
	self.hud.roguelikeUiHandled = true -- 176
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) return self.roguelikeUi:getTalentCardRects( -- 177
		w, -- 178
		h, -- 178
		count, -- 178
		touchMode, -- 178
		safeTop -- 178
	) end -- 178
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 192
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 193
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 194
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 195
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 196
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 197
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 198
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 199
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 200
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 201
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 202
end -- 96
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 206
	local i = 0 -- 207
	do -- 207
		i = 0 -- 208
		while i < #self.plugins do -- 208
			if self.plugins[i + 1].id == plugin.id then -- 208
				self.plugins[i + 1] = plugin -- 210
				self:syncRuntimeHooks() -- 211
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 211
					plugin:onBindPlay( -- 213
						self.boundPlay, -- 213
						self.contract:peekSnapshot(self.boundPlay) -- 213
					) -- 213
				end -- 213
				return -- 215
			end -- 215
			i = i + 1 -- 208
		end -- 208
	end -- 208
	local ____self_plugins_0 = self.plugins -- 208
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 218
	self:syncRuntimeHooks() -- 219
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 219
		plugin:onBindPlay( -- 221
			self.boundPlay, -- 221
			self.contract:peekSnapshot(self.boundPlay) -- 221
		) -- 221
	end -- 221
end -- 206
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 226
	local w = 0 -- 227
	local i = 0 -- 228
	do -- 228
		i = 0 -- 229
		while i < #self.plugins do -- 229
			if self.plugins[i + 1].id ~= id then -- 229
				self.plugins[w + 1] = self.plugins[i + 1] -- 231
				w = w + 1 -- 232
			end -- 232
			i = i + 1 -- 229
		end -- 229
	end -- 229
	__TS__ArraySetLength(self.plugins, w) -- 229
	self:syncRuntimeHooks() -- 236
end -- 226
function WatchFrontend.prototype.getPlugin(self, id) -- 240
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 240
		return self.roguelikeUi -- 242
	end -- 242
	local i = 0 -- 244
	do -- 244
		i = 0 -- 245
		while i < #self.plugins do -- 245
			if self.plugins[i + 1].id == id then -- 245
				return self.plugins[i + 1] -- 247
			end -- 247
			i = i + 1 -- 245
		end -- 245
	end -- 245
	return nil -- 250
end -- 240
function WatchFrontend.prototype.getPlugins(self) -- 253
	return self.plugins -- 254
end -- 253
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 262
	local g = _G -- 263
	local ____temp_1 -- 264
	if g.package ~= nil then -- 264
		____temp_1 = g.package.loaded -- 264
	else -- 264
		____temp_1 = nil -- 264
	end -- 264
	local loaded = ____temp_1 -- 264
	if loaded == nil then -- 264
		return -- 266
	end -- 266
	local rawFe = loaded["watch.fe"] -- 268
	if rawFe ~= nil and type(rawFe) == "table" then -- 268
		local watchFe = rawFe -- 270
		if watchFe.contract ~= self.contract then -- 270
			watchFe.contract = self.contract -- 272
			watchFe.audio = self.audio -- 273
			watchFe.soundscape = self.soundscape -- 274
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 275
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 276
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 277
		end -- 277
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 279
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 280
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 281
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 282
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 283
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 284
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 285
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 286
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 287
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 288
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 289
		watchFe.roguelikeUi = self.roguelikeUi -- 290
	end -- 290
end -- 262
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 294
	local scale = math.max( -- 295
		0.25, -- 295
		math.min(w / 1280, h / 720) -- 295
	) -- 295
	self.uiLayer.scaleX = scale -- 296
	self.uiLayer.scaleY = scale -- 297
	return scale -- 298
end -- 294
function WatchFrontend.prototype.setVisible(self, v) -- 302
	self.layerRoot.visible = v -- 303
	if not v then -- 303
		self.xiaoman3d:hide() -- 305
		self.cam.projection = nil -- 306
		self.texts:hideAll() -- 307
	end -- 307
end -- 302
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 312
	self:syncRuntimeHooks() -- 313
	self.boundPlay = p -- 314
	p.useEscortDeathSummary = true -- 315
	p:openTalentDraft() -- 316
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 317
	self.xiaoman3d:hide() -- 318
	self.cam.projection = nil -- 319
	self.cam:snap(p, w, h) -- 320
	self.adapter:reset(p) -- 321
	self.contract:resetForRoom(p) -- 322
	self.audio:stopRoomTransient() -- 323
	self.soundscape:resetForRoom(p) -- 324
	self.actors:reset(p) -- 325
	self.occlusion:reset() -- 326
	self.vfx:reset() -- 327
	self.hud:reset(p) -- 328
	self.narrative:onEnterRoom(p.room.key) -- 329
	local initView = self.contract:peekSnapshot(p) -- 331
	if #self.plugins > 0 then -- 331
		local i = 0 -- 333
		do -- 333
			i = 0 -- 334
			while i < #self.plugins do -- 334
				local pl = self.plugins[i + 1] -- 335
				if pl.onBindPlay ~= nil then -- 335
					pl:onBindPlay(p, initView) -- 337
				end -- 337
				i = i + 1 -- 334
			end -- 334
		end -- 334
	end -- 334
	self.roguelikeUi:onBindPlay(p, initView) -- 341
end -- 312
function WatchFrontend.prototype.clearAll(self) -- 344
	self.bgDraw:clear() -- 345
	self.escortTowerDraw:clear() -- 346
	self.bgGlow:clear() -- 347
	self.fgDraw:clear() -- 348
	self.fgGlow:clear() -- 349
	self.uiDraw:clear() -- 350
	self.uiInkDraw:clear() -- 351
	self.uiGlow:clear() -- 352
	self.uiMask:clear() -- 353
	self.backdropArt:beginFrame() -- 354
	self.dioramaBg:beginFrame() -- 355
	self.dioramaWorld:beginFrame() -- 356
	self.dioramaFg:beginFrame() -- 357
	self.worldArt:beginFrame() -- 358
	self.uiArt:beginFrame() -- 359
	self.texts:beginFrame() -- 360
end -- 344
function WatchFrontend.prototype.finishFrame(self) -- 363
	self.backdropArt:endFrame() -- 364
	self.dioramaBg:endFrame() -- 365
	self.dioramaWorld:endFrame() -- 366
	self.dioramaFg:endFrame() -- 367
	self.worldArt:endFrame() -- 368
	self.uiArt:endFrame() -- 369
	self.texts:endFrame() -- 370
end -- 363
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 374
	self.stageVp = vp -- 375
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 376
end -- 374
function WatchFrontend.prototype.showToast(self, text, duration) -- 380
	if duration == nil then -- 380
		duration = 1.8 -- 380
	end -- 380
	self.toastText = text -- 381
	self.toastTimer = duration -- 382
end -- 380
function WatchFrontend.prototype.getToastText(self) -- 385
	return self.toastTimer > 0 and self.toastText or "" -- 386
end -- 385
function WatchFrontend.prototype.drawToast(self, uiW) -- 389
	if self.toastTimer <= 0 or self.toastText == "" then -- 389
		return -- 391
	end -- 391
	local alpha = math.min(1, self.toastTimer * 2.4) -- 393
	local cx = uiW * 0.5 -- 394
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 395
	drawSilkVeil( -- 396
		self.uiDraw, -- 396
		self.uiArt, -- 396
		"fe_toast_veil", -- 396
		cx, -- 396
		cy, -- 396
		340, -- 396
		38, -- 396
		PALETTE.inkWarm, -- 396
		0.86 * alpha, -- 396
		9 -- 396
	) -- 396
	self.texts:put( -- 397
		"sm", -- 397
		self.toastText, -- 397
		cx, -- 397
		cy, -- 397
		toColor(PALETTE.amberCore), -- 397
		0.5, -- 397
		0.5, -- 397
		"Center", -- 397
		1.4, -- 397
		0.96 * alpha, -- 397
		0.08 -- 397
	) -- 397
end -- 389
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 400
	return not p.escortFailed and not p.paused and not p.craftBench.active and not p.reloadOpen and self.roguelikeUi:canPickTalent() -- 401
end -- 400
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 405
	local offers = p:getStoryTalentOffers() -- 406
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 406
		return {} -- 408
	end -- 408
	local uiScale = math.max( -- 410
		0.25, -- 410
		math.min(w / 1280, h / 720) -- 410
	) -- 410
	return self.hud:talentCardRects( -- 411
		w / uiScale, -- 411
		h / uiScale, -- 411
		#offers, -- 411
		touchMode, -- 411
		self.stageVp.safeUi.top -- 411
	) -- 411
end -- 405
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 415
	if not p.escortFailed then -- 415
		return nil -- 417
	end -- 417
	local uiScale = math.max( -- 419
		0.25, -- 419
		math.min(w / 1280, h / 720) -- 419
	) -- 419
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 420
end -- 415
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 424
	if not p.escortFailed then -- 424
		return "" -- 426
	end -- 426
	if input.inputMode == "gamepad" and not input.uiPressed then -- 426
		return "" -- 429
	end -- 429
	local useUiPtr = input.uiInside or input.uiPressed -- 431
	local ____useUiPtr_2 -- 432
	if useUiPtr then -- 432
		____useUiPtr_2 = input.uiInside -- 432
	else -- 432
		____useUiPtr_2 = input.inside -- 432
	end -- 432
	local inside = ____useUiPtr_2 -- 432
	if not inside then -- 432
		return "" -- 434
	end -- 434
	local uiScale = math.max( -- 436
		0.25, -- 436
		math.min(w / 1280, h / 720) -- 436
	) -- 436
	local rawX = useUiPtr and input.uiX or input.mx -- 437
	local rawY = useUiPtr and input.uiY or input.my -- 438
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 439
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 440
	if btns.retry:containsPoint(pointer) then -- 440
		self.roguelikeUi.deathSelected = 0 -- 442
		return "retry" -- 443
	end -- 443
	if btns.title:containsPoint(pointer) then -- 443
		self.roguelikeUi.deathSelected = 1 -- 446
		return "title" -- 447
	end -- 447
	return "" -- 449
end -- 424
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 452
	if kind == "hover" then -- 452
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 454
	elseif kind == "confirm" then -- 454
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 456
	elseif kind == "back" then -- 456
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 458
	elseif kind == "start" then -- 458
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 460
	elseif kind == "pauseOpen" then -- 460
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 462
	elseif kind == "pauseClose" then -- 462
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 464
	elseif kind == "toggle" then -- 464
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 466
	end -- 466
end -- 452
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 471
	self:syncRuntimeHooks() -- 472
	local safeDt = math.min( -- 473
		0.05, -- 473
		math.max(0, dt) -- 473
	) -- 473
	if self.toastTimer > 0 then -- 473
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 475
	end -- 475
	if self.screen == "title" and self.boundPlay ~= nil then -- 475
		self.audio:stopRoomTransient() -- 478
		self.boundPlay = nil -- 479
	end -- 479
	self.audio:update(safeDt) -- 481
	self.xiaoman3d:hide() -- 482
	self.cam.projection = nil -- 483
	self.soundscape:updateMenu(self.screen, self.audio) -- 484
	self:setVisible(true) -- 485
	self:clearAll() -- 486
	local uiScale = self:resizeInterface(w, h) -- 487
	local act = self.menus:updateAndDrawScreen( -- 488
		dt, -- 489
		self.screen, -- 490
		input, -- 491
		self.stage, -- 492
		self.bgDraw, -- 493
		self.bgGlow, -- 494
		self.backdropArt, -- 495
		self.uiArt, -- 496
		self.uiDraw, -- 497
		self.uiInkDraw, -- 498
		self.uiGlow, -- 499
		self.texts, -- 500
		w, -- 501
		h, -- 502
		uiScale, -- 503
		self.stageVp.safeUi -- 504
	) -- 504
	self:drawToast(w / uiScale) -- 506
	self:finishFrame() -- 507
	return act -- 508
end -- 471
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 512
	local offers = p:getStoryTalentOffers() -- 513
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 513
		return false -- 515
	end -- 515
	if input.inputMode == "gamepad" and not input.uiPressed then -- 515
		return false -- 518
	end -- 518
	local useUiPtr = input.uiInside or input.uiPressed -- 520
	local ____useUiPtr_3 -- 521
	if useUiPtr then -- 521
		____useUiPtr_3 = input.uiInside -- 521
	else -- 521
		____useUiPtr_3 = input.inside -- 521
	end -- 521
	local inside = ____useUiPtr_3 -- 521
	if not inside then -- 521
		return false -- 523
	end -- 523
	local uiScale = math.max( -- 525
		0.25, -- 525
		math.min(w / 1280, h / 720) -- 525
	) -- 525
	local uiW = w / uiScale -- 526
	local uiH = h / uiScale -- 527
	local rawX = useUiPtr and input.uiX or input.mx -- 528
	local rawY = useUiPtr and input.uiY or input.my -- 529
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 530
	local boxes = self.hud:talentCardRects( -- 531
		uiW, -- 531
		uiH, -- 531
		#offers, -- 531
		input:isTouchMode(), -- 531
		self.stageVp.safeUi.top -- 531
	) -- 531
	local i = 0 -- 532
	do -- 532
		i = 0 -- 533
		while i < #boxes do -- 533
			if boxes[i + 1]:containsPoint(pointer) then -- 533
				return p:chooseTalent(i) -- 535
			end -- 535
			i = i + 1 -- 533
		end -- 533
	end -- 533
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 539
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 540
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 541
end -- 512
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 546
	self:syncRuntimeHooks() -- 547
	self:setVisible(true) -- 548
	if self.boundPlay ~= p then -- 548
		self:bindPlay(p, w, h) -- 550
	end -- 550
	local safeDt = math.min( -- 552
		0.05, -- 552
		math.max(0.001, dt) -- 552
	) -- 552
	if self.toastTimer > 0 then -- 552
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 554
	end -- 554
	self.audio:setPaused(p.paused) -- 556
	self.audio:setCameraRef( -- 557
		self.cam.x, -- 557
		w / math.max(0.25, self.cam.ppu) -- 557
	) -- 557
	self.audio:update(safeDt) -- 558
	local ev -- 560
	local worldDt = 0 -- 561
	local uiDt = 0 -- 562
	if not p.paused then -- 562
		ev = self.adapter:sample(p) -- 566
		self.vfx:ingest(ev, p, self.cam) -- 567
		self.audio:ingestEvents(ev, p) -- 568
		if ev.playerHit then -- 568
			input:vibrate(0.036) -- 570
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 570
			input:vibrate(0.024) -- 572
		elseif ev.coverDeflect then -- 572
			input:vibrate(0.018) -- 574
		elseif ev.knockPulse then -- 574
			input:vibrate(0.014) -- 576
		end -- 576
	else -- 576
		ev = self.adapter:emptyFrame(p) -- 580
		self.narrative.wipeT = 0 -- 581
	end -- 581
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 584
	if not p.paused then -- 584
		local clampedScale = math.max( -- 586
			0, -- 586
			math.min(2, view.timeScale) -- 586
		) -- 586
		uiDt = safeDt -- 587
		worldDt = safeDt * clampedScale -- 588
	end -- 588
	local uiScale = self:resizeInterface(w, h) -- 591
	local uiW = w / uiScale -- 592
	local uiH = h / uiScale -- 593
	local ctx = { -- 595
		p = p, -- 596
		view = view, -- 597
		events = ev, -- 598
		input = input, -- 599
		cam = self.cam, -- 600
		audio = self.audio, -- 601
		assets = self.worldArt, -- 602
		backdropArt = self.backdropArt, -- 603
		worldArt = self.worldArt, -- 604
		uiArt = self.uiArt, -- 605
		uiMask = self.uiMask, -- 606
		dioramaBg = self.dioramaBg, -- 607
		dioramaWorld = self.dioramaWorld, -- 608
		dioramaFg = self.dioramaFg, -- 609
		texts = self.texts, -- 610
		worldDt = worldDt, -- 611
		uiDt = uiDt, -- 612
		w = w, -- 613
		h = h, -- 614
		uiW = uiW, -- 615
		uiH = uiH, -- 616
		uiScale = uiScale, -- 617
		safeUi = self.stageVp.safeUi, -- 618
		paused = p.paused -- 619
	} -- 619
	local i = 0 -- 623
	do -- 623
		i = 0 -- 624
		while i < #self.plugins do -- 624
			local pl = self.plugins[i + 1] -- 625
			if pl.update ~= nil then -- 625
				pl:update(ctx) -- 627
			end -- 627
			i = i + 1 -- 624
		end -- 624
	end -- 624
	self.roguelikeUi:update(ctx) -- 630
	if not p.paused then -- 630
		self.time = self.time + worldDt -- 633
		self.cam:update(worldDt, p, w, h) -- 634
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 635
		self.audio:setCameraRef( -- 636
			self.cam.x, -- 636
			w / math.max(0.25, self.cam.ppu) -- 636
		) -- 636
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 637
		self.actors:update(worldDt, p) -- 638
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
	local use3D = self.xiaoman3d:supports(p, view.visualMode) -- 648
	if use3D then -- 648
		self.xiaoman3d:render( -- 650
			p, -- 650
			self.cam, -- 650
			self.actors, -- 650
			worldDt, -- 650
			w, -- 650
			h, -- 650
			self.stageVp -- 650
		) -- 650
	else -- 650
		self.xiaoman3d:hide() -- 652
		self.cam.projection = nil -- 653
		local backdropHandled = false -- 656
		do -- 656
			i = 0 -- 657
			while i < #self.plugins do -- 657
				local pl = self.plugins[i + 1] -- 658
				if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 658
					backdropHandled = true -- 660
				end -- 660
				i = i + 1 -- 657
			end -- 657
		end -- 657
		if not backdropHandled then -- 657
			self.stage:drawBackdrop( -- 664
				self.bgDraw, -- 664
				self.bgGlow, -- 664
				self.backdropArt, -- 664
				p, -- 664
				self.cam, -- 664
				self.time -- 664
			) -- 664
		end -- 664
		if view.visualMode == "pixel" then -- 664
			self.escortWorld:drawBackdropOverlay( -- 667
				self.bgDraw, -- 667
				self.bgGlow, -- 667
				self.backdropArt, -- 667
				p, -- 667
				self.cam, -- 667
				self.time, -- 667
				self.escortTowerDraw -- 667
			) -- 667
		end -- 667
		local worldHandled = false -- 671
		do -- 671
			i = 0 -- 672
			while i < #self.plugins do -- 672
				local pl = self.plugins[i + 1] -- 673
				if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 673
					worldHandled = true -- 675
				end -- 675
				i = i + 1 -- 672
			end -- 672
		end -- 672
		if not worldHandled then -- 672
			self.stage:drawPlayableWorld( -- 679
				self.fgDraw, -- 679
				self.fgGlow, -- 679
				self.worldArt, -- 679
				p, -- 679
				self.cam, -- 679
				self.time, -- 679
				self.occlusion, -- 679
				worldDt -- 679
			) -- 679
		end -- 679
		local propsHandled = false -- 683
		do -- 683
			i = 0 -- 684
			while i < #self.plugins do -- 684
				local pl = self.plugins[i + 1] -- 685
				if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 685
					propsHandled = true -- 687
				end -- 687
				i = i + 1 -- 684
			end -- 684
		end -- 684
		if not propsHandled then -- 684
			self.props:drawAll( -- 691
				self.fgDraw, -- 691
				self.fgGlow, -- 691
				self.worldArt, -- 691
				p, -- 691
				self.cam, -- 691
				self.time, -- 691
				self.occlusion, -- 691
				worldDt -- 691
			) -- 691
		end -- 691
		if view.visualMode == "pixel" then -- 691
			self.escortWorld:drawWorldSetpieces( -- 694
				self.fgDraw, -- 694
				self.fgGlow, -- 694
				self.worldArt, -- 694
				p, -- 694
				view, -- 694
				self.cam, -- 694
				self.time -- 694
			) -- 694
		end -- 694
		if view.visualMode ~= "museum" then -- 694
			local pose -- 699
			for ____, pl in ipairs(self.plugins) do -- 700
				if pl.drawPartyPose ~= nil then -- 700
					pose = pl:drawPartyPose(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 702
					if pose ~= nil then -- 702
						break -- 703
					end -- 703
				end -- 703
			end -- 703
			self.actors:drawAll( -- 706
				self.fgDraw, -- 706
				self.fgGlow, -- 706
				self.worldArt, -- 706
				p, -- 706
				self.cam, -- 706
				pose -- 706
			) -- 706
		end -- 706
		do -- 706
			i = 0 -- 708
			while i < #self.plugins do -- 708
				local pl = self.plugins[i + 1] -- 709
				if pl.drawActorsOverlay ~= nil then -- 709
					pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 711
				end -- 711
				i = i + 1 -- 708
			end -- 708
		end -- 708
		self.roguelikeUi:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 714
		self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 717
		if view.visualMode == "pixel" then -- 717
			self.stage:drawForegroundFraming( -- 721
				self.fgDraw, -- 721
				w, -- 721
				h, -- 721
				p, -- 721
				self.cam -- 721
			) -- 721
			self.escortWorld:drawForegroundFraming( -- 722
				self.fgDraw, -- 722
				self.fgGlow, -- 722
				self.worldArt, -- 722
				p, -- 722
				self.cam, -- 722
				self.time -- 722
			) -- 722
		end -- 722
	end -- 722
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 725
	local action = {type = "none"} -- 728
	if p.paused then -- 728
		action = self.menus:updateAndDrawPause( -- 730
			safeDt, -- 731
			input, -- 732
			self.uiDraw, -- 733
			self.uiInkDraw, -- 734
			self.uiArt, -- 735
			self.uiGlow, -- 736
			self.texts, -- 737
			uiW, -- 738
			uiH, -- 739
			uiScale, -- 740
			view.assistHintsEnabled, -- 741
			function() -- 742
				self.contract:toggleAssistHints() -- 743
			end, -- 742
			self.stageVp.safeUi, -- 745
			p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom(), -- 746
			view.roguelike.active, -- 747
			function() -- 748
				self.roguelikeUi:openLedger() -- 749
			end -- 748
		) -- 748
	else -- 748
		local cutsceneHandled = false -- 754
		do -- 754
			i = 0 -- 755
			while i < #self.plugins do -- 755
				local pl = self.plugins[i + 1] -- 756
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 756
					self.uiDraw, -- 758
					self.uiInkDraw, -- 758
					self.uiArt, -- 758
					self.uiGlow, -- 758
					ctx -- 758
				) then -- 758
					cutsceneHandled = true -- 759
				end -- 759
				i = i + 1 -- 755
			end -- 755
		end -- 755
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 763
		if not cutsceneHandled and not roguelikeModal then -- 763
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 765
			self.hud:draw( -- 766
				self.uiDraw, -- 767
				self.uiInkDraw, -- 768
				self.uiArt, -- 769
				self.uiGlow, -- 770
				self.texts, -- 771
				p, -- 772
				self.cam, -- 773
				self.vfx, -- 774
				self.narrative.letterbox, -- 775
				uiScale, -- 776
				view.assistHintsEnabled, -- 777
				true, -- 778
				input.inputMode, -- 779
				input.gamepadLayout, -- 780
				self.stageVp.safeUi, -- 781
				input.retryHoldProgress, -- 782
				touchOverlayVisible -- 783
			) -- 783
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 785
			local savedBannerT = self.narrative.bannerT -- 786
			if suppressBanner then -- 786
				self.narrative.bannerT = 0 -- 788
			end -- 788
			self.narrative:draw( -- 790
				self.uiDraw, -- 791
				self.uiInkDraw, -- 792
				self.uiGlow, -- 793
				self.uiArt, -- 794
				self.texts, -- 795
				p, -- 796
				uiW, -- 797
				uiH, -- 798
				view.assistHintsEnabled, -- 799
				input.inputMode, -- 800
				input.gamepadLayout, -- 801
				self.stageVp.safeUi -- 802
			) -- 802
			if suppressBanner then -- 802
				self.narrative.bannerT = savedBannerT -- 805
			end -- 805
		elseif cutsceneHandled then -- 805
			self.narrative:drawCutsceneDialogue( -- 809
				self.uiDraw, -- 810
				self.uiInkDraw, -- 811
				self.uiArt, -- 812
				self.texts, -- 813
				p, -- 814
				uiW, -- 815
				uiH, -- 816
				self.stageVp.safeUi -- 817
			) -- 817
		end -- 817
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 821
		do -- 821
			i = 0 -- 822
			while i < #self.plugins do -- 822
				local pl = self.plugins[i + 1] -- 823
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 823
					self.uiDraw, -- 825
					self.uiInkDraw, -- 825
					self.uiArt, -- 825
					self.uiGlow, -- 825
					ctx -- 825
				) then -- 825
					suppressReticle = true -- 826
				end -- 826
				i = i + 1 -- 822
			end -- 822
		end -- 822
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 822
			self.uiDraw, -- 830
			self.uiInkDraw, -- 830
			self.uiArt, -- 830
			self.uiGlow, -- 830
			ctx -- 830
		) then -- 830
			suppressReticle = true -- 831
		end -- 831
		if not suppressReticle then -- 831
			self.hud:drawReticleOverlay( -- 834
				self.uiInkDraw, -- 835
				self.uiArt, -- 836
				self.uiGlow, -- 837
				p, -- 838
				self.cam, -- 839
				self.vfx, -- 840
				self.narrative.letterbox, -- 841
				uiScale, -- 842
				input:isTouchMode() -- 843
			) -- 843
		end -- 843
		if view.isRehearsal then -- 843
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 849
			drawSilkVeil( -- 850
				self.uiDraw, -- 850
				self.uiArt, -- 850
				"rehearsal_tag_veil", -- 850
				uiW * 0.5, -- 850
				uiH - 22 - self.stageVp.safeUi.top, -- 850
				168, -- 850
				26, -- 850
				PALETTE.inkWarm, -- 850
				0.74, -- 850
				8 -- 850
			) -- 850
			self.texts:put( -- 851
				"xs", -- 851
				badgeText, -- 851
				uiW * 0.5, -- 851
				uiH - 22 - self.stageVp.safeUi.top, -- 851
				toColor(PALETTE.amberCore), -- 851
				0.5, -- 851
				0.5, -- 851
				"Center", -- 851
				1.2, -- 851
				0.92, -- 851
				0.08 -- 851
			) -- 851
		end -- 851
	end -- 851
	self:drawToast(uiW) -- 855
	self:finishFrame() -- 856
	return action -- 857
end -- 546
return ____exports -- 546