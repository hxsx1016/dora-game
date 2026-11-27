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
____exports.WatchFrontend = __TS__Class() -- 48
local WatchFrontend = ____exports.WatchFrontend -- 48
WatchFrontend.name = "WatchFrontend" -- 48
function WatchFrontend.prototype.____constructor(self, parent) -- 92
	self.occlusion = __TS__New(DepthOcclusion) -- 49
	self.cam = __TS__New(CameraDirector) -- 69
	self.adapter = __TS__New(PlayAdapter) -- 70
	self.contract = __TS__New(DualRouteContract) -- 71
	self.audio = __TS__New(AudioDirector) -- 72
	self.soundscape = __TS__New(SoundscapeDirector) -- 73
	self.stage = __TS__New(StageRenderer) -- 74
	self.escortWorld = __TS__New(EscortWorldRenderer) -- 75
	self.props = __TS__New(PropsRenderer) -- 76
	self.actors = __TS__New(ActorsRenderer) -- 77
	self.vfx = __TS__New(VfxSystem) -- 78
	self.hud = __TS__New(HudRenderer) -- 79
	self.narrative = __TS__New(NarrativeRenderer) -- 80
	self.menus = __TS__New(MenuRenderer) -- 81
	self.plugins = {} -- 83
	self.screen = "title" -- 85
	self.time = 0 -- 86
	self.stageVp = computeStageViewport(1280, 720) -- 88
	self.toastText = "" -- 89
	self.toastTimer = 0 -- 90
	self.layerRoot = Node() -- 93
	self.layerRoot.order = 5 -- 94
	self.layerRoot:addTo(parent) -- 95
	ensureSecondHalfAssetsRegistered() -- 96
	self.audio:attachHost(self.layerRoot) -- 98
	self.menus.onUiSound = function(____, kind) -- 99
		self:playMenuUiSound(kind) -- 100
	end -- 99
	self.menus.onAudioSettingsChanged = function(____, inp) -- 102
		self.audio:applyUserVolumes(inp.settings) -- 103
	end -- 102
	local additive = BlendFunc("SrcAlpha", "One") -- 106
	self.bgDraw = DrawNode() -- 108
	self.bgDraw.order = 10 -- 109
	self.bgDraw:addTo(self.layerRoot) -- 110
	self.escortTowerDraw = DrawNode() -- 113
	self.escortTowerDraw.order = 13 -- 114
	self.escortTowerDraw:addTo(self.layerRoot) -- 115
	self.bgGlow = DrawNode() -- 117
	self.bgGlow.order = 15 -- 118
	self.bgGlow.blendFunc = additive -- 119
	self.bgGlow:addTo(self.layerRoot) -- 120
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 122
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 123
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 124
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 125
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 126
	self.fgDraw = DrawNode() -- 128
	self.fgDraw.order = 30 -- 129
	self.fgDraw:addTo(self.layerRoot) -- 130
	self.fgGlow = DrawNode() -- 132
	self.fgGlow.order = 35 -- 133
	self.fgGlow.blendFunc = additive -- 134
	self.fgGlow:addTo(self.layerRoot) -- 135
	self.uiLayer = Node() -- 137
	self.uiLayer.order = 40 -- 138
	self.uiLayer:addTo(self.layerRoot) -- 139
	self.uiDraw = DrawNode() -- 141
	self.uiDraw.order = 0 -- 142
	self.uiDraw:addTo(self.uiLayer) -- 143
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 145
	self.uiInkDraw = DrawNode() -- 147
	self.uiInkDraw.order = 4 -- 148
	self.uiInkDraw:addTo(self.uiLayer) -- 149
	self.uiGlow = DrawNode() -- 151
	self.uiGlow.order = 6 -- 152
	self.uiGlow.blendFunc = additive -- 153
	self.uiGlow:addTo(self.uiLayer) -- 154
	self.uiMask = DrawNode() -- 156
	self.uiMask.order = 8 -- 157
	self.uiMask:addTo(self.uiLayer) -- 158
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 160
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 174
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 175
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 176
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 177
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 178
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 179
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 180
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 181
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 182
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 183
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 184
end -- 92
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 188
	local i = 0 -- 189
	do -- 189
		i = 0 -- 190
		while i < #self.plugins do -- 190
			if self.plugins[i + 1].id == plugin.id then -- 190
				self.plugins[i + 1] = plugin -- 192
				self:syncRuntimeHooks() -- 193
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 193
					plugin:onBindPlay( -- 195
						self.boundPlay, -- 195
						self.contract:peekSnapshot(self.boundPlay) -- 195
					) -- 195
				end -- 195
				return -- 197
			end -- 197
			i = i + 1 -- 190
		end -- 190
	end -- 190
	local ____self_plugins_0 = self.plugins -- 190
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 200
	self:syncRuntimeHooks() -- 201
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 201
		plugin:onBindPlay( -- 203
			self.boundPlay, -- 203
			self.contract:peekSnapshot(self.boundPlay) -- 203
		) -- 203
	end -- 203
