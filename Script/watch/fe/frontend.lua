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
local ____vfx = require("Script.watch.fe.renderer.vfx") -- 27
local VfxSystem = ____vfx.VfxSystem -- 27
local ____escort_world = require("Script.watch.fe.scenes.escort_world") -- 28
local EscortWorldRenderer = ____escort_world.EscortWorldRenderer -- 28
local ____second_half_assets = require("Script.watch.fe.scenes.second_half_assets") -- 29
local ensureSecondHalfAssetsRegistered = ____second_half_assets.ensureSecondHalfAssetsRegistered -- 29
local ____textpool = require("Script.watch.fe.ui.textpool") -- 30
local TextPool = ____textpool.TextPool -- 30
local ____hud = require("Script.watch.fe.ui.hud") -- 31
local HudRenderer = ____hud.HudRenderer -- 31
local ____narrative = require("Script.watch.fe.ui.narrative") -- 32
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 32
local ____menus = require("Script.watch.fe.ui.menus") -- 33
local MenuRenderer = ____menus.MenuRenderer -- 33
local ____theme = require("Script.watch.fe.theme") -- 34
local PALETTE = ____theme.PALETTE -- 34
local drawSilkVeil = ____theme.drawSilkVeil -- 34
local themeOf = ____theme.themeOf -- 34
local toColor = ____theme.toColor -- 34
local ____ming_audit = require("Script.watch.fe.renderer.ming_audit") -- 35
local MingArtAuditPlugin = ____ming_audit.MingArtAuditPlugin -- 35
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 36
local GateTransitionPlugin = ____gate_transition.GateTransitionPlugin -- 36
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 37
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 37
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 38
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 38
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 39
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 39
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 40
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 40
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 41
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 41
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 42
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 42
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 43
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 43
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 44
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 44
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 45
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 45
____exports.WatchFrontend = __TS__Class() -- 47
local WatchFrontend = ____exports.WatchFrontend -- 47
WatchFrontend.name = "WatchFrontend" -- 47
function WatchFrontend.prototype.____constructor(self, parent) -- 87
	self.occlusion = __TS__New(DepthOcclusion) -- 48
	self.cam = __TS__New(CameraDirector) -- 64
	self.adapter = __TS__New(PlayAdapter) -- 65
	self.contract = __TS__New(DualRouteContract) -- 66
	self.audio = __TS__New(AudioDirector) -- 67
	self.soundscape = __TS__New(SoundscapeDirector) -- 68
	self.stage = __TS__New(StageRenderer) -- 69
	self.escortWorld = __TS__New(EscortWorldRenderer) -- 70
	self.props = __TS__New(PropsRenderer) -- 71
	self.actors = __TS__New(ActorsRenderer) -- 72
	self.vfx = __TS__New(VfxSystem) -- 73
	self.hud = __TS__New(HudRenderer) -- 74
	self.narrative = __TS__New(NarrativeRenderer) -- 75
	self.menus = __TS__New(MenuRenderer) -- 76
	self.plugins = {} -- 78
	self.screen = "title" -- 80
	self.time = 0 -- 81
	self.stageVp = computeStageViewport(1280, 720) -- 83
	self.toastText = "" -- 84
	self.toastTimer = 0 -- 85
	self.layerRoot = Node() -- 88
	self.layerRoot.order = 5 -- 89
	self.layerRoot:addTo(parent) -- 90
	ensureSecondHalfAssetsRegistered() -- 91
	self.audio:attachHost(self.layerRoot) -- 93
	self.menus.onUiSound = function(____, kind) -- 94
		self:playMenuUiSound(kind) -- 95
	end -- 94
	self.menus.onAudioSettingsChanged = function(____, inp) -- 97
		self.audio:applyUserVolumes(inp.settings) -- 98
	end -- 97
	local additive = BlendFunc("SrcAlpha", "One") -- 101
	self.bgDraw = DrawNode() -- 103
	self.bgDraw.order = 10 -- 104
	self.bgDraw:addTo(self.layerRoot) -- 105
	self.escortTowerDraw = DrawNode() -- 108
	self.escortTowerDraw.order = 13 -- 109
	self.escortTowerDraw:addTo(self.layerRoot) -- 110
	self.bgGlow = DrawNode() -- 112
	self.bgGlow.order = 15 -- 113
	self.bgGlow.blendFunc = additive -- 114
	self.bgGlow:addTo(self.layerRoot) -- 115
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 117
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 118
	self.fgDraw = DrawNode() -- 120
	self.fgDraw.order = 30 -- 121
	self.fgDraw:addTo(self.layerRoot) -- 122
	self.fgGlow = DrawNode() -- 124
	self.fgGlow.order = 35 -- 125
	self.fgGlow.blendFunc = additive -- 126
	self.fgGlow:addTo(self.layerRoot) -- 127
	self.uiLayer = Node() -- 129
	self.uiLayer.order = 40 -- 130
	self.uiLayer:addTo(self.layerRoot) -- 131
	self.uiDraw = DrawNode() -- 133
	self.uiDraw.order = 0 -- 134
	self.uiDraw:addTo(self.uiLayer) -- 135
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 137
	self.uiInkDraw = DrawNode() -- 139
	self.uiInkDraw.order = 4 -- 140
	self.uiInkDraw:addTo(self.uiLayer) -- 141
	self.uiGlow = DrawNode() -- 143
	self.uiGlow.order = 6 -- 144
	self.uiGlow.blendFunc = additive -- 145
	self.uiGlow:addTo(self.uiLayer) -- 146
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 148
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 162
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 163
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 164
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 165
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 166
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 167
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 168
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 169
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 170
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 171
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 172
end -- 87
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 176
	local i = 0 -- 177
	do -- 177
		i = 0 -- 178
		while i < #self.plugins do -- 178
			if self.plugins[i + 1].id == plugin.id then -- 178
				self.plugins[i + 1] = plugin -- 180
				self:syncRuntimeHooks() -- 181
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 181
					plugin:onBindPlay( -- 183
						self.boundPlay, -- 183
						self.contract:peekSnapshot(self.boundPlay) -- 183
					) -- 183
				end -- 183
				return -- 185
			end -- 185
			i = i + 1 -- 178
		end -- 178
	end -- 178
	local ____self_plugins_0 = self.plugins -- 178
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 188
	self:syncRuntimeHooks() -- 189
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 189
		plugin:onBindPlay( -- 191
			self.boundPlay, -- 191
			self.contract:peekSnapshot(self.boundPlay) -- 191
		) -- 191
	end -- 191
