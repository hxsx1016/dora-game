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
local ____textpool = require("Script.watch.fe.ui.textpool") -- 29
local TextPool = ____textpool.TextPool -- 29
local ____hud = require("Script.watch.fe.ui.hud") -- 30
local HudRenderer = ____hud.HudRenderer -- 30
local ____narrative = require("Script.watch.fe.ui.narrative") -- 31
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 31
local ____menus = require("Script.watch.fe.ui.menus") -- 32
local MenuRenderer = ____menus.MenuRenderer -- 32
local ____theme = require("Script.watch.fe.theme") -- 33
local PALETTE = ____theme.PALETTE -- 33
local drawSilkVeil = ____theme.drawSilkVeil -- 33
local themeOf = ____theme.themeOf -- 33
local toColor = ____theme.toColor -- 33
local ____ming_audit = require("Script.watch.fe.renderer.ming_audit") -- 34
local MingArtAuditPlugin = ____ming_audit.MingArtAuditPlugin -- 34
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 35
local GateTransitionPlugin = ____gate_transition.GateTransitionPlugin -- 35
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 36
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 36
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 37
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 37
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 38
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 38
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 39
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 39
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 40
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 40
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 41
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 41
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 42
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 42
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 43
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 43
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 44
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 44
____exports.WatchFrontend = __TS__Class() -- 46
local WatchFrontend = ____exports.WatchFrontend -- 46
WatchFrontend.name = "WatchFrontend" -- 46
function WatchFrontend.prototype.____constructor(self, parent) -- 87
	self.occlusion = __TS__New(DepthOcclusion) -- 47
	self.cam = __TS__New(CameraDirector) -- 65
	self.adapter = __TS__New(PlayAdapter) -- 66
	self.contract = __TS__New(DualRouteContract) -- 67
	self.audio = __TS__New(AudioDirector) -- 68
	self.soundscape = __TS__New(SoundscapeDirector) -- 69
	self.stage = __TS__New(StageRenderer) -- 70
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
	self.audio:attachHost(self.layerRoot) -- 92
	self.menus.onUiSound = function(____, kind) -- 93
		self:playMenuUiSound(kind) -- 94
	end -- 93
	self.menus.onAudioSettingsChanged = function(____, inp) -- 96
		self.audio:applyUserVolumes(inp.settings) -- 97
	end -- 96
	local additive = BlendFunc("SrcAlpha", "One") -- 100
	self.bgDraw = DrawNode() -- 102
	self.bgDraw.order = 10 -- 103
	self.bgDraw:addTo(self.layerRoot) -- 104
	self.bgGlow = DrawNode() -- 106
	self.bgGlow.order = 15 -- 107
	self.bgGlow.blendFunc = additive -- 108
	self.bgGlow:addTo(self.layerRoot) -- 109
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 111
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 112
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 113
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 114
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 115
	self.fgDraw = DrawNode() -- 117
	self.fgDraw.order = 30 -- 118
	self.fgDraw:addTo(self.layerRoot) -- 119
	self.fgGlow = DrawNode() -- 121
	self.fgGlow.order = 35 -- 122
	self.fgGlow.blendFunc = additive -- 123
	self.fgGlow:addTo(self.layerRoot) -- 124
	self.uiLayer = Node() -- 126
	self.uiLayer.order = 40 -- 127
	self.uiLayer:addTo(self.layerRoot) -- 128
	self.uiDraw = DrawNode() -- 130
	self.uiDraw.order = 0 -- 131
	self.uiDraw:addTo(self.uiLayer) -- 132
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 134
	self.uiInkDraw = DrawNode() -- 136
	self.uiInkDraw.order = 4 -- 137
	self.uiInkDraw:addTo(self.uiLayer) -- 138
	self.uiGlow = DrawNode() -- 140
	self.uiGlow.order = 6 -- 141
	self.uiGlow.blendFunc = additive -- 142
	self.uiGlow:addTo(self.uiLayer) -- 143
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 145
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 159
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 160
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 161
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 162
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 163
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 164
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 165
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 166
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 167
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 168
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 169
end -- 87
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 173
	local i = 0 -- 174
	do -- 174
		i = 0 -- 175
		while i < #self.plugins do -- 175
			if self.plugins[i + 1].id == plugin.id then -- 175
				self.plugins[i + 1] = plugin -- 177
				self:syncRuntimeHooks() -- 178
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 178
					plugin:onBindPlay( -- 180
						self.boundPlay, -- 180
						self.contract:peekSnapshot(self.boundPlay) -- 180
					) -- 180
				end -- 180
				return -- 182
			end -- 182
			i = i + 1 -- 175
		end -- 175
	end -- 175
	local ____self_plugins_0 = self.plugins -- 175
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 185
	self:syncRuntimeHooks() -- 186
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 186
		plugin:onBindPlay( -- 188
			self.boundPlay, -- 188
			self.contract:peekSnapshot(self.boundPlay) -- 188
		) -- 188
	end -- 188