end -- 188
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 208
	local w = 0 -- 209
	local i = 0 -- 210
	do -- 210
		i = 0 -- 211
		while i < #self.plugins do -- 211
			if self.plugins[i + 1].id ~= id then -- 211
				self.plugins[w + 1] = self.plugins[i + 1] -- 213
				w = w + 1 -- 214
			end -- 214
			i = i + 1 -- 211
		end -- 211
	end -- 211
	__TS__ArraySetLength(self.plugins, w) -- 211
	self:syncRuntimeHooks() -- 218
end -- 208
function WatchFrontend.prototype.getPlugin(self, id) -- 222
	local i = 0 -- 223
	do -- 223
		i = 0 -- 224
		while i < #self.plugins do -- 224
			if self.plugins[i + 1].id == id then -- 224
				return self.plugins[i + 1] -- 226
			end -- 226
			i = i + 1 -- 224
		end -- 224
	end -- 224
	return nil -- 229
end -- 222
function WatchFrontend.prototype.getPlugins(self) -- 232
	return self.plugins -- 233
end -- 232
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 241
	local g = _G -- 242
	local ____temp_1 -- 243
	if g.package ~= nil then -- 243
		____temp_1 = g.package.loaded -- 243
	else -- 243
		____temp_1 = nil -- 243
	end -- 243
	local loaded = ____temp_1 -- 243
	if loaded == nil then -- 243
		return -- 245
	end -- 245
	local rawFe = loaded["watch.fe"] -- 247
	if rawFe ~= nil and type(rawFe) == "table" then -- 247
		local watchFe = rawFe -- 249
		if watchFe.contract ~= self.contract then -- 249
			watchFe.contract = self.contract -- 251
			watchFe.audio = self.audio -- 252
			watchFe.soundscape = self.soundscape -- 253
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 254
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 255
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 256
		end -- 256
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 258
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 259
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 260
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 261
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 262
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 263
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 264
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 265
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 266
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 267
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 268
	end -- 268
end -- 241
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 272
	local scale = math.max( -- 273
		0.25, -- 273
		math.min(w / 1280, h / 720) -- 273
	) -- 273
	self.uiLayer.scaleX = scale -- 274
	self.uiLayer.scaleY = scale -- 275
	return scale -- 276
end -- 272
function WatchFrontend.prototype.setVisible(self, v) -- 280
	self.layerRoot.visible = v -- 281
	if not v then -- 281
		self.texts:hideAll() -- 283
	end -- 283
end -- 280
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 288
	self:syncRuntimeHooks() -- 289
	self.boundPlay = p -- 290
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 291
	self.cam:snap(p, w, h) -- 292
	self.adapter:reset(p) -- 293
	self.contract:resetForRoom(p) -- 294
	self.audio:stopRoomTransient() -- 295
	self.soundscape:resetForRoom(p) -- 296
	self.actors:reset(p) -- 297
	self.occlusion:reset() -- 298
	self.vfx:reset() -- 299
	self.hud:reset(p) -- 300
	self.narrative:onEnterRoom(p.room.key) -- 301
	if #self.plugins > 0 then -- 301
		local initView = self.contract:peekSnapshot(p) -- 304
		local i = 0 -- 305
		do -- 305
			i = 0 -- 306
			while i < #self.plugins do -- 306
				local pl = self.plugins[i + 1] -- 307
				if pl.onBindPlay ~= nil then -- 307
					pl:onBindPlay(p, initView) -- 309
				end -- 309
				i = i + 1 -- 306
			end -- 306
		end -- 306
	end -- 306
