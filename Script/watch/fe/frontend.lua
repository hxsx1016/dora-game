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
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 40
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 40
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 41
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 41
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 42
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 42
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 43
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 43
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 44
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 44
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 45
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 45
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 46
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 46
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 47
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 47
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 48
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 48
local ____roguelike_ui = require("Script.watch.fe.ui.roguelike_ui") -- 49
local computeEscortDeathButtons = ____roguelike_ui.computeEscortDeathButtons -- 49
local RoguelikeUiPlugin = ____roguelike_ui.RoguelikeUiPlugin -- 49
____exports.WatchFrontend = __TS__Class() -- 51
local WatchFrontend = ____exports.WatchFrontend -- 51
WatchFrontend.name = "WatchFrontend" -- 51
function WatchFrontend.prototype.____constructor(self, parent) -- 100
	self.occlusion = __TS__New(DepthOcclusion) -- 52
	self.cam = __TS__New(CameraDirector) -- 75
	self.adapter = __TS__New(PlayAdapter) -- 76
	self.contract = __TS__New( -- 77
		DualRouteContract, -- 77
		function(p) return self:canPickStoryTalent(p) end -- 77
	) -- 77
	self.audio = __TS__New(AudioDirector) -- 78
	self.soundscape = __TS__New(SoundscapeDirector) -- 79
	self.stage = __TS__New(StageRenderer) -- 80
	self.escortWorld = __TS__New(EscortWorldRenderer) -- 81
	self.props = __TS__New(PropsRenderer) -- 82
	self.actors = __TS__New(ActorsRenderer) -- 83
	self.sceneFx = __TS__New(SceneFxSystem) -- 84
	self.vfx = __TS__New(VfxSystem) -- 85
	self.hud = __TS__New(HudRenderer) -- 86
	self.narrative = __TS__New(NarrativeRenderer) -- 87
	self.menus = __TS__New(MenuRenderer) -- 88
	self.plugins = {} -- 91
	self.screen = "title" -- 93
	self.time = 0 -- 94
	self.stageVp = computeStageViewport(1280, 720) -- 96
	self.toastText = "" -- 97
	self.toastTimer = 0 -- 98
	self.layerRoot = Node() -- 101
	self.layerRoot.order = 5 -- 102
	self.layerRoot:addTo(parent) -- 103
	ensureSecondHalfAssetsRegistered() -- 104
	ensureDarkPixelAssetsRegistered() -- 105
	self.audio:attachHost(self.layerRoot) -- 107
	self.menus.onUiSound = function(____, kind) -- 108
		self:playMenuUiSound(kind) -- 109
	end -- 108
	self.menus.onAudioSettingsChanged = function(____, inp) -- 111
		self.audio:applyUserVolumes(inp.settings) -- 112
	end -- 111
	local additive = BlendFunc("SrcAlpha", "One") -- 115
	self.bgDraw = DrawNode() -- 117
	self.bgDraw.order = 10 -- 118
	self.bgDraw:addTo(self.layerRoot) -- 119
	self.escortTowerDraw = DrawNode() -- 122
	self.escortTowerDraw.order = 13 -- 123
	self.escortTowerDraw:addTo(self.layerRoot) -- 124
	self.bgGlow = DrawNode() -- 126
	self.bgGlow.order = 15 -- 127
	self.bgGlow.blendFunc = additive -- 128
	self.bgGlow:addTo(self.layerRoot) -- 129
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 131
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 132
	self.groundDraw = DrawNode() -- 134
	self.groundDraw.order = 20 -- 135
	self.groundDraw:addTo(self.layerRoot) -- 136
	self.groundArt = __TS__New(AssetSlotHost, self.layerRoot, 22) -- 137
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 138
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 139
	self.worldOverlayDraw = DrawNode() -- 140
	self.worldOverlayDraw.order = 33 -- 141
	self.worldOverlayDraw:addTo(self.layerRoot) -- 142
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 143
	self.fgDraw = DrawNode() -- 145
	self.fgDraw.order = 30 -- 146
	self.fgDraw:addTo(self.layerRoot) -- 147
	self.fgGlow = DrawNode() -- 149
	self.fgGlow.order = 35 -- 150
	self.fgGlow.blendFunc = additive -- 151
	self.fgGlow:addTo(self.layerRoot) -- 152
	self.uiLayer = Node() -- 154
	self.uiLayer.order = 40 -- 155
	self.uiLayer:addTo(self.layerRoot) -- 156
	self.uiDraw = DrawNode() -- 158
	self.uiDraw.order = 0 -- 159
	self.uiDraw:addTo(self.uiLayer) -- 160
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 162
	self.uiInkDraw = DrawNode() -- 164
	self.uiInkDraw.order = 4 -- 165
	self.uiInkDraw:addTo(self.uiLayer) -- 166
	self.uiGlow = DrawNode() -- 168
	self.uiGlow.order = 6 -- 169
	self.uiGlow.blendFunc = additive -- 170
	self.uiGlow:addTo(self.uiLayer) -- 171
	self.uiMask = DrawNode() -- 173
	self.uiMask.order = 8 -- 174
	self.uiMask:addTo(self.uiLayer) -- 175
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 177
	self.roguelikeUi = __TS__New( -- 181
		RoguelikeUiPlugin, -- 181
		self.contract, -- 182
		function() return self.hud.talentSelected end, -- 183
		function(idx) -- 184
			self.hud.talentSelected = idx -- 185
		end -- 184
	) -- 184
	self.hud.roguelikeUiHandled = true -- 188
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) return self.roguelikeUi:getTalentCardRects( -- 189
		w, -- 190
		h, -- 190
		count, -- 190
		touchMode, -- 190
		safeTop -- 190
	) end -- 189
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 204
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 205
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 206
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 207
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 208
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 209
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 210
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 211
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 212
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 213
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 214
end -- 100
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 218
	local i = 0 -- 219
	do -- 219
		i = 0 -- 220
		while i < #self.plugins do -- 220
			if self.plugins[i + 1].id == plugin.id then -- 221
				self.plugins[i + 1] = plugin -- 222
				self:syncRuntimeHooks() -- 223
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 224
					plugin:onBindPlay( -- 225
						self.boundPlay, -- 225
						self.contract:peekSnapshot(self.boundPlay) -- 225
					) -- 225
				end -- 225
				return -- 227
			end -- 227
			i = i + 1 -- 220
		end -- 220
	end -- 220
	local ____self_plugins_0 = self.plugins -- 230
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 230
	self:syncRuntimeHooks() -- 231
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 232
		plugin:onBindPlay( -- 233
			self.boundPlay, -- 233
			self.contract:peekSnapshot(self.boundPlay) -- 233
		) -- 233
	end -- 233