end -- 173
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 193
	local w = 0 -- 194
	local i = 0 -- 195
	do -- 195
		i = 0 -- 196
		while i < #self.plugins do -- 196
			if self.plugins[i + 1].id ~= id then -- 196
				self.plugins[w + 1] = self.plugins[i + 1] -- 198
				w = w + 1 -- 199
			end -- 199
			i = i + 1 -- 196
		end -- 196
	end -- 196
	__TS__ArraySetLength(self.plugins, w) -- 196
	self:syncRuntimeHooks() -- 203
end -- 193
function WatchFrontend.prototype.getPlugin(self, id) -- 207
	local i = 0 -- 208
	do -- 208
		i = 0 -- 209
		while i < #self.plugins do -- 209
			if self.plugins[i + 1].id == id then -- 209
				return self.plugins[i + 1] -- 211
			end -- 211
			i = i + 1 -- 209
		end -- 209
	end -- 209
	return nil -- 214
end -- 207
function WatchFrontend.prototype.getPlugins(self) -- 217
	return self.plugins -- 218
end -- 217
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 226
	local g = _G -- 227
	local ____temp_1 -- 228
	if g.package ~= nil then -- 228
		____temp_1 = g.package.loaded -- 228
	else -- 228
		____temp_1 = nil -- 228
	end -- 228
	local loaded = ____temp_1 -- 228
	if loaded == nil then -- 228
		return -- 230
	end -- 230
	local rawFe = loaded["watch.fe"] -- 232
	if rawFe ~= nil and type(rawFe) == "table" then -- 232
		local watchFe = rawFe -- 234
		if watchFe.contract ~= self.contract then -- 234
			watchFe.contract = self.contract -- 236
			watchFe.audio = self.audio -- 237
			watchFe.soundscape = self.soundscape -- 238
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 239
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 240
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 241
		end -- 241
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 243
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 244
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 245
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 246
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 247
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 248
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 249
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 250
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 251
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 252
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 253
	end -- 253
end -- 226
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 257
	local scale = math.max( -- 258
		0.25, -- 258
		math.min(w / 1280, h / 720) -- 258
	) -- 258
	self.uiLayer.scaleX = scale -- 259
	self.uiLayer.scaleY = scale -- 260
	return scale -- 261
end -- 257
function WatchFrontend.prototype.setVisible(self, v) -- 265
	self.layerRoot.visible = v -- 266
	if not v then -- 266
		self.texts:hideAll() -- 268
	end -- 268