end -- 176
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 196
	local w = 0 -- 197
	local i = 0 -- 198
	do -- 198
		i = 0 -- 199
		while i < #self.plugins do -- 199
			if self.plugins[i + 1].id ~= id then -- 199
				self.plugins[w + 1] = self.plugins[i + 1] -- 201
				w = w + 1 -- 202
			end -- 202
			i = i + 1 -- 199
		end -- 199
	end -- 199
	__TS__ArraySetLength(self.plugins, w) -- 199
	self:syncRuntimeHooks() -- 206
end -- 196
function WatchFrontend.prototype.getPlugin(self, id) -- 210
	local i = 0 -- 211
	do -- 211
		i = 0 -- 212
		while i < #self.plugins do -- 212
			if self.plugins[i + 1].id == id then -- 212
				return self.plugins[i + 1] -- 214
			end -- 214
			i = i + 1 -- 212
		end -- 212
	end -- 212
	return nil -- 217
end -- 210
function WatchFrontend.prototype.getPlugins(self) -- 220
	return self.plugins -- 221
end -- 220
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 229
	local g = _G -- 230
	local ____temp_1 -- 231
	if g.package ~= nil then -- 231
		____temp_1 = g.package.loaded -- 231
	else -- 231
		____temp_1 = nil -- 231
	end -- 231
	local loaded = ____temp_1 -- 231
	if loaded == nil then -- 231
		return -- 233
	end -- 233
	local rawFe = loaded["watch.fe"] -- 235
	if rawFe ~= nil and type(rawFe) == "table" then -- 235
		local watchFe = rawFe -- 237
		if watchFe.contract ~= self.contract then -- 237
			watchFe.contract = self.contract -- 239
			watchFe.audio = self.audio -- 240
			watchFe.soundscape = self.soundscape -- 241
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 242
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 243
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 244
		end -- 244
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 246
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 247
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 248
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 249
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 250
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 251
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 252
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 253
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 254
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 255
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 256
	end -- 256