end -- 288
function WatchFrontend.prototype.clearAll(self) -- 315
	self.bgDraw:clear() -- 316
	self.escortTowerDraw:clear() -- 317
	self.bgGlow:clear() -- 318
	self.fgDraw:clear() -- 319
	self.fgGlow:clear() -- 320
	self.uiDraw:clear() -- 321
	self.uiInkDraw:clear() -- 322
	self.uiGlow:clear() -- 323
	self.uiMask:clear() -- 324
	self.backdropArt:beginFrame() -- 325
	self.dioramaBg:beginFrame() -- 326
	self.dioramaWorld:beginFrame() -- 327
	self.dioramaFg:beginFrame() -- 328
	self.worldArt:beginFrame() -- 329
	self.uiArt:beginFrame() -- 330
	self.texts:beginFrame() -- 331
end -- 315
function WatchFrontend.prototype.finishFrame(self) -- 334
	self.backdropArt:endFrame() -- 335
	self.dioramaBg:endFrame() -- 336
	self.dioramaWorld:endFrame() -- 337
	self.dioramaFg:endFrame() -- 338
	self.worldArt:endFrame() -- 339
	self.uiArt:endFrame() -- 340
	self.texts:endFrame() -- 341
end -- 334
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 345
	self.stageVp = vp -- 346
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 347
end -- 345
function WatchFrontend.prototype.showToast(self, text, duration) -- 351
	if duration == nil then -- 351
		duration = 1.8 -- 351
	end -- 351
	self.toastText = text -- 352
	self.toastTimer = duration -- 353
end -- 351
function WatchFrontend.prototype.getToastText(self) -- 356
	return self.toastTimer > 0 and self.toastText or "" -- 357
end -- 356
function WatchFrontend.prototype.drawToast(self, uiW) -- 360
	if self.toastTimer <= 0 or self.toastText == "" then -- 360
		return -- 362
	end -- 362
	local alpha = math.min(1, self.toastTimer * 2.4) -- 364
	local cx = uiW * 0.5 -- 365
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 366
	drawSilkVeil( -- 367
		self.uiDraw, -- 367
		self.uiArt, -- 367
		"fe_toast_veil", -- 367
		cx, -- 367
		cy, -- 367
		340, -- 367
		38, -- 367
		PALETTE.inkWarm, -- 367
		0.86 * alpha, -- 367
		9 -- 367
	) -- 367
	self.texts:put( -- 368
		"sm", -- 368
		self.toastText, -- 368
		cx, -- 368
		cy, -- 368
		toColor(PALETTE.amberCore), -- 368
		0.5, -- 368
		0.5, -- 368
		"Center", -- 368
		1.4, -- 368
		0.96 * alpha, -- 368
		0.08 -- 368
	) -- 368
end -- 360
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 372
	local offers = p:getStoryTalentOffers() -- 373
	if #offers == 0 then -- 373
		return {} -- 375
	end -- 375
	local uiScale = math.max( -- 377
		0.25, -- 377
		math.min(w / 1280, h / 720) -- 377
	) -- 377
	return self.hud:talentCardRects( -- 378
		w / uiScale, -- 378
		h / uiScale, -- 378
		#offers, -- 378
		touchMode, -- 378
		self.stageVp.safeUi.top -- 378
	) -- 378
end -- 372
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 381
	if kind == "hover" then -- 381
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 383
	elseif kind == "confirm" then -- 383
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 385
	elseif kind == "back" then -- 385
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 387
	elseif kind == "start" then -- 387
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 389
	elseif kind == "pauseOpen" then -- 389
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 391
	elseif kind == "pauseClose" then -- 391
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 393
	elseif kind == "toggle" then -- 393
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 395
	end -- 395