end -- 265
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 273
	self:syncRuntimeHooks() -- 274
	self.boundPlay = p -- 275
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 276
	self.cam:snap(p, w, h) -- 277
	self.adapter:reset(p) -- 278
	self.contract:resetForRoom(p) -- 279
	self.audio:stopRoomTransient() -- 280
	self.soundscape:resetForRoom(p) -- 281
	self.actors:reset(p) -- 282
	self.occlusion:reset() -- 283
	self.vfx:reset() -- 284
	self.hud:reset(p) -- 285
	self.narrative:onEnterRoom(p.room.key) -- 286
	if #self.plugins > 0 then -- 286
		local initView = self.contract:peekSnapshot(p) -- 289
		local i = 0 -- 290
		do -- 290
			i = 0 -- 291
			while i < #self.plugins do -- 291
				local pl = self.plugins[i + 1] -- 292
				if pl.onBindPlay ~= nil then -- 292
					pl:onBindPlay(p, initView) -- 294
				end -- 294
				i = i + 1 -- 291
			end -- 291
		end -- 291
	end -- 291
end -- 273
function WatchFrontend.prototype.clearAll(self) -- 300
	self.bgDraw:clear() -- 301
	self.bgGlow:clear() -- 302
	self.fgDraw:clear() -- 303
	self.fgGlow:clear() -- 304
	self.uiDraw:clear() -- 305
	self.uiInkDraw:clear() -- 306
	self.uiGlow:clear() -- 307
	self.backdropArt:beginFrame() -- 308
	self.dioramaBg:beginFrame() -- 309
	self.dioramaWorld:beginFrame() -- 310
	self.dioramaFg:beginFrame() -- 311
	self.worldArt:beginFrame() -- 312
	self.uiArt:beginFrame() -- 313
	self.texts:beginFrame() -- 314
end -- 300
function WatchFrontend.prototype.finishFrame(self) -- 317
	self.backdropArt:endFrame() -- 318
	self.dioramaBg:endFrame() -- 319
	self.dioramaWorld:endFrame() -- 320
	self.dioramaFg:endFrame() -- 321
	self.worldArt:endFrame() -- 322
	self.uiArt:endFrame() -- 323
	self.texts:endFrame() -- 324
end -- 317
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 328
	self.stageVp = vp -- 329
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 330
end -- 328
function WatchFrontend.prototype.showToast(self, text, duration) -- 334
	if duration == nil then -- 334
		duration = 1.8 -- 334
	end -- 334
	self.toastText = text -- 335
	self.toastTimer = duration -- 336
end -- 334
function WatchFrontend.prototype.getToastText(self) -- 339
	return self.toastTimer > 0 and self.toastText or "" -- 340
end -- 339
function WatchFrontend.prototype.drawToast(self, uiW) -- 343
	if self.toastTimer <= 0 or self.toastText == "" then -- 343
		return -- 345
	end -- 345
	local alpha = math.min(1, self.toastTimer * 2.4) -- 347
	local cx = uiW * 0.5 -- 348
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 349
	drawSilkVeil( -- 350
		self.uiDraw, -- 350
		self.uiArt, -- 350
		"fe_toast_veil", -- 350
		cx, -- 350
		cy, -- 350
		340, -- 350
		38, -- 350
		PALETTE.inkWarm, -- 350
		0.86 * alpha, -- 350
		9 -- 350
	) -- 350
	self.texts:put( -- 351
		"sm", -- 351
		self.toastText, -- 351
		cx, -- 351
		cy, -- 351
		toColor(PALETTE.amberCore), -- 351
		0.5, -- 351
		0.5, -- 351
		"Center", -- 351
		1.4, -- 351
		0.96 * alpha, -- 351
		0.08 -- 351
	) -- 351
end -- 343
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 355
	local offers = p:getStoryTalentOffers() -- 356
	if #offers == 0 then -- 356
		return {} -- 358
	end -- 358
	local uiScale = math.max( -- 360
		0.25, -- 360
		math.min(w / 1280, h / 720) -- 360
	) -- 360
	return self.hud:talentCardRects( -- 361
		w / uiScale, -- 361
		h / uiScale, -- 361
		#offers, -- 361
		touchMode, -- 361
		self.stageVp.safeUi.top -- 361
	) -- 361