end -- 218
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 238
	local w = 0 -- 239
	local i = 0 -- 240
	do -- 240
		i = 0 -- 241
		while i < #self.plugins do -- 241
			if self.plugins[i + 1].id ~= id then -- 242
				self.plugins[w + 1] = self.plugins[i + 1] -- 243
				w = w + 1 -- 244
			end -- 244
			i = i + 1 -- 241
		end -- 241
	end -- 241
	__TS__ArraySetLength(self.plugins, w) -- 247
	self:syncRuntimeHooks() -- 248
end -- 238
function WatchFrontend.prototype.getPlugin(self, id) -- 252
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 253
		return self.roguelikeUi -- 254
	end -- 254
	local i = 0 -- 256
	do -- 256
		i = 0 -- 257
		while i < #self.plugins do -- 257
			if self.plugins[i + 1].id == id then -- 258
				return self.plugins[i + 1] -- 259
			end -- 259
			i = i + 1 -- 257
		end -- 257
	end -- 257
	return nil -- 262
end -- 252
function WatchFrontend.prototype.getPlugins(self) -- 265
	return self.plugins -- 266
end -- 265
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 274
	local g = _G -- 275
	local ____temp_1 -- 276
	if g.package ~= nil then -- 276
		____temp_1 = g.package.loaded -- 276
	else -- 276
		____temp_1 = nil -- 276
	end -- 276
	local loaded = ____temp_1 -- 276
	if loaded == nil then -- 277
		return -- 278
	end -- 278
	local rawFe = loaded["watch.fe"] -- 280
	if rawFe ~= nil and type(rawFe) == "table" then -- 281
		local watchFe = rawFe -- 282
		if watchFe.contract ~= self.contract then -- 283
			watchFe.contract = self.contract -- 284
			watchFe.audio = self.audio -- 285
			watchFe.soundscape = self.soundscape -- 286
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 287
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 288
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 289
		end -- 289
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 291
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 292
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 293
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 294
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 295
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 296
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 297
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 298
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 299
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 300
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 301
		watchFe.roguelikeUi = self.roguelikeUi -- 302
	end -- 302