end -- 229
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 260
	local scale = math.max( -- 261
		0.25, -- 261
		math.min(w / 1280, h / 720) -- 261
	) -- 261
	self.uiLayer.scaleX = scale -- 262
	self.uiLayer.scaleY = scale -- 263
	return scale -- 264
end -- 260
function WatchFrontend.prototype.setVisible(self, v) -- 268
	self.layerRoot.visible = v -- 269
	if not v then -- 269
		self.texts:hideAll() -- 271
	end -- 271
end -- 268
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 276
	self:syncRuntimeHooks() -- 277
	self.boundPlay = p -- 278
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 279
	self.cam:snap(p, w, h) -- 280
	self.adapter:reset(p) -- 281
	self.contract:resetForRoom(p) -- 282
	self.audio:stopRoomTransient() -- 283
	self.soundscape:resetForRoom(p) -- 284
	self.actors:reset(p) -- 285
	self.occlusion:reset() -- 286
	self.vfx:reset() -- 287
	self.hud:reset(p) -- 288
	self.narrative:onEnterRoom(p.room.key) -- 289
	if #self.plugins > 0 then -- 289
		local initView = self.contract:peekSnapshot(p) -- 292
		local i = 0 -- 293
		do -- 293
			i = 0 -- 294
			while i < #self.plugins do -- 294
				local pl = self.plugins[i + 1] -- 295
				if pl.onBindPlay ~= nil then -- 295
					pl:onBindPlay(p, initView) -- 297
				end -- 297
				i = i + 1 -- 294
			end -- 294
		end -- 294
	end -- 294
end -- 276
function WatchFrontend.prototype.clearAll(self) -- 303
	self.bgDraw:clear() -- 304
	self.escortTowerDraw:clear() -- 305
	self.bgGlow:clear() -- 306
	self.fgDraw:clear() -- 307
	self.fgGlow:clear() -- 308
	self.uiDraw:clear() -- 309
	self.uiInkDraw:clear() -- 310
	self.uiGlow:clear() -- 311
	self.backdropArt:beginFrame() -- 312
	self.worldArt:beginFrame() -- 313
	self.uiArt:beginFrame() -- 314
	self.texts:beginFrame() -- 315
end -- 303
function WatchFrontend.prototype.finishFrame(self) -- 318
	self.backdropArt:endFrame() -- 319
	self.worldArt:endFrame() -- 320
	self.uiArt:endFrame() -- 321
	self.texts:endFrame() -- 322
end -- 318
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 326
	self.stageVp = vp -- 327
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 328
end -- 326
function WatchFrontend.prototype.showToast(self, text, duration) -- 332
	if duration == nil then -- 332
		duration = 1.8 -- 332
	end -- 332
	self.toastText = text -- 333
	self.toastTimer = duration -- 334
end -- 332
function WatchFrontend.prototype.getToastText(self) -- 337
	return self.toastTimer > 0 and self.toastText or "" -- 338
end -- 337
function WatchFrontend.prototype.drawToast(self, uiW) -- 341
	if self.toastTimer <= 0 or self.toastText == "" then -- 341
		return -- 343
	end -- 343
	local alpha = math.min(1, self.toastTimer * 2.4) -- 345
	local cx = uiW * 0.5 -- 346
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 347
	drawSilkVeil( -- 348
		self.uiDraw, -- 348
		self.uiArt, -- 348
		"fe_toast_veil", -- 348
		cx, -- 348
		cy, -- 348
		340, -- 348
		38, -- 348
		PALETTE.inkWarm, -- 348
		0.86 * alpha, -- 348
		9 -- 348
	) -- 348
	self.texts:put( -- 349
		"sm", -- 349
		self.toastText, -- 349
		cx, -- 349
		cy, -- 349
		toColor(PALETTE.amberCore), -- 349
		0.5, -- 349
		0.5, -- 349
		"Center", -- 349
		1.4, -- 349
		0.96 * alpha, -- 349
		0.08 -- 349
	) -- 349