end -- 355
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 364
	if kind == "hover" then -- 364
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 366
	elseif kind == "confirm" then -- 366
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 368
	elseif kind == "back" then -- 368
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 370
	elseif kind == "start" then -- 370
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 372
	elseif kind == "pauseOpen" then -- 372
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 374
	elseif kind == "pauseClose" then -- 374
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 376
	elseif kind == "toggle" then -- 376
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 378
	end -- 378
end -- 364
function WatchFrontend.prototype.resetTrialAudio(self, p) -- 383
	self.adapter:reset(p) -- 384
	self.audio:stopRoomTransient() -- 385
	self.soundscape:resetForRoom(p) -- 386
end -- 383
function WatchFrontend.prototype.syncTrialAudio(self, dt, p, offerCount) -- 390
	local safeDt = math.min( -- 391
		0.05, -- 391
		math.max(0.001, dt) -- 391
	) -- 391
	self.audio:setPaused(p.paused) -- 392
	self.audio:setCameraRef(p.player.x, 960) -- 393
	self.audio:update(safeDt) -- 394
	if not p.paused then -- 394
		local ev = self.adapter:sample(p) -- 396
		self.audio:ingestEvents(ev, p) -- 397
		self.soundscape:updateTrial(safeDt, p, self.audio, offerCount) -- 398
	end -- 398
end -- 390
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 403
	self:syncRuntimeHooks() -- 404
	local safeDt = math.min( -- 405
		0.05, -- 405
		math.max(0, dt) -- 405
	) -- 405
	if self.toastTimer > 0 then -- 405
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 407
	end -- 407
	if self.screen == "title" and self.boundPlay ~= nil then -- 407
		self.audio:stopRoomTransient() -- 410
		self.boundPlay = nil -- 411
	end -- 411
	self.audio:update(safeDt) -- 413
	self.soundscape:updateMenu(self.screen, self.audio) -- 414
	self:setVisible(true) -- 415
	self:clearAll() -- 416
	local uiScale = self:resizeInterface(w, h) -- 417
	local act = self.menus:updateAndDrawScreen( -- 418
		dt, -- 419
		self.screen, -- 420
		input, -- 421
		self.stage, -- 422
		self.bgDraw, -- 423
		self.bgGlow, -- 424
		self.backdropArt, -- 425
		self.uiArt, -- 426
		self.uiDraw, -- 427
		self.uiInkDraw, -- 428
		self.uiGlow, -- 429
		self.texts, -- 430
		w, -- 431
		h, -- 432
		uiScale, -- 433
		self.stageVp.safeUi -- 434
	) -- 434
	self:drawToast(w / uiScale) -- 436
	self:finishFrame() -- 437
	return act -- 438
end -- 403
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 442
	local offers = p:getStoryTalentOffers() -- 443
	if #offers == 0 then -- 443
		return false -- 445
	end -- 445
	if input.inputMode == "gamepad" and not input.uiPressed then -- 445
		return false -- 448
	end -- 448
	local useUiPtr = input.uiInside or input.uiPressed -- 450
	local ____useUiPtr_2 -- 451
	if useUiPtr then -- 451
		____useUiPtr_2 = input.uiInside -- 451
	else -- 451
		____useUiPtr_2 = input.inside -- 451
	end -- 451
	local inside = ____useUiPtr_2 -- 451
	if not inside then -- 451
		return false -- 453
	end -- 453
	local uiScale = math.max( -- 455
		0.25, -- 455
		math.min(w / 1280, h / 720) -- 455
	) -- 455
	local uiW = w / uiScale -- 456
	local uiH = h / uiScale -- 457
	local rawX = useUiPtr and input.uiX or input.mx -- 458
	local rawY = useUiPtr and input.uiY or input.my -- 459
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 460
	local boxes = self.hud:talentCardRects( -- 461
		uiW, -- 461
		uiH, -- 461
		#offers, -- 461
		input:isTouchMode(), -- 461
		self.stageVp.safeUi.top -- 461
	) -- 461
	local i = 0 -- 462
	do -- 462
		i = 0 -- 463
		while i < #boxes do -- 463
			if boxes[i + 1]:containsPoint(pointer) then -- 463
				return p:chooseTalent(i) -- 465
			end -- 465
			i = i + 1 -- 463
		end -- 463
	end -- 463
	return false -- 468