end -- 274
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 306
	local scale = math.max( -- 307
		0.25, -- 307
		math.min(w / 1280, h / 720) -- 307
	) -- 307
	self.uiLayer.scaleX = scale -- 308
	self.uiLayer.scaleY = scale -- 309
	return scale -- 310
end -- 306
function WatchFrontend.prototype.setVisible(self, v) -- 314
	self.layerRoot.visible = v -- 315
	if not v then -- 316
		self.texts:hideAll() -- 317
	end -- 317
end -- 314
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 322
	self:syncRuntimeHooks() -- 323
	self.boundPlay = p -- 324
	p.useEscortDeathSummary = true -- 325
	p:openTalentDraft() -- 326
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 327
	self.cam:snap(p, w, h) -- 328
	self.adapter:reset(p) -- 329
	self.contract:resetForRoom(p) -- 330
	self.audio:stopRoomTransient() -- 331
	self.soundscape:resetForRoom(p) -- 332
	self.actors:reset(p) -- 333
	self.sceneFx:reset(p.room.key) -- 334
	self.occlusion:reset() -- 335
	self.vfx:reset() -- 336
	self.hud:reset(p) -- 337
	self.narrative:onEnterRoom(p.room.key) -- 338
	local initView = self.contract:peekSnapshot(p) -- 340
	if #self.plugins > 0 then -- 341
		local i = 0 -- 342
		do -- 342
			i = 0 -- 343
			while i < #self.plugins do -- 343
				local pl = self.plugins[i + 1] -- 344
				if pl.onBindPlay ~= nil then -- 345
					pl:onBindPlay(p, initView) -- 346
				end -- 346
				i = i + 1 -- 343
			end -- 343
		end -- 343
	end -- 343
	self.roguelikeUi:onBindPlay(p, initView) -- 350
end -- 322
function WatchFrontend.prototype.clearAll(self) -- 353
	self.bgDraw:clear() -- 354
	self.escortTowerDraw:clear() -- 355
	self.bgGlow:clear() -- 356
	self.groundDraw:clear() -- 357
	self.fgDraw:clear() -- 358
	self.worldOverlayDraw:clear() -- 359
	self.fgGlow:clear() -- 360
	self.uiDraw:clear() -- 361
	self.uiInkDraw:clear() -- 362
	self.uiGlow:clear() -- 363
	self.uiMask:clear() -- 364
	self.backdropArt:beginFrame() -- 365
	self.groundArt:beginFrame() -- 366
	self.dioramaBg:beginFrame() -- 367
	self.dioramaWorld:beginFrame() -- 368
	self.dioramaFg:beginFrame() -- 369
	self.worldArt:beginFrame() -- 370
	self.uiArt:beginFrame() -- 371
	self.texts:beginFrame() -- 372
end -- 353
function WatchFrontend.prototype.finishFrame(self) -- 375
	self.backdropArt:endFrame() -- 376
	self.groundArt:endFrame() -- 377
	self.dioramaBg:endFrame() -- 378
	self.dioramaWorld:endFrame() -- 379
	self.dioramaFg:endFrame() -- 380
	self.worldArt:endFrame() -- 381
	self.uiArt:endFrame() -- 382
	self.texts:endFrame() -- 383
end -- 375
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 387
	self.stageVp = vp -- 388
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 389
end -- 387
function WatchFrontend.prototype.showToast(self, text, duration) -- 393
	if duration == nil then -- 393
		duration = 1.8 -- 393
	end -- 393
	self.toastText = text -- 394
	self.toastTimer = duration -- 395
end -- 393
function WatchFrontend.prototype.getToastText(self) -- 398
	return self.toastTimer > 0 and self.toastText or "" -- 399