end -- 341
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 353
	local offers = p:getStoryTalentOffers() -- 354
	if #offers == 0 then -- 354
		return {} -- 356
	end -- 356
	local uiScale = math.max( -- 358
		0.25, -- 358
		math.min(w / 1280, h / 720) -- 358
	) -- 358
	return self.hud:talentCardRects( -- 359
		w / uiScale, -- 359
		h / uiScale, -- 359
		#offers, -- 359
		touchMode, -- 359
		self.stageVp.safeUi.top -- 359
	) -- 359
end -- 353
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 362
	if kind == "hover" then -- 362
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 364
	elseif kind == "confirm" then -- 364
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 366
	elseif kind == "back" then -- 366
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 368
	elseif kind == "start" then -- 368
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 370
	elseif kind == "pauseOpen" then -- 370
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 372
	elseif kind == "pauseClose" then -- 372
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 374
	elseif kind == "toggle" then -- 374
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 376
	end -- 376
end -- 362
function WatchFrontend.prototype.resetTrialAudio(self, p) -- 381
	self.adapter:reset(p) -- 382
	self.audio:stopRoomTransient() -- 383
	self.soundscape:resetForRoom(p) -- 384
end -- 381
function WatchFrontend.prototype.syncTrialAudio(self, dt, p, offerCount) -- 388
	local safeDt = math.min( -- 389
		0.05, -- 389
		math.max(0.001, dt) -- 389
	) -- 389
	self.audio:setPaused(p.paused) -- 390
	self.audio:setCameraRef(p.player.x, 960) -- 391
	self.audio:update(safeDt) -- 392
	if not p.paused then -- 392
		local ev = self.adapter:sample(p) -- 394
		self.audio:ingestEvents(ev, p) -- 395
		self.soundscape:updateTrial(safeDt, p, self.audio, offerCount) -- 396
	end -- 396
end -- 388
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 401
	self:syncRuntimeHooks() -- 402
	local safeDt = math.min( -- 403
		0.05, -- 403
		math.max(0, dt) -- 403
	) -- 403
	if self.toastTimer > 0 then -- 403
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 405
	end -- 405
	if self.screen == "title" and self.boundPlay ~= nil then -- 405
		self.audio:stopRoomTransient() -- 408
		self.boundPlay = nil -- 409
	end -- 409
	self.audio:update(safeDt) -- 411
	self.soundscape:updateMenu(self.screen, self.audio) -- 412
	self:setVisible(true) -- 413
	self:clearAll() -- 414
	local uiScale = self:resizeInterface(w, h) -- 415
	local act = self.menus:updateAndDrawScreen( -- 416
		dt, -- 417
		self.screen, -- 418
		input, -- 419
		self.stage, -- 420
		self.bgDraw, -- 421
		self.bgGlow, -- 422
		self.backdropArt, -- 423
		self.uiArt, -- 424
		self.uiDraw, -- 425
		self.uiInkDraw, -- 426
		self.uiGlow, -- 427
		self.texts, -- 428
		w, -- 429
		h, -- 430
		uiScale, -- 431
		self.stageVp.safeUi -- 432
	) -- 432
	self:drawToast(w / uiScale) -- 434
	self:finishFrame() -- 435
	return act -- 436
end -- 401
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 440
	local offers = p:getStoryTalentOffers() -- 441
	if #offers == 0 then -- 441
		return false -- 443
	end -- 443
	if input.inputMode == "gamepad" and not input.uiPressed then -- 443
		return false -- 446
	end -- 446
	local useUiPtr = input.uiInside or input.uiPressed -- 448
	local ____useUiPtr_2 -- 449
	if useUiPtr then -- 449
		____useUiPtr_2 = input.uiInside -- 449
	else -- 449
		____useUiPtr_2 = input.inside -- 449
	end -- 449
	local inside = ____useUiPtr_2 -- 449
	if not inside then -- 449
		return false -- 451
	end -- 451
	local uiScale = math.max( -- 453
		0.25, -- 453
		math.min(w / 1280, h / 720) -- 453
	) -- 453
	local uiW = w / uiScale -- 454
	local uiH = h / uiScale -- 455
	local rawX = useUiPtr and input.uiX or input.mx -- 456
	local rawY = useUiPtr and input.uiY or input.my -- 457
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 458
	local boxes = self.hud:talentCardRects( -- 459
		uiW, -- 459
		uiH, -- 459
		#offers, -- 459
		input:isTouchMode(), -- 459
		self.stageVp.safeUi.top -- 459
	) -- 459
	local i = 0 -- 460
	do -- 460
		i = 0 -- 461
		while i < #boxes do -- 461
			if boxes[i + 1]:containsPoint(pointer) then -- 461
				return p:chooseTalent(i) -- 463
			end -- 463
			i = i + 1 -- 461
		end -- 461
	end -- 461
	return false -- 466