end -- 442
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 472
	self:syncRuntimeHooks() -- 473
	self:setVisible(true) -- 474
	if self.boundPlay ~= p then -- 474
		self:bindPlay(p, w, h) -- 476
	end -- 476
	local safeDt = math.min( -- 478
		0.05, -- 478
		math.max(0.001, dt) -- 478
	) -- 478
	if self.toastTimer > 0 then -- 478
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 480
	end -- 480
	self.audio:setPaused(p.paused) -- 482
	self.audio:setCameraRef( -- 483
		self.cam.x, -- 483
		w / math.max(0.25, self.cam.ppu) -- 483
	) -- 483
	self.audio:update(safeDt) -- 484
	local ev -- 486
	local worldDt = 0 -- 487
	local uiDt = 0 -- 488
	if not p.paused then -- 488
		ev = self.adapter:sample(p) -- 492
		self.vfx:ingest(ev, p, self.cam) -- 493
		self.audio:ingestEvents(ev, p) -- 494
		local touch = input:getTouch() -- 495
		if touch ~= nil then -- 495
			if ev.playerHit then -- 495
				touch:vibrate(0.036) -- 498
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 498
				touch:vibrate(0.024) -- 500
			elseif ev.coverDeflect then -- 500
				touch:vibrate(0.018) -- 502
			elseif ev.knockPulse then -- 502
				touch:vibrate(0.014) -- 504
			end -- 504
		end -- 504
	else -- 504
		ev = self.adapter:emptyFrame(p) -- 509
		self.narrative.wipeT = 0 -- 510
	end -- 510
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 513
	if not p.paused then -- 513
		local clampedScale = math.max( -- 515
			0, -- 515
			math.min(2, view.timeScale) -- 515
		) -- 515
		uiDt = safeDt -- 516
		worldDt = safeDt * clampedScale -- 517
	end -- 517
	local uiScale = self:resizeInterface(w, h) -- 520
	local uiW = w / uiScale -- 521
	local uiH = h / uiScale -- 522
	local ctx = { -- 524
		p = p, -- 525
		view = view, -- 526
		events = ev, -- 527
		input = input, -- 528
		cam = self.cam, -- 529
		audio = self.audio, -- 530
		assets = self.worldArt, -- 531
		backdropArt = self.backdropArt, -- 532
		worldArt = self.worldArt, -- 533
		uiArt = self.uiArt, -- 534
		dioramaBg = self.dioramaBg, -- 535
		dioramaWorld = self.dioramaWorld, -- 536
		dioramaFg = self.dioramaFg, -- 537
		texts = self.texts, -- 538
		worldDt = worldDt, -- 539
		uiDt = uiDt, -- 540
		w = w, -- 541
		h = h, -- 542
		uiW = uiW, -- 543
		uiH = uiH, -- 544
		uiScale = uiScale, -- 545
		safeUi = self.stageVp.safeUi, -- 546
		paused = p.paused -- 547
	} -- 547
	local i = 0 -- 551
	do -- 551
		i = 0 -- 552
		while i < #self.plugins do -- 552
			local pl = self.plugins[i + 1] -- 553
			if pl.update ~= nil then -- 553
				pl:update(ctx) -- 555
			end -- 555
			i = i + 1 -- 552
		end -- 552
	end -- 552
	if not p.paused then -- 552
		self.time = self.time + worldDt -- 560
		self.cam:update(worldDt, p, w, h) -- 561
		self.audio:setCameraRef( -- 562
			self.cam.x, -- 562
			w / math.max(0.25, self.cam.ppu) -- 562
		) -- 562
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 563
		self.actors:update(worldDt, p) -- 564
		self.vfx:update( -- 565
			worldDt, -- 565
			themeOf(p.room.key).ambient -- 565
		) -- 565
		self.hud:update(safeDt, p) -- 566
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 567
	else -- 567
		self.cam:update(0, p, w, h) -- 569
	end -- 569
	self:clearAll() -- 572
	local backdropHandled = false -- 575
	do -- 575
		i = 0 -- 576
		while i < #self.plugins do -- 576
			local pl = self.plugins[i + 1] -- 577
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 577
				backdropHandled = true -- 579
			end -- 579
			i = i + 1 -- 576
		end -- 576
	end -- 576
	if not backdropHandled then -- 576
		self.stage:drawBackdrop( -- 583
			self.bgDraw, -- 583
			self.bgGlow, -- 583
			self.backdropArt, -- 583
			p, -- 583
			self.cam, -- 583
			self.time -- 583
		) -- 583
	end -- 583
	local worldHandled = false -- 587
	do -- 587
		i = 0 -- 588
		while i < #self.plugins do -- 588
			local pl = self.plugins[i + 1] -- 589
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 589
				worldHandled = true -- 591
			end -- 591
			i = i + 1 -- 588
		end -- 588
	end -- 588
	if not worldHandled then -- 588
		self.stage:drawPlayableWorld( -- 595
			self.fgDraw, -- 595
			self.fgGlow, -- 595
			self.worldArt, -- 595
			p, -- 595
			self.cam, -- 595
			self.time, -- 595
			self.occlusion, -- 595
			worldDt -- 595
		) -- 595
	end -- 595
	local propsHandled = false -- 599
	do -- 599
		i = 0 -- 600
		while i < #self.plugins do -- 600
			local pl = self.plugins[i + 1] -- 601
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 601
				propsHandled = true -- 603
			end -- 603
			i = i + 1 -- 600
		end -- 600
	end -- 600
	if not propsHandled then -- 600
		self.props:drawAll( -- 607
			self.fgDraw, -- 607
			self.fgGlow, -- 607
			self.worldArt, -- 607
			p, -- 607
			self.cam, -- 607
			self.time, -- 607
			self.occlusion, -- 607
			worldDt -- 607
		) -- 607
	end -- 607
	local suppressAllActors = view.visualMode == "museum" -- 611
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 612
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 616
	if not suppressAllActors then -- 616
		self.actors:drawAll( -- 625
			self.fgDraw, -- 625
			self.fgGlow, -- 625
			self.worldArt, -- 625
			p, -- 625
			self.cam, -- 625
			suppressPartner -- 625
		) -- 625
	end -- 625
	do -- 625
		i = 0 -- 627
		while i < #self.plugins do -- 627
			local pl = self.plugins[i + 1] -- 628
			if pl.drawActorsOverlay ~= nil then -- 628
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 630
			end -- 630
			i = i + 1 -- 627
		end -- 627
	end -- 627
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 635
	if view.visualMode == "pixel" then -- 635
		self.stage:drawForegroundFraming( -- 639
			self.fgDraw, -- 639
			w, -- 639
			h, -- 639
			p, -- 639
			self.cam -- 639
		) -- 639
	end -- 639
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 641
	local action = {type = "none"} -- 644
	if p.paused then -- 644
		action = self.menus:updateAndDrawPause( -- 646
			safeDt, -- 647
			input, -- 648
			self.uiDraw, -- 649
			self.uiInkDraw, -- 650
			self.uiArt, -- 651
			self.uiGlow, -- 652
			self.texts, -- 653
			uiW, -- 654
			uiH, -- 655
			uiScale, -- 656
			view.assistHintsEnabled, -- 657
			function() -- 658
				self.contract:toggleAssistHints() -- 659
			end, -- 658
			self.stageVp.safeUi -- 661
		) -- 661
	else -- 661
		local cutsceneHandled = false -- 665
		do -- 665
			i = 0 -- 666
			while i < #self.plugins do -- 666
				local pl = self.plugins[i + 1] -- 667
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 667
					self.uiDraw, -- 669
					self.uiInkDraw, -- 669
					self.uiArt, -- 669
					self.uiGlow, -- 669
					ctx -- 669
				) then -- 669
					cutsceneHandled = true -- 670
				end -- 670
				i = i + 1 -- 666
			end -- 666
		end -- 666
		if not cutsceneHandled then -- 666
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 675
			self.hud:draw( -- 676
				self.uiDraw, -- 677
				self.uiInkDraw, -- 678
				self.uiArt, -- 679
				self.uiGlow, -- 680
				self.texts, -- 681
				p, -- 682
				self.cam, -- 683
				self.vfx, -- 684
				self.narrative.letterbox, -- 685
				uiScale, -- 686
				view.assistHintsEnabled, -- 687
				true, -- 688
				input.inputMode, -- 689
				input.gamepadLayout, -- 690
				self.stageVp.safeUi, -- 691
				input.retryHoldProgress, -- 692
				touchOverlayVisible -- 693
			) -- 693
			self.narrative:draw( -- 695
				self.uiDraw, -- 696
				self.uiInkDraw, -- 697
				self.uiGlow, -- 698
				self.uiArt, -- 699
				self.texts, -- 700
				p, -- 701
				uiW, -- 702
				uiH, -- 703
				view.assistHintsEnabled, -- 704
				input.inputMode, -- 705
				input.gamepadLayout, -- 706
				self.stageVp.safeUi -- 707
			) -- 707
		end -- 707
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 711
		do -- 711
			i = 0 -- 712
			while i < #self.plugins do -- 712
				local pl = self.plugins[i + 1] -- 713
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 713
					self.uiDraw, -- 715
					self.uiInkDraw, -- 715
					self.uiArt, -- 715
					self.uiGlow, -- 715
					ctx -- 715
				) then -- 715
					suppressReticle = true -- 716
				end -- 716
				i = i + 1 -- 712
			end -- 712
		end -- 712
		if not suppressReticle then -- 712
			self.hud:drawReticleOverlay( -- 720
				self.uiInkDraw, -- 721
				self.uiArt, -- 722
				self.uiGlow, -- 723
				p, -- 724
				self.cam, -- 725
				self.vfx, -- 726
				self.narrative.letterbox, -- 727
				uiScale, -- 728
				input:isTouchMode() -- 729
			) -- 729
		end -- 729
		if view.isRehearsal then -- 729
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 735
			drawSilkVeil( -- 736
				self.uiDraw, -- 736
				self.uiArt, -- 736
				"rehearsal_tag_veil", -- 736
				uiW * 0.5, -- 736
				uiH - 22 - self.stageVp.safeUi.top, -- 736
				168, -- 736
				26, -- 736
				PALETTE.inkWarm, -- 736
				0.74, -- 736
				8 -- 736
			) -- 736
			self.texts:put( -- 737
				"xs", -- 737
				badgeText, -- 737
				uiW * 0.5, -- 737
				uiH - 22 - self.stageVp.safeUi.top, -- 737
				toColor(PALETTE.amberCore), -- 737
				0.5, -- 737
				0.5, -- 737
				"Center", -- 737
				1.2, -- 737
				0.92, -- 737
				0.08 -- 737
			) -- 737
		end -- 737
	end -- 737
	self:drawToast(uiW) -- 741
	self:finishFrame() -- 742
	return action -- 743
end -- 472
return ____exports -- 472