end -- 398
function WatchFrontend.prototype.drawToast(self, uiW) -- 402
	if self.toastTimer <= 0 or self.toastText == "" then -- 403
		return -- 404
	end -- 404
	local alpha = math.min(1, self.toastTimer * 2.4) -- 406
	local cx = uiW * 0.5 -- 407
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 408
	drawSilkVeil( -- 409
		self.uiDraw, -- 409
		self.uiArt, -- 409
		"fe_toast_veil", -- 409
		cx, -- 409
		cy, -- 409
		340, -- 409
		38, -- 409
		PALETTE.inkWarm, -- 409
		0.86 * alpha, -- 409
		9 -- 409
	) -- 409
	self.texts:put( -- 410
		"sm", -- 410
		self.toastText, -- 410
		cx, -- 410
		cy, -- 410
		toColor(PALETTE.amberCore), -- 410
		0.5, -- 410
		0.5, -- 410
		"Center", -- 410
		1.4, -- 410
		0.96 * alpha, -- 410
		0.08 -- 410
	) -- 410
end -- 402
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 413
	return not p.escortFailed and not p.paused and not p.craftBench.active and not p.reloadOpen and self.roguelikeUi:canPickTalent() -- 414
end -- 413
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 418
	local offers = p:getStoryTalentOffers() -- 419
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 420
		return {} -- 421
	end -- 421
	local uiScale = math.max( -- 423
		0.25, -- 423
		math.min(w / 1280, h / 720) -- 423
	) -- 423
	return self.hud:talentCardRects( -- 424
		w / uiScale, -- 424
		h / uiScale, -- 424
		#offers, -- 424
		touchMode, -- 424
		self.stageVp.safeUi.top -- 424
	) -- 424
end -- 418
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 428
	if not p.escortFailed then -- 429
		return nil -- 430
	end -- 430
	local uiScale = math.max( -- 432
		0.25, -- 432
		math.min(w / 1280, h / 720) -- 432
	) -- 432
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 433
end -- 428
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 437
	if not p.escortFailed then -- 438
		return "" -- 439
	end -- 439
	if input.inputMode == "gamepad" and not input.uiPressed then -- 441
		return "" -- 442
	end -- 442
	local useUiPtr = input.uiInside or input.uiPressed -- 444
	local ____useUiPtr_2 -- 445
	if useUiPtr then -- 445
		____useUiPtr_2 = input.uiInside -- 445
	else -- 445
		____useUiPtr_2 = input.inside -- 445
	end -- 445
	local inside = ____useUiPtr_2 -- 445
	if not inside then -- 446
		return "" -- 447
	end -- 447
	local uiScale = math.max( -- 449
		0.25, -- 449
		math.min(w / 1280, h / 720) -- 449
	) -- 449
	local rawX = useUiPtr and input.uiX or input.mx -- 450
	local rawY = useUiPtr and input.uiY or input.my -- 451
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 452
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 453
	if btns.retry:containsPoint(pointer) then -- 454
		self.roguelikeUi.deathSelected = 0 -- 455
		return "retry" -- 456
	end -- 456
	if btns.title:containsPoint(pointer) then -- 458
		self.roguelikeUi.deathSelected = 1 -- 459
		return "title" -- 460
	end -- 460
	return "" -- 462
end -- 437
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 465
	if kind == "hover" then -- 466
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 467
	elseif kind == "confirm" then -- 468
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 469
	elseif kind == "back" then -- 470
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 471
	elseif kind == "start" then -- 472
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 473
	elseif kind == "pauseOpen" then -- 474
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 475
	elseif kind == "pauseClose" then -- 476
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 477
	elseif kind == "toggle" then -- 478
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 479
	end -- 479
end -- 465
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 484
	self:syncRuntimeHooks() -- 485
	local safeDt = math.min( -- 486
		0.05, -- 486
		math.max(0, dt) -- 486
	) -- 486
	self.time = self.time + safeDt -- 487
	if self.toastTimer > 0 then -- 488
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 489
	end -- 489
	if self.screen == "title" and self.boundPlay ~= nil then -- 491
		self.audio:stopRoomTransient() -- 492
		self.boundPlay = nil -- 493
	end -- 493
	self.audio:update(safeDt) -- 495
	self.soundscape:updateMenu(self.screen, self.audio) -- 496
	self:setVisible(true) -- 497
	self:clearAll() -- 498
	local uiScale = self:resizeInterface(w, h) -- 499
	local act = self.menus:updateAndDrawScreen( -- 500
		dt, -- 501
		self.screen, -- 502
		input, -- 503
		self.stage, -- 504
		self.bgDraw, -- 505
		self.bgGlow, -- 506
		self.backdropArt, -- 507
		self.uiArt, -- 508
		self.uiDraw, -- 509
		self.uiInkDraw, -- 510
		self.uiGlow, -- 511
		self.texts, -- 512
		w, -- 513
		h, -- 514
		uiScale, -- 515
		self.stageVp.safeUi -- 516
	) -- 516
	if self.screen == "title" then -- 518
		self.sceneFx:drawTitleAtmosphere( -- 519
			self.bgGlow, -- 519
			self.fgGlow, -- 519
			self.backdropArt, -- 519
			self.worldArt, -- 519
			w, -- 519
			h, -- 519
			self.time -- 519
		) -- 519
	end -- 519
	self:drawToast(w / uiScale) -- 521
	self:finishFrame() -- 522
	return act -- 523