end -- 381
function WatchFrontend.prototype.resetTrialAudio(self, p) -- 400
	self.adapter:reset(p) -- 401
	self.audio:stopRoomTransient() -- 402
	self.soundscape:resetForRoom(p) -- 403
end -- 400
function WatchFrontend.prototype.syncTrialAudio(self, dt, p, offerCount, ev) -- 407
	local safeDt = math.min( -- 408
		0.05, -- 408
		math.max(0.001, dt) -- 408
	) -- 408
	self.audio:setPaused(p.paused) -- 409
	self.audio:setCameraRef(p.player.x, 960) -- 410
	self.audio:update(safeDt) -- 411
	if not p.paused then -- 411
		local frame = ev ~= nil and ev or self.adapter:sample(p) -- 413
		self.audio:ingestEvents(frame, p) -- 414
		self.soundscape:updateTrial(safeDt, p, self.audio, offerCount) -- 415
	end -- 415
end -- 407
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 420
	self:syncRuntimeHooks() -- 421
	local safeDt = math.min( -- 422
		0.05, -- 422
		math.max(0, dt) -- 422
	) -- 422
	if self.toastTimer > 0 then -- 422
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 424
	end -- 424
	if self.screen == "title" and self.boundPlay ~= nil then -- 424
		self.audio:stopRoomTransient() -- 427
		self.boundPlay = nil -- 428
	end -- 428
	self.audio:update(safeDt) -- 430
	self.soundscape:updateMenu(self.screen, self.audio) -- 431
	self:setVisible(true) -- 432
	self:clearAll() -- 433
	local uiScale = self:resizeInterface(w, h) -- 434
	local act = self.menus:updateAndDrawScreen( -- 435
		dt, -- 436
		self.screen, -- 437
		input, -- 438
		self.stage, -- 439
		self.bgDraw, -- 440
		self.bgGlow, -- 441
		self.backdropArt, -- 442
		self.uiArt, -- 443
		self.uiDraw, -- 444
		self.uiInkDraw, -- 445
		self.uiGlow, -- 446
		self.texts, -- 447
		w, -- 448
		h, -- 449
		uiScale, -- 450
		self.stageVp.safeUi -- 451
	) -- 451
	self:drawToast(w / uiScale) -- 453
	self:finishFrame() -- 454
	return act -- 455
end -- 420
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 459
	local offers = p:getStoryTalentOffers() -- 460
	if #offers == 0 then -- 460
		return false -- 462
	end -- 462
	if input.inputMode == "gamepad" and not input.uiPressed then -- 462
		return false -- 465
	end -- 465
	local useUiPtr = input.uiInside or input.uiPressed -- 467
	local ____useUiPtr_2 -- 468
	if useUiPtr then -- 468
		____useUiPtr_2 = input.uiInside -- 468
	else -- 468
		____useUiPtr_2 = input.inside -- 468
	end -- 468
	local inside = ____useUiPtr_2 -- 468
	if not inside then -- 468
		return false -- 470
	end -- 470
	local uiScale = math.max( -- 472
		0.25, -- 472
		math.min(w / 1280, h / 720) -- 472
	) -- 472
	local uiW = w / uiScale -- 473
	local uiH = h / uiScale -- 474
	local rawX = useUiPtr and input.uiX or input.mx -- 475
	local rawY = useUiPtr and input.uiY or input.my -- 476
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 477
	local boxes = self.hud:talentCardRects( -- 478
		uiW, -- 478
		uiH, -- 478
		#offers, -- 478
		input:isTouchMode(), -- 478
		self.stageVp.safeUi.top -- 478
	) -- 478
	local i = 0 -- 479
	do -- 479
		i = 0 -- 480
		while i < #boxes do -- 480
			if boxes[i + 1]:containsPoint(pointer) then -- 480
				return p:chooseTalent(i) -- 482
			end -- 482
			i = i + 1 -- 480
		end -- 480
	end -- 480
	return false -- 485