end -- 440
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 470
	self:syncRuntimeHooks() -- 471
	self:setVisible(true) -- 472
	if self.boundPlay ~= p then -- 472
		self:bindPlay(p, w, h) -- 474
	end -- 474
	local safeDt = math.min( -- 476
		0.05, -- 476
		math.max(0.001, dt) -- 476
	) -- 476
	if self.toastTimer > 0 then -- 476
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 478
	end -- 478
	self.audio:setPaused(p.paused) -- 480
	self.audio:setCameraRef( -- 481
		self.cam.x, -- 481
		w / math.max(0.25, self.cam.ppu) -- 481
	) -- 481
	self.audio:update(safeDt) -- 482
	local ev -- 484
	local worldDt = 0 -- 485
	local uiDt = 0 -- 486
	if not p.paused then -- 486
		ev = self.adapter:sample(p) -- 490
		self.vfx:ingest(ev, p, self.cam) -- 491
		self.audio:ingestEvents(ev, p) -- 492
		local touch = input:getTouch() -- 493
		if touch ~= nil then -- 493
			if ev.playerHit then -- 493
				touch:vibrate(0.036) -- 496
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 496
				touch:vibrate(0.024) -- 498
			elseif ev.coverDeflect then -- 498
				touch:vibrate(0.018) -- 500
			elseif ev.knockPulse then -- 500
				touch:vibrate(0.014) -- 502
			end -- 502
		end -- 502
	else -- 502
		ev = self.adapter:emptyFrame(p) -- 507
		self.narrative.wipeT = 0 -- 508
	end -- 508
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 511
	if not p.paused then -- 511
		local clampedScale = math.max( -- 513
			0, -- 513
			math.min(2, view.timeScale) -- 513
		) -- 513
		uiDt = safeDt -- 514
		worldDt = safeDt * clampedScale -- 515
	end -- 515
	local uiScale = self:resizeInterface(w, h) -- 518
	local uiW = w / uiScale -- 519
	local uiH = h / uiScale -- 520
	local ctx = { -- 522
		p = p, -- 523
		view = view, -- 524
		events = ev, -- 525
		input = input, -- 526
		cam = self.cam, -- 527
		audio = self.audio, -- 528
		assets = self.worldArt, -- 529
		backdropArt = self.backdropArt, -- 530
		worldArt = self.worldArt, -- 531
		uiArt = self.uiArt, -- 532
		texts = self.texts, -- 533
		worldDt = worldDt, -- 534
		uiDt = uiDt, -- 535
		w = w, -- 536
		h = h, -- 537
		uiW = uiW, -- 538
		uiH = uiH, -- 539
		uiScale = uiScale, -- 540
		safeUi = self.stageVp.safeUi, -- 541
		paused = p.paused -- 542
	} -- 542
	local i = 0 -- 546
	do -- 546
		i = 0 -- 547
		while i < #self.plugins do -- 547
			local pl = self.plugins[i + 1] -- 548
			if pl.update ~= nil then -- 548
				pl:update(ctx) -- 550
			end -- 550
			i = i + 1 -- 547
		end -- 547
	end -- 547
	if not p.paused then -- 547
		self.time = self.time + worldDt -- 555
		self.cam:update(worldDt, p, w, h) -- 556
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 557
		self.audio:setCameraRef( -- 558
			self.cam.x, -- 558
			w / math.max(0.25, self.cam.ppu) -- 558
		) -- 558
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 559
		self.actors:update(worldDt, p) -- 560
		self.vfx:update( -- 561
			worldDt, -- 561
			themeOf(p.room.key).ambient -- 561
		) -- 561
		self.hud:update(safeDt, p) -- 562
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 563
	else -- 563
		self.cam:update(0, p, w, h) -- 565
	end -- 565
	self:clearAll() -- 568
	local backdropHandled = false -- 571
	do -- 571
		i = 0 -- 572
		while i < #self.plugins do -- 572
			local pl = self.plugins[i + 1] -- 573
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 573
				backdropHandled = true -- 575
			end -- 575
			i = i + 1 -- 572
		end -- 572
	end -- 572
	if not backdropHandled then -- 572
		self.stage:drawBackdrop( -- 579
			self.bgDraw, -- 579
			self.bgGlow, -- 579
			self.backdropArt, -- 579
			p, -- 579
			self.cam, -- 579
			self.time -- 579
		) -- 579
	end -- 579
	if view.visualMode == "pixel" then -- 579
		self.escortWorld:drawBackdropOverlay( -- 582
			self.bgDraw, -- 582
			self.bgGlow, -- 582
			self.backdropArt, -- 582
			p, -- 582
			self.cam, -- 582
			self.time, -- 582
			self.escortTowerDraw -- 582
		) -- 582
	end -- 582
	local worldHandled = false -- 586
	do -- 586
		i = 0 -- 587
		while i < #self.plugins do -- 587
			local pl = self.plugins[i + 1] -- 588
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 588
				worldHandled = true -- 590
			end -- 590
			i = i + 1 -- 587
		end -- 587
	end -- 587
	if not worldHandled then -- 587
		self.stage:drawPlayableWorld( -- 594
			self.fgDraw, -- 594
			self.fgGlow, -- 594
			self.worldArt, -- 594
			p, -- 594
			self.cam, -- 594
			self.time, -- 594
			self.occlusion, -- 594
			worldDt -- 594
		) -- 594
	end -- 594
	local propsHandled = false -- 598
	do -- 598
		i = 0 -- 599
		while i < #self.plugins do -- 599
			local pl = self.plugins[i + 1] -- 600
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 600
				propsHandled = true -- 602
			end -- 602
			i = i + 1 -- 599
		end -- 599
	end -- 599
	if not propsHandled then -- 599
		self.props:drawAll( -- 606
			self.fgDraw, -- 606
			self.fgGlow, -- 606
			self.worldArt, -- 606
			p, -- 606
			self.cam, -- 606
			self.time, -- 606
			self.occlusion, -- 606
			worldDt -- 606
		) -- 606
	end -- 606
	if view.visualMode == "pixel" then -- 606
		self.escortWorld:drawWorldSetpieces( -- 609
			self.fgDraw, -- 609
			self.fgGlow, -- 609
			self.worldArt, -- 609
			p, -- 609
			view, -- 609
			self.cam, -- 609
			self.time -- 609
		) -- 609
	end -- 609
	local suppressAllActors = view.visualMode == "museum" -- 613
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 614
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 618
	if not suppressAllActors then -- 618
		self.actors:drawAll( -- 627
			self.fgDraw, -- 627
			self.fgGlow, -- 627
			self.worldArt, -- 627
			p, -- 627
			self.cam, -- 627
			suppressPartner -- 627
		) -- 627
	end -- 627
	do -- 627
		i = 0 -- 629
		while i < #self.plugins do -- 629
			local pl = self.plugins[i + 1] -- 630
			if pl.drawActorsOverlay ~= nil then -- 630
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 632
			end -- 632
			i = i + 1 -- 629
		end -- 629
	end -- 629
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 637
	if view.visualMode == "pixel" then -- 637
		self.stage:drawForegroundFraming( -- 641
			self.fgDraw, -- 641
			w, -- 641
			h, -- 641
			p, -- 641
			self.cam -- 641
		) -- 641
		self.escortWorld:drawForegroundFraming( -- 642
			self.fgDraw, -- 642
			self.fgGlow, -- 642
			self.worldArt, -- 642
			p, -- 642
			self.cam, -- 642
			self.time -- 642
		) -- 642
	end -- 642
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 644
	local action = {type = "none"} -- 647
	if p.paused then -- 647
		action = self.menus:updateAndDrawPause( -- 649
			safeDt, -- 650
			input, -- 651
			self.uiDraw, -- 652
			self.uiInkDraw, -- 653
			self.uiArt, -- 654
			self.uiGlow, -- 655
			self.texts, -- 656
			uiW, -- 657
			uiH, -- 658
			uiScale, -- 659
			view.assistHintsEnabled, -- 660
			function() -- 661
				self.contract:toggleAssistHints() -- 662
			end, -- 661
			self.stageVp.safeUi -- 664
		) -- 664
	else -- 664
		local cutsceneHandled = false -- 668
		do -- 668
			i = 0 -- 669
			while i < #self.plugins do -- 669
				local pl = self.plugins[i + 1] -- 670
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 670
					self.uiDraw, -- 672
					self.uiInkDraw, -- 672
					self.uiArt, -- 672
					self.uiGlow, -- 672
					ctx -- 672
				) then -- 672
					cutsceneHandled = true -- 673
				end -- 673
				i = i + 1 -- 669
			end -- 669
		end -- 669
		if not cutsceneHandled then -- 669
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 678
			self.hud:draw( -- 679
				self.uiDraw, -- 680
				self.uiInkDraw, -- 681
				self.uiArt, -- 682
				self.uiGlow, -- 683
				self.texts, -- 684
				p, -- 685
				self.cam, -- 686
				self.vfx, -- 687
				self.narrative.letterbox, -- 688
				uiScale, -- 689
				view.assistHintsEnabled, -- 690
				true, -- 691
				input.inputMode, -- 692
				input.gamepadLayout, -- 693
				self.stageVp.safeUi, -- 694
				input.retryHoldProgress, -- 695
				touchOverlayVisible -- 696
			) -- 696
			self.narrative:draw( -- 698
				self.uiDraw, -- 699
				self.uiInkDraw, -- 700
				self.uiGlow, -- 701
				self.uiArt, -- 702
				self.texts, -- 703
				p, -- 704
				uiW, -- 705
				uiH, -- 706
				view.assistHintsEnabled, -- 707
				input.inputMode, -- 708
				input.gamepadLayout, -- 709
				self.stageVp.safeUi -- 710
			) -- 710
		end -- 710
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 714
		do -- 714
			i = 0 -- 715
			while i < #self.plugins do -- 715
				local pl = self.plugins[i + 1] -- 716
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 716
					self.uiDraw, -- 718
					self.uiInkDraw, -- 718
					self.uiArt, -- 718
					self.uiGlow, -- 718
					ctx -- 718
				) then -- 718
					suppressReticle = true -- 719
				end -- 719
				i = i + 1 -- 715
			end -- 715
		end -- 715
		if not suppressReticle then -- 715
			self.hud:drawReticleOverlay( -- 723
				self.uiInkDraw, -- 724
				self.uiArt, -- 725
				self.uiGlow, -- 726
				p, -- 727
				self.cam, -- 728
				self.vfx, -- 729
				self.narrative.letterbox, -- 730
				uiScale, -- 731
				input:isTouchMode() -- 732
			) -- 732
		end -- 732
		if view.isRehearsal then -- 732
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 738
			drawSilkVeil( -- 739
				self.uiDraw, -- 739
				self.uiArt, -- 739
				"rehearsal_tag_veil", -- 739
				uiW * 0.5, -- 739
				uiH - 22 - self.stageVp.safeUi.top, -- 739
				168, -- 739
				26, -- 739
				PALETTE.inkWarm, -- 739
				0.74, -- 739
				8 -- 739
			) -- 739
			self.texts:put( -- 740
				"xs", -- 740
				badgeText, -- 740
				uiW * 0.5, -- 740
				uiH - 22 - self.stageVp.safeUi.top, -- 740
				toColor(PALETTE.amberCore), -- 740
				0.5, -- 740
				0.5, -- 740
				"Center", -- 740
				1.2, -- 740
				0.92, -- 740
				0.08 -- 740
			) -- 740
		end -- 740
	end -- 740
	self:drawToast(uiW) -- 744
	self:finishFrame() -- 745
	return action -- 746
end -- 470
return ____exports -- 470