end -- 484
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 527
	local offers = p:getStoryTalentOffers() -- 528
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 529
		return false -- 530
	end -- 530
	if input.inputMode == "gamepad" and not input.uiPressed then -- 532
		return false -- 533
	end -- 533
	local useUiPtr = input.uiInside or input.uiPressed -- 535
	local ____useUiPtr_3 -- 536
	if useUiPtr then -- 536
		____useUiPtr_3 = input.uiInside -- 536
	else -- 536
		____useUiPtr_3 = input.inside -- 536
	end -- 536
	local inside = ____useUiPtr_3 -- 536
	if not inside then -- 537
		return false -- 538
	end -- 538
	local uiScale = math.max( -- 540
		0.25, -- 540
		math.min(w / 1280, h / 720) -- 540
	) -- 540
	local uiW = w / uiScale -- 541
	local uiH = h / uiScale -- 542
	local rawX = useUiPtr and input.uiX or input.mx -- 543
	local rawY = useUiPtr and input.uiY or input.my -- 544
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 545
	local boxes = self.hud:talentCardRects( -- 546
		uiW, -- 546
		uiH, -- 546
		#offers, -- 546
		input:isTouchMode(), -- 546
		self.stageVp.safeUi.top -- 546
	) -- 546
	local i = 0 -- 547
	do -- 547
		i = 0 -- 548
		while i < #boxes do -- 548
			if boxes[i + 1]:containsPoint(pointer) then -- 549
				return p:chooseTalent(i) -- 550
			end -- 550
			i = i + 1 -- 548
		end -- 548
	end -- 548
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 554
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 555
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 556
end -- 527
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 561
	self:syncRuntimeHooks() -- 562
	self:setVisible(true) -- 563
	if self.boundPlay ~= p then -- 564
		self:bindPlay(p, w, h) -- 565
	end -- 565
	local safeDt = math.min( -- 567
		0.05, -- 567
		math.max(0.001, dt) -- 567
	) -- 567
	if self.toastTimer > 0 then -- 568
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 569
	end -- 569
	self.audio:setPaused(p.paused) -- 571
	self.audio:setCameraRef( -- 572
		self.cam.x, -- 572
		w / math.max(0.25, self.cam.ppu) -- 572
	) -- 572
	self.audio:update(safeDt) -- 573
	local ev -- 575
	local worldDt = 0 -- 576
	local uiDt = 0 -- 577
	if not p.paused then -- 579
		ev = self.adapter:sample(p) -- 581
		self.vfx:ingest(ev, p, self.cam) -- 582
		self.audio:ingestEvents(ev, p) -- 583
		if ev.playerHit then -- 584
			input:vibrate(0.036) -- 585
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 586
			input:vibrate(0.024) -- 587
		elseif ev.coverDeflect then -- 588
			input:vibrate(0.018) -- 589
		elseif ev.knockPulse then -- 590
			input:vibrate(0.014) -- 591
		end -- 591
	else -- 591
		ev = self.adapter:emptyFrame(p) -- 595
		self.narrative.wipeT = 0 -- 596
	end -- 596
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 599
	if not p.paused then -- 600
		local clampedScale = math.max( -- 601
			0, -- 601
			math.min(2, view.timeScale) -- 601
		) -- 601
		uiDt = safeDt -- 602
		worldDt = safeDt * clampedScale -- 603
	end -- 603
	local uiScale = self:resizeInterface(w, h) -- 606
	local uiW = w / uiScale -- 607
	local uiH = h / uiScale -- 608
	local ctx = { -- 610
		p = p, -- 611
		view = view, -- 612
		events = ev, -- 613
		input = input, -- 614
		cam = self.cam, -- 615
		audio = self.audio, -- 616
		assets = self.worldArt, -- 617
		backdropArt = self.backdropArt, -- 618
		worldArt = self.worldArt, -- 619
		uiArt = self.uiArt, -- 620
		uiMask = self.uiMask, -- 621
		dioramaBg = self.dioramaBg, -- 622
		dioramaWorld = self.dioramaWorld, -- 623
		dioramaFg = self.dioramaFg, -- 624
		texts = self.texts, -- 625
		worldDt = worldDt, -- 626
		uiDt = uiDt, -- 627
		w = w, -- 628
		h = h, -- 629
		uiW = uiW, -- 630
		uiH = uiH, -- 631
		uiScale = uiScale, -- 632
		safeUi = self.stageVp.safeUi, -- 633
		paused = p.paused -- 634
	} -- 634
	local i = 0 -- 638
	do -- 638
		i = 0 -- 639
		while i < #self.plugins do -- 639
			local pl = self.plugins[i + 1] -- 640
			if pl.update ~= nil then -- 641
				pl:update(ctx) -- 642
			end -- 642
			i = i + 1 -- 639
		end -- 639
	end -- 639
	self.roguelikeUi:update(ctx) -- 645
	if not p.paused then -- 647
		self.time = self.time + worldDt -- 648
		self.cam:update(worldDt, p, w, h) -- 649
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 650
		self.audio:setCameraRef( -- 651
			self.cam.x, -- 651
			w / math.max(0.25, self.cam.ppu) -- 651
		) -- 651
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 652
		self.actors:update(worldDt, p) -- 653
		self.vfx:ingestFootsteps(self.actors:drainFootsteps()) -- 654
		self.sceneFx:update(worldDt, p, self.cam) -- 655
		self.vfx:update( -- 656
			worldDt, -- 656
			themeOf(p.room.key).ambient -- 656
		) -- 656
		self.hud:update(safeDt, p) -- 657
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 658
	else -- 658
		self.cam:update(0, p, w, h) -- 660
	end -- 660
	self:clearAll() -- 663
	local backdropHandled = false -- 666
	do -- 666
		i = 0 -- 667
		while i < #self.plugins do -- 667
			local pl = self.plugins[i + 1] -- 668
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 669
				backdropHandled = true -- 670
			end -- 670
			i = i + 1 -- 667
		end -- 667
	end -- 667
	if not backdropHandled then -- 673
		self.stage:drawBackdrop( -- 674
			self.bgDraw, -- 674
			self.bgGlow, -- 674
			self.backdropArt, -- 674
			p, -- 674
			self.cam, -- 674
			self.time -- 674
		) -- 674
	end -- 674
	if view.visualMode == "pixel" then -- 676
		self.escortWorld:drawBackdropOverlay( -- 677
			self.bgDraw, -- 677
			self.bgGlow, -- 677
			self.backdropArt, -- 677
			p, -- 677
			self.cam, -- 677
			self.time, -- 677
			self.escortTowerDraw -- 677
		) -- 677
		self.sceneFx:drawBackdropFx( -- 678
			self.bgDraw, -- 678
			self.bgGlow, -- 678
			self.backdropArt, -- 678
			p, -- 678
			self.cam -- 678
		) -- 678
	end -- 678
	local worldHandled = false -- 682
	do -- 682
		i = 0 -- 683
		while i < #self.plugins do -- 683
			local pl = self.plugins[i + 1] -- 684
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 685
				worldHandled = true -- 686
			end -- 686
			i = i + 1 -- 683
		end -- 683
	end -- 683
	if not worldHandled then -- 689
		self.stage:drawPlayableWorld( -- 690
			self.groundDraw, -- 691
			self.fgGlow, -- 692
			self.worldArt, -- 693
			p, -- 694
			self.cam, -- 695
			self.time, -- 696
			self.occlusion, -- 697
			worldDt, -- 698
			self.groundArt, -- 699
			self.fgDraw, -- 700
			self.worldOverlayDraw -- 701
		) -- 701
	end -- 701
	local propsHandled = false -- 706
	do -- 706
		i = 0 -- 707
		while i < #self.plugins do -- 707
			local pl = self.plugins[i + 1] -- 708
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 709
				propsHandled = true -- 710
			end -- 710
			i = i + 1 -- 707
		end -- 707
	end -- 707
	if not propsHandled then -- 713
		self.props:drawAll( -- 714
			self.fgDraw, -- 714
			self.fgGlow, -- 714
			self.worldArt, -- 714
			p, -- 714
			self.cam, -- 714
			self.time, -- 714
			self.occlusion, -- 714
			worldDt, -- 714
			self.groundArt -- 714
		) -- 714
	end -- 714
	if view.visualMode == "pixel" then -- 716
		self.escortWorld:drawWorldSetpieces( -- 717
			self.fgDraw, -- 717
			self.fgGlow, -- 717
			self.worldArt, -- 717
			p, -- 717
			view, -- 717
			self.cam, -- 717
			self.time -- 717
		) -- 717
		self.sceneFx:drawWorldFx( -- 718
			self.fgDraw, -- 718
			self.fgGlow, -- 718
			self.worldArt, -- 718
			p, -- 718
			self.cam -- 718
		) -- 718
	end -- 718
	if view.visualMode ~= "museum" then -- 722
		local pose -- 723
		for ____, pl in ipairs(self.plugins) do -- 724
			if pl.drawPartyPose ~= nil then -- 725
				pose = pl:drawPartyPose(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 726
				if pose ~= nil then -- 727
					break -- 727
				end -- 727
			end -- 727
		end -- 727
		self.actors:drawAll( -- 730
			self.worldOverlayDraw, -- 730
			self.fgGlow, -- 730
			self.worldArt, -- 730
			p, -- 730
			self.cam, -- 730
			pose -- 730
		) -- 730
	end -- 730
	do -- 730
		i = 0 -- 732
		while i < #self.plugins do -- 732
			local pl = self.plugins[i + 1] -- 733
			if pl.drawActorsOverlay ~= nil then -- 734
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 735
			end -- 735
			i = i + 1 -- 732
		end -- 732
	end -- 732
	self.roguelikeUi:drawActorsOverlay(self.worldOverlayDraw, self.fgGlow, self.worldArt, ctx) -- 738
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam, p.room.depth ~= nil) -- 741
	if view.visualMode == "pixel" then -- 744
		self.stage:drawForegroundFraming( -- 745
			self.worldOverlayDraw, -- 745
			w, -- 745
			h, -- 745
			p, -- 745
			self.cam -- 745
		) -- 745
		self.escortWorld:drawForegroundFraming( -- 746
			self.worldOverlayDraw, -- 746
			self.fgGlow, -- 746
			self.worldArt, -- 746
			p, -- 746
			self.cam, -- 746
			self.time -- 746
		) -- 746
		self.sceneFx:drawForegroundWeather( -- 747
			self.fgGlow, -- 747
			p, -- 747
			self.cam, -- 747
			w, -- 747
			h -- 747
		) -- 747
	end -- 747
	self.vfx:drawScreenVfx( -- 749
		self.fgGlow, -- 749
		w, -- 749
		h, -- 749
		p.room.key, -- 749
		view.visualMode ~= "pixel" -- 749
	) -- 749
	local action = {type = "none"} -- 752
	if p.paused then -- 753
		action = self.menus:updateAndDrawPause( -- 754
			safeDt, -- 755
			input, -- 756
			self.uiDraw, -- 757
			self.uiInkDraw, -- 758
			self.uiArt, -- 759
			self.uiGlow, -- 760
			self.texts, -- 761
			uiW, -- 762
			uiH, -- 763
			uiScale, -- 764
			view.assistHintsEnabled, -- 765
			function() -- 766
				self.contract:toggleAssistHints() -- 767
			end, -- 766
			self.stageVp.safeUi, -- 769
			p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom(), -- 770
			view.roguelike.active, -- 771
			function() -- 772
				self.roguelikeUi:openLedger() -- 773
			end -- 772
		) -- 772
	else -- 772
		local cutsceneHandled = false -- 778
		do -- 778
			i = 0 -- 779
			while i < #self.plugins do -- 779
				local pl = self.plugins[i + 1] -- 780
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 781
					self.uiDraw, -- 782
					self.uiInkDraw, -- 782
					self.uiArt, -- 782
					self.uiGlow, -- 782
					ctx -- 782
				) then -- 782
					cutsceneHandled = true -- 783
				end -- 783
				i = i + 1 -- 779
			end -- 779
		end -- 779
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 787
		if not cutsceneHandled and not roguelikeModal then -- 788
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 789
			self.hud:draw( -- 790
				self.uiDraw, -- 791
				self.uiInkDraw, -- 792
				self.uiArt, -- 793
				self.uiGlow, -- 794
				self.texts, -- 795
				p, -- 796
				self.cam, -- 797
				self.vfx, -- 798
				self.narrative.letterbox, -- 799
				uiScale, -- 800
				view.assistHintsEnabled, -- 801
				true, -- 802
				input.inputMode, -- 803
				input.gamepadLayout, -- 804
				self.stageVp.safeUi, -- 805
				input.retryHoldProgress, -- 806
				touchOverlayVisible -- 807
			) -- 807
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 809
			local savedBannerT = self.narrative.bannerT -- 810
			if suppressBanner then -- 811
				self.narrative.bannerT = 0 -- 812
			end -- 812
			self.narrative:draw( -- 814
				self.uiDraw, -- 815
				self.uiInkDraw, -- 816
				self.uiGlow, -- 817
				self.uiArt, -- 818
				self.texts, -- 819
				p, -- 820
				uiW, -- 821
				uiH, -- 822
				view.assistHintsEnabled, -- 823
				input.inputMode, -- 824
				input.gamepadLayout, -- 825
				self.stageVp.safeUi -- 826
			) -- 826
			if suppressBanner then -- 828
				self.narrative.bannerT = savedBannerT -- 829
			end -- 829
		elseif cutsceneHandled then -- 831
			self.narrative:drawCutsceneDialogue( -- 833
				self.uiDraw, -- 834
				self.uiInkDraw, -- 835
				self.uiArt, -- 836
				self.texts, -- 837
				p, -- 838
				uiW, -- 839
				uiH, -- 840
				self.stageVp.safeUi -- 841
			) -- 841
		end -- 841
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 845
		do -- 845
			i = 0 -- 846
			while i < #self.plugins do -- 846
				local pl = self.plugins[i + 1] -- 847
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 848
					self.uiDraw, -- 849
					self.uiInkDraw, -- 849
					self.uiArt, -- 849
					self.uiGlow, -- 849
					ctx -- 849
				) then -- 849
					suppressReticle = true -- 850
				end -- 850
				i = i + 1 -- 846
			end -- 846
		end -- 846
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 853
			self.uiDraw, -- 854
			self.uiInkDraw, -- 854
			self.uiArt, -- 854
			self.uiGlow, -- 854
			ctx -- 854
		) then -- 854
			suppressReticle = true -- 855
		end -- 855
		if not suppressReticle then -- 857
			self.hud:drawReticleOverlay( -- 858
				self.uiInkDraw, -- 859
				self.uiArt, -- 860
				self.uiGlow, -- 861
				p, -- 862
				self.cam, -- 863
				self.vfx, -- 864
				self.narrative.letterbox, -- 865
				uiScale, -- 866
				input:isTouchMode() -- 867
			) -- 867
		end -- 867
		if view.isRehearsal then -- 872
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 873
			drawSilkVeil( -- 874
				self.uiDraw, -- 874
				self.uiArt, -- 874
				"rehearsal_tag_veil", -- 874
				uiW * 0.5, -- 874
				uiH - 22 - self.stageVp.safeUi.top, -- 874
				168, -- 874
				26, -- 874
				PALETTE.inkWarm, -- 874
				0.74, -- 874
				8 -- 874
			) -- 874
			self.texts:put( -- 875
				"xs", -- 875
				badgeText, -- 875
				uiW * 0.5, -- 875
				uiH - 22 - self.stageVp.safeUi.top, -- 875
				toColor(PALETTE.amberCore), -- 875
				0.5, -- 875
				0.5, -- 875
				"Center", -- 875
				1.2, -- 875
				0.92, -- 875
				0.08 -- 875
			) -- 875
		end -- 875
	end -- 875
	self:drawToast(uiW) -- 879
	self:finishFrame() -- 880
	return action -- 881
end -- 561
return ____exports -- 561