end -- 459
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h, trialMode, evIn) -- 489
	if trialMode == nil then -- 489
		trialMode = false -- 489
	end -- 489
	self:syncRuntimeHooks() -- 490
	self:setVisible(true) -- 491
	if self.boundPlay ~= p then -- 491
		self:bindPlay(p, w, h) -- 493
	end -- 493
	local safeDt = math.min( -- 495
		0.05, -- 495
		math.max(0.001, dt) -- 495
	) -- 495
	if self.toastTimer > 0 then -- 495
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 497
	end -- 497
	if not trialMode then -- 497
		self.audio:setPaused(p.paused) -- 500
		self.audio:setCameraRef( -- 501
			self.cam.x, -- 501
			w / math.max(0.25, self.cam.ppu) -- 501
		) -- 501
		self.audio:update(safeDt) -- 502
	end -- 502
	local ev -- 505
	local worldDt = 0 -- 506
	local uiDt = 0 -- 507
	if not p.paused then -- 507
		ev = evIn ~= nil and evIn or self.adapter:sample(p) -- 511
		self.vfx:ingest(ev, p, self.cam) -- 512
		if not trialMode then -- 512
			self.audio:ingestEvents(ev, p) -- 514
		end -- 514
		local touch = input:getTouch() -- 516
		if touch ~= nil then -- 516
			if ev.playerHit then -- 516
				touch:vibrate(0.036) -- 519
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 519
				touch:vibrate(0.024) -- 521
			elseif ev.coverDeflect then -- 521
				touch:vibrate(0.018) -- 523
			elseif ev.knockPulse then -- 523
				touch:vibrate(0.014) -- 525
			end -- 525
		end -- 525
	else -- 525
		ev = self.adapter:emptyFrame(p) -- 530
		self.narrative.wipeT = 0 -- 531
	end -- 531
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 534
	if not p.paused then -- 534
		local clampedScale = math.max( -- 536
			0, -- 536
			math.min(2, view.timeScale) -- 536
		) -- 536
		uiDt = safeDt -- 537
		worldDt = safeDt * clampedScale -- 538
	end -- 538
	local uiScale = self:resizeInterface(w, h) -- 541
	local uiW = w / uiScale -- 542
	local uiH = h / uiScale -- 543
	local ctx = { -- 545
		p = p, -- 546
		view = view, -- 547
		events = ev, -- 548
		input = input, -- 549
		cam = self.cam, -- 550
		audio = self.audio, -- 551
		assets = self.worldArt, -- 552
		backdropArt = self.backdropArt, -- 553
		worldArt = self.worldArt, -- 554
		uiArt = self.uiArt, -- 555
		uiMask = self.uiMask, -- 556
		dioramaBg = self.dioramaBg, -- 557
		dioramaWorld = self.dioramaWorld, -- 558
		dioramaFg = self.dioramaFg, -- 559
		texts = self.texts, -- 560
		worldDt = worldDt, -- 561
		uiDt = uiDt, -- 562
		w = w, -- 563
		h = h, -- 564
		uiW = uiW, -- 565
		uiH = uiH, -- 566
		uiScale = uiScale, -- 567
		safeUi = self.stageVp.safeUi, -- 568
		paused = p.paused -- 569
	} -- 569
	local i = 0 -- 573
	do -- 573
		i = 0 -- 574
		while i < #self.plugins do -- 574
			local pl = self.plugins[i + 1] -- 575
			if pl.update ~= nil then -- 575
				pl:update(ctx) -- 577
			end -- 577
			i = i + 1 -- 574
		end -- 574
	end -- 574
	if not p.paused then -- 574
		self.time = self.time + worldDt -- 582
		self.cam:update(worldDt, p, w, h) -- 583
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 584
		if not trialMode then -- 584
			self.audio:setCameraRef( -- 586
				self.cam.x, -- 586
				w / math.max(0.25, self.cam.ppu) -- 586
			) -- 586
			self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 587
		end -- 587
		self.actors:update(worldDt, p) -- 589
		self.vfx:update( -- 590
			worldDt, -- 590
			themeOf(p.room.key).ambient -- 590
		) -- 590
		self.hud:update(safeDt, p) -- 591
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 592
	else -- 592
		self.cam:update(0, p, w, h) -- 594
	end -- 594
	self:clearAll() -- 597
	local backdropHandled = false -- 600
	do -- 600
		i = 0 -- 601
		while i < #self.plugins do -- 601
			local pl = self.plugins[i + 1] -- 602
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 602
				backdropHandled = true -- 604
			end -- 604
			i = i + 1 -- 601
		end -- 601
	end -- 601
	if not backdropHandled then -- 601
		self.stage:drawBackdrop( -- 608
			self.bgDraw, -- 608
			self.bgGlow, -- 608
			self.backdropArt, -- 608
			p, -- 608
			self.cam, -- 608
			self.time -- 608
		) -- 608
	end -- 608
	if view.visualMode == "pixel" then -- 608
		self.escortWorld:drawBackdropOverlay( -- 611
			self.bgDraw, -- 611
			self.bgGlow, -- 611
			self.backdropArt, -- 611
			p, -- 611
			self.cam, -- 611
			self.time, -- 611
			self.escortTowerDraw -- 611
		) -- 611
	end -- 611
	local worldHandled = false -- 615
	do -- 615
		i = 0 -- 616
		while i < #self.plugins do -- 616
			local pl = self.plugins[i + 1] -- 617
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 617
				worldHandled = true -- 619
			end -- 619
			i = i + 1 -- 616
		end -- 616
	end -- 616
	if not worldHandled then -- 616
		self.stage:drawPlayableWorld( -- 623
			self.fgDraw, -- 623
			self.fgGlow, -- 623
			self.worldArt, -- 623
			p, -- 623
			self.cam, -- 623
			self.time, -- 623
			self.occlusion, -- 623
			worldDt -- 623
		) -- 623
	end -- 623
	local propsHandled = false -- 627
	do -- 627
		i = 0 -- 628
		while i < #self.plugins do -- 628
			local pl = self.plugins[i + 1] -- 629
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 629
				propsHandled = true -- 631
			end -- 631
			i = i + 1 -- 628
		end -- 628
	end -- 628
	if not propsHandled then -- 628
		self.props:drawAll( -- 635
			self.fgDraw, -- 635
			self.fgGlow, -- 635
			self.worldArt, -- 635
			p, -- 635
			self.cam, -- 635
			self.time, -- 635
			self.occlusion, -- 635
			worldDt -- 635
		) -- 635
	end -- 635
	if view.visualMode == "pixel" then -- 635
		self.escortWorld:drawWorldSetpieces( -- 638
			self.fgDraw, -- 638
			self.fgGlow, -- 638
			self.worldArt, -- 638
			p, -- 638
			view, -- 638
			self.cam, -- 638
			self.time -- 638
		) -- 638
	end -- 638
	if view.visualMode ~= "museum" then -- 638
		local pose -- 643
		for ____, pl in ipairs(self.plugins) do -- 644
			if pl.drawPartyPose ~= nil then -- 644
				pose = pl:drawPartyPose(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 646
				if pose ~= nil then -- 646
					break -- 647
				end -- 647
			end -- 647
		end -- 647
		self.actors:drawAll( -- 650
			self.fgDraw, -- 650
			self.fgGlow, -- 650
			self.worldArt, -- 650
			p, -- 650
			self.cam, -- 650
			pose -- 650
		) -- 650
	end -- 650
	do -- 650
		i = 0 -- 652
		while i < #self.plugins do -- 652
			local pl = self.plugins[i + 1] -- 653
			if pl.drawActorsOverlay ~= nil then -- 653
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 655
			end -- 655
			i = i + 1 -- 652
		end -- 652
	end -- 652
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 660
	if view.visualMode == "pixel" then -- 660
		self.stage:drawForegroundFraming( -- 664
			self.fgDraw, -- 664
			w, -- 664
			h, -- 664
			p, -- 664
			self.cam -- 664
		) -- 664
		self.escortWorld:drawForegroundFraming( -- 665
			self.fgDraw, -- 665
			self.fgGlow, -- 665
			self.worldArt, -- 665
			p, -- 665
			self.cam, -- 665
			self.time -- 665
		) -- 665
	end -- 665
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 667
	local action = {type = "none"} -- 670
	if p.paused then -- 670
		action = trialMode and ({type = "none"}) or self.menus:updateAndDrawPause( -- 673
			safeDt, -- 674
			input, -- 675
			self.uiDraw, -- 676
			self.uiInkDraw, -- 677
			self.uiArt, -- 678
			self.uiGlow, -- 679
			self.texts, -- 680
			uiW, -- 681
			uiH, -- 682
			uiScale, -- 683
			view.assistHintsEnabled, -- 684
			function() -- 685
				self.contract:toggleAssistHints() -- 686
			end, -- 685
			self.stageVp.safeUi -- 688
		) -- 688
	else -- 688
		local cutsceneHandled = false -- 692
		do -- 692
			i = 0 -- 693
			while i < #self.plugins do -- 693
				local pl = self.plugins[i + 1] -- 694
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 694
					self.uiDraw, -- 696
					self.uiInkDraw, -- 696
					self.uiArt, -- 696
					self.uiGlow, -- 696
					ctx -- 696
				) then -- 696
					cutsceneHandled = true -- 697
				end -- 697
				i = i + 1 -- 693
			end -- 693
		end -- 693
		if not cutsceneHandled then -- 693
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 702
			self.hud:draw( -- 703
				self.uiDraw, -- 704
				self.uiInkDraw, -- 705
				self.uiArt, -- 706
				self.uiGlow, -- 707
				self.texts, -- 708
				p, -- 709
				self.cam, -- 710
				self.vfx, -- 711
				self.narrative.letterbox, -- 712
				uiScale, -- 713
				view.assistHintsEnabled, -- 714
				true, -- 715
				input.inputMode, -- 716
				input.gamepadLayout, -- 717
				self.stageVp.safeUi, -- 718
				input.retryHoldProgress, -- 719
				touchOverlayVisible -- 720
			) -- 720
			self.narrative:draw( -- 722
				self.uiDraw, -- 723
				self.uiInkDraw, -- 724
				self.uiGlow, -- 725
				self.uiArt, -- 726
				self.texts, -- 727
				p, -- 728
				uiW, -- 729
				uiH, -- 730
				view.assistHintsEnabled, -- 731
				input.inputMode, -- 732
				input.gamepadLayout, -- 733
				self.stageVp.safeUi -- 734
			) -- 734
		end -- 734
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 738
		do -- 738
			i = 0 -- 739
			while i < #self.plugins do -- 739
				local pl = self.plugins[i + 1] -- 740
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 740
					self.uiDraw, -- 742
					self.uiInkDraw, -- 742
					self.uiArt, -- 742
					self.uiGlow, -- 742
					ctx -- 742
				) then -- 742
					suppressReticle = true -- 743
				end -- 743
				i = i + 1 -- 739
			end -- 739
		end -- 739
		if not suppressReticle then -- 739
			self.hud:drawReticleOverlay( -- 747
				self.uiInkDraw, -- 748
				self.uiArt, -- 749
				self.uiGlow, -- 750
				p, -- 751
				self.cam, -- 752
				self.vfx, -- 753
				self.narrative.letterbox, -- 754
				uiScale, -- 755
				input:isTouchMode() -- 756
			) -- 756
		end -- 756
		if view.isRehearsal then -- 756
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 762
			drawSilkVeil( -- 763
				self.uiDraw, -- 763
				self.uiArt, -- 763
				"rehearsal_tag_veil", -- 763
				uiW * 0.5, -- 763
				uiH - 22 - self.stageVp.safeUi.top, -- 763
				168, -- 763
				26, -- 763
				PALETTE.inkWarm, -- 763
				0.74, -- 763
				8 -- 763
			) -- 763
			self.texts:put( -- 764
				"xs", -- 764
				badgeText, -- 764
				uiW * 0.5, -- 764
				uiH - 22 - self.stageVp.safeUi.top, -- 764
				toColor(PALETTE.amberCore), -- 764
				0.5, -- 764
				0.5, -- 764
				"Center", -- 764
				1.2, -- 764
				0.92, -- 764
				0.08 -- 764
			) -- 764
		end -- 764
	end -- 764
	self:drawToast(uiW) -- 768
	self:finishFrame() -- 769
	return action -- 770
end -- 489
return ____exports -- 489