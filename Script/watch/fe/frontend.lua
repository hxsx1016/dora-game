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
function WatchFrontend.prototype.____constructor(self, parent) -- 86
	self.occlusion = __TS__New(DepthOcclusion) -- 48
	self.cam = __TS__New(CameraDirector) -- 63
	self.adapter = __TS__New(PlayAdapter) -- 64
	self.contract = __TS__New(DualRouteContract) -- 65
	self.audio = __TS__New(AudioDirector) -- 66
	self.soundscape = __TS__New(SoundscapeDirector) -- 67
	self.stage = __TS__New(StageRenderer) -- 68
	self.escortWorld = __TS__New(EscortWorldRenderer) -- 69
	self.props = __TS__New(PropsRenderer) -- 70
	self.actors = __TS__New(ActorsRenderer) -- 71
	self.vfx = __TS__New(VfxSystem) -- 72
	self.hud = __TS__New(HudRenderer) -- 73
	self.narrative = __TS__New(NarrativeRenderer) -- 74
	self.menus = __TS__New(MenuRenderer) -- 75
	self.plugins = {} -- 77
	self.screen = "title" -- 79
	self.time = 0 -- 80
	self.stageVp = computeStageViewport(1280, 720) -- 82
	self.toastText = "" -- 83
	self.toastTimer = 0 -- 84
	self.layerRoot = Node() -- 87
	self.layerRoot.order = 5 -- 88
	self.layerRoot:addTo(parent) -- 89
	ensureSecondHalfAssetsRegistered() -- 90
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
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 112
	self.fgDraw = DrawNode() -- 114
	self.fgDraw.order = 30 -- 115
	self.fgDraw:addTo(self.layerRoot) -- 116
	self.fgGlow = DrawNode() -- 118
	self.fgGlow.order = 35 -- 119
	self.fgGlow.blendFunc = additive -- 120
	self.fgGlow:addTo(self.layerRoot) -- 121
	self.uiLayer = Node() -- 123
	self.uiLayer.order = 40 -- 124
	self.uiLayer:addTo(self.layerRoot) -- 125
	self.uiDraw = DrawNode() -- 127
	self.uiDraw.order = 0 -- 128
	self.uiDraw:addTo(self.uiLayer) -- 129
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 131
	self.uiInkDraw = DrawNode() -- 133
	self.uiInkDraw.order = 4 -- 134
	self.uiInkDraw:addTo(self.uiLayer) -- 135
	self.uiGlow = DrawNode() -- 137
	self.uiGlow.order = 6 -- 138
	self.uiGlow.blendFunc = additive -- 139
	self.uiGlow:addTo(self.uiLayer) -- 140
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 142
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 156
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 157
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 158
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 159
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 160
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 161
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 162
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 163
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 164
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 165
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 166
end -- 86
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 170
	local i = 0 -- 171
	do -- 171
		i = 0 -- 172
		while i < #self.plugins do -- 172
			if self.plugins[i + 1].id == plugin.id then -- 173
				self.plugins[i + 1] = plugin -- 174
				self:syncRuntimeHooks() -- 175
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 176
					plugin:onBindPlay( -- 177
						self.boundPlay, -- 177
						self.contract:peekSnapshot(self.boundPlay) -- 177
					) -- 177
				end -- 177
				return -- 179
			end -- 179
			i = i + 1 -- 172
		end -- 172
	end -- 172
	local ____self_plugins_0 = self.plugins -- 182
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 182
	self:syncRuntimeHooks() -- 183
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 184
		plugin:onBindPlay( -- 185
			self.boundPlay, -- 185
			self.contract:peekSnapshot(self.boundPlay) -- 185
		) -- 185
	end -- 185
end -- 170
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 190
	local w = 0 -- 191
	local i = 0 -- 192
	do -- 192
		i = 0 -- 193
		while i < #self.plugins do -- 193
			if self.plugins[i + 1].id ~= id then -- 194
				self.plugins[w + 1] = self.plugins[i + 1] -- 195
				w = w + 1 -- 196
			end -- 196
			i = i + 1 -- 193
		end -- 193
	end -- 193
	__TS__ArraySetLength(self.plugins, w) -- 199
	self:syncRuntimeHooks() -- 200
end -- 190
function WatchFrontend.prototype.getPlugin(self, id) -- 204
	local i = 0 -- 205
	do -- 205
		i = 0 -- 206
		while i < #self.plugins do -- 206
			if self.plugins[i + 1].id == id then -- 207
				return self.plugins[i + 1] -- 208
			end -- 208
			i = i + 1 -- 206
		end -- 206
	end -- 206
	return nil -- 211
end -- 204
function WatchFrontend.prototype.getPlugins(self) -- 214
	return self.plugins -- 215
end -- 214
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 223
	local g = _G -- 224
	local ____temp_1 -- 225
	if g.package ~= nil then -- 225
		____temp_1 = g.package.loaded -- 225
	else -- 225
		____temp_1 = nil -- 225
	end -- 225
	local loaded = ____temp_1 -- 225
	if loaded == nil then -- 226
		return -- 227
	end -- 227
	local rawFe = loaded["watch.fe"] -- 229
	if rawFe ~= nil and type(rawFe) == "table" then -- 230
		local watchFe = rawFe -- 231
		if watchFe.contract ~= self.contract then -- 232
			watchFe.contract = self.contract -- 233
			watchFe.audio = self.audio -- 234
			watchFe.soundscape = self.soundscape -- 235
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 236
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 237
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 238
		end -- 238
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 240
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 241
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 242
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 243
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 244
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 245
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 246
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 247
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 248
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 249
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 250
	end -- 250
end -- 223
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 254
	local scale = math.max( -- 255
		0.25, -- 255
		math.min(w / 1280, h / 720) -- 255
	) -- 255
	self.uiLayer.scaleX = scale -- 256
	self.uiLayer.scaleY = scale -- 257
	return scale -- 258
end -- 254
function WatchFrontend.prototype.setVisible(self, v) -- 262
	self.layerRoot.visible = v -- 263
	if not v then -- 264
		self.texts:hideAll() -- 265
	end -- 265
end -- 262
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 270
	self:syncRuntimeHooks() -- 271
	self.boundPlay = p -- 272
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 273
	self.cam:snap(p, w, h) -- 274
	self.adapter:reset(p) -- 275
	self.contract:resetForRoom(p) -- 276
	self.audio:stopRoomTransient() -- 277
	self.soundscape:resetForRoom(p) -- 278
	self.actors:reset(p) -- 279
	self.occlusion:reset() -- 280
	self.vfx:reset() -- 281
	self.hud:reset(p) -- 282
	self.narrative:onEnterRoom(p.room.key) -- 283
	if #self.plugins > 0 then -- 285
		local initView = self.contract:peekSnapshot(p) -- 286
		local i = 0 -- 287
		do -- 287
			i = 0 -- 288
			while i < #self.plugins do -- 288
				local pl = self.plugins[i + 1] -- 289
				if pl.onBindPlay ~= nil then -- 290
					pl:onBindPlay(p, initView) -- 291
				end -- 291
				i = i + 1 -- 288
			end -- 288
		end -- 288
	end -- 288
end -- 270
function WatchFrontend.prototype.clearAll(self) -- 297
	self.bgDraw:clear() -- 298
	self.bgGlow:clear() -- 299
	self.fgDraw:clear() -- 300
	self.fgGlow:clear() -- 301
	self.uiDraw:clear() -- 302
	self.uiInkDraw:clear() -- 303
	self.uiGlow:clear() -- 304
	self.backdropArt:beginFrame() -- 305
	self.worldArt:beginFrame() -- 306
	self.uiArt:beginFrame() -- 307
	self.texts:beginFrame() -- 308
end -- 297
function WatchFrontend.prototype.finishFrame(self) -- 311
	self.backdropArt:endFrame() -- 312
	self.worldArt:endFrame() -- 313
	self.uiArt:endFrame() -- 314
	self.texts:endFrame() -- 315
end -- 311
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 319
	self.stageVp = vp -- 320
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 321
end -- 319
function WatchFrontend.prototype.showToast(self, text, duration) -- 325
	if duration == nil then -- 325
		duration = 1.8 -- 325
	end -- 325
	self.toastText = text -- 326
	self.toastTimer = duration -- 327
end -- 325
function WatchFrontend.prototype.getToastText(self) -- 330
	return self.toastTimer > 0 and self.toastText or "" -- 331
end -- 330
function WatchFrontend.prototype.drawToast(self, uiW) -- 334
	if self.toastTimer <= 0 or self.toastText == "" then -- 335
		return -- 336
	end -- 336
	local alpha = math.min(1, self.toastTimer * 2.4) -- 338
	local cx = uiW * 0.5 -- 339
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 340
	drawSilkVeil( -- 341
		self.uiDraw, -- 341
		self.uiArt, -- 341
		"fe_toast_veil", -- 341
		cx, -- 341
		cy, -- 341
		340, -- 341
		38, -- 341
		PALETTE.inkWarm, -- 341
		0.86 * alpha, -- 341
		9 -- 341
	) -- 341
	self.texts:put( -- 342
		"sm", -- 342
		self.toastText, -- 342
		cx, -- 342
		cy, -- 342
		toColor(PALETTE.amberCore), -- 342
		0.5, -- 342
		0.5, -- 342
		"Center", -- 342
		1.4, -- 342
		0.96 * alpha, -- 342
		0.08 -- 342
	) -- 342
end -- 334
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 346
	local offers = p:getStoryTalentOffers() -- 347
	if #offers == 0 then -- 348
		return {} -- 349
	end -- 349
	local uiScale = math.max( -- 351
		0.25, -- 351
		math.min(w / 1280, h / 720) -- 351
	) -- 351
	return self.hud:talentCardRects( -- 352
		w / uiScale, -- 352
		h / uiScale, -- 352
		#offers, -- 352
		touchMode, -- 352
		self.stageVp.safeUi.top -- 352
	) -- 352
end -- 346
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 355
	if kind == "hover" then -- 356
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 357
	elseif kind == "confirm" then -- 358
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 359
	elseif kind == "back" then -- 360
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 361
	elseif kind == "start" then -- 362
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 363
	elseif kind == "pauseOpen" then -- 364
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 365
	elseif kind == "pauseClose" then -- 366
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 367
	elseif kind == "toggle" then -- 368
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 369
	end -- 369
end -- 355
function WatchFrontend.prototype.resetTrialAudio(self, p) -- 374
	self.adapter:reset(p) -- 375
	self.audio:stopRoomTransient() -- 376
	self.soundscape:resetForRoom(p) -- 377
end -- 374
function WatchFrontend.prototype.syncTrialAudio(self, dt, p, offerCount) -- 381
	local safeDt = math.min( -- 382
		0.05, -- 382
		math.max(0.001, dt) -- 382
	) -- 382
	self.audio:setPaused(p.paused) -- 383
	self.audio:setCameraRef(p.player.x, 960) -- 384
	self.audio:update(safeDt) -- 385
	if not p.paused then -- 386
		local ev = self.adapter:sample(p) -- 387
		self.audio:ingestEvents(ev, p) -- 388
		self.soundscape:updateTrial(safeDt, p, self.audio, offerCount) -- 389
	end -- 389
end -- 381
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 394
	self:syncRuntimeHooks() -- 395
	local safeDt = math.min( -- 396
		0.05, -- 396
		math.max(0, dt) -- 396
	) -- 396
	if self.toastTimer > 0 then -- 397
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 398
	end -- 398
	if self.screen == "title" and self.boundPlay ~= nil then -- 400
		self.audio:stopRoomTransient() -- 401
		self.boundPlay = nil -- 402
	end -- 402
	self.audio:update(safeDt) -- 404
	self.soundscape:updateMenu(self.screen, self.audio) -- 405
	self:setVisible(true) -- 406
	self:clearAll() -- 407
	local uiScale = self:resizeInterface(w, h) -- 408
	local act = self.menus:updateAndDrawScreen( -- 409
		dt, -- 410
		self.screen, -- 411
		input, -- 412
		self.stage, -- 413
		self.bgDraw, -- 414
		self.bgGlow, -- 415
		self.backdropArt, -- 416
		self.uiArt, -- 417
		self.uiDraw, -- 418
		self.uiInkDraw, -- 419
		self.uiGlow, -- 420
		self.texts, -- 421
		w, -- 422
		h, -- 423
		uiScale, -- 424
		self.stageVp.safeUi -- 425
	) -- 425
	self:drawToast(w / uiScale) -- 427
	self:finishFrame() -- 428
	return act -- 429
end -- 394
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 433
	local offers = p:getStoryTalentOffers() -- 434
	if #offers == 0 then -- 435
		return false -- 436
	end -- 436
	if input.inputMode == "gamepad" and not input.uiPressed then -- 438
		return false -- 439
	end -- 439
	local useUiPtr = input.uiInside or input.uiPressed -- 441
	local ____useUiPtr_2 -- 442
	if useUiPtr then -- 442
		____useUiPtr_2 = input.uiInside -- 442
	else -- 442
		____useUiPtr_2 = input.inside -- 442
	end -- 442
	local inside = ____useUiPtr_2 -- 442
	if not inside then -- 443
		return false -- 444
	end -- 444
	local uiScale = math.max( -- 446
		0.25, -- 446
		math.min(w / 1280, h / 720) -- 446
	) -- 446
	local uiW = w / uiScale -- 447
	local uiH = h / uiScale -- 448
	local rawX = useUiPtr and input.uiX or input.mx -- 449
	local rawY = useUiPtr and input.uiY or input.my -- 450
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 451
	local boxes = self.hud:talentCardRects( -- 452
		uiW, -- 452
		uiH, -- 452
		#offers, -- 452
		input:isTouchMode(), -- 452
		self.stageVp.safeUi.top -- 452
	) -- 452
	local i = 0 -- 453
	do -- 453
		i = 0 -- 454
		while i < #boxes do -- 454
			if boxes[i + 1]:containsPoint(pointer) then -- 455
				return p:chooseTalent(i) -- 456
			end -- 456
			i = i + 1 -- 454
		end -- 454
	end -- 454
	return false -- 459
end -- 433
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 463
	self:syncRuntimeHooks() -- 464
	self:setVisible(true) -- 465
	if self.boundPlay ~= p then -- 466
		self:bindPlay(p, w, h) -- 467
	end -- 467
	local safeDt = math.min( -- 469
		0.05, -- 469
		math.max(0.001, dt) -- 469
	) -- 469
	if self.toastTimer > 0 then -- 470
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 471
	end -- 471
	self.audio:setPaused(p.paused) -- 473
	self.audio:setCameraRef( -- 474
		self.cam.x, -- 474
		w / math.max(0.25, self.cam.ppu) -- 474
	) -- 474
	self.audio:update(safeDt) -- 475
	local ev -- 477
	local worldDt = 0 -- 478
	local uiDt = 0 -- 479
	if not p.paused then -- 481
		ev = self.adapter:sample(p) -- 483
		self.vfx:ingest(ev, p, self.cam) -- 484
		self.audio:ingestEvents(ev, p) -- 485
		local touch = input:getTouch() -- 486
		if touch ~= nil then -- 487
			if ev.playerHit then -- 488
				touch:vibrate(0.036) -- 489
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 490
				touch:vibrate(0.024) -- 491
			elseif ev.coverDeflect then -- 492
				touch:vibrate(0.018) -- 493
			elseif ev.knockPulse then -- 494
				touch:vibrate(0.014) -- 495
			end -- 495
		end -- 495
	else -- 495
		ev = self.adapter:emptyFrame(p) -- 500
		self.narrative.wipeT = 0 -- 501
	end -- 501
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 504
	if not p.paused then -- 505
		local clampedScale = math.max( -- 506
			0, -- 506
			math.min(2, view.timeScale) -- 506
		) -- 506
		uiDt = safeDt -- 507
		worldDt = safeDt * clampedScale -- 508
	end -- 508
	local uiScale = self:resizeInterface(w, h) -- 511
	local uiW = w / uiScale -- 512
	local uiH = h / uiScale -- 513
	local ctx = { -- 515
		p = p, -- 516
		view = view, -- 517
		events = ev, -- 518
		input = input, -- 519
		cam = self.cam, -- 520
		audio = self.audio, -- 521
		assets = self.worldArt, -- 522
		backdropArt = self.backdropArt, -- 523
		worldArt = self.worldArt, -- 524
		uiArt = self.uiArt, -- 525
		texts = self.texts, -- 526
		worldDt = worldDt, -- 527
		uiDt = uiDt, -- 528
		w = w, -- 529
		h = h, -- 530
		uiW = uiW, -- 531
		uiH = uiH, -- 532
		uiScale = uiScale, -- 533
		safeUi = self.stageVp.safeUi, -- 534
		paused = p.paused -- 535
	} -- 535
	local i = 0 -- 539
	do -- 539
		i = 0 -- 540
		while i < #self.plugins do -- 540
			local pl = self.plugins[i + 1] -- 541
			if pl.update ~= nil then -- 542
				pl:update(ctx) -- 543
			end -- 543
			i = i + 1 -- 540
		end -- 540
	end -- 540
	if not p.paused then -- 547
		self.time = self.time + worldDt -- 548
		self.cam:update(worldDt, p, w, h) -- 549
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 550
		self.audio:setCameraRef( -- 551
			self.cam.x, -- 551
			w / math.max(0.25, self.cam.ppu) -- 551
		) -- 551
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 552
		self.actors:update(worldDt, p) -- 553
		self.vfx:update( -- 554
			worldDt, -- 554
			themeOf(p.room.key).ambient -- 554
		) -- 554
		self.hud:update(safeDt, p) -- 555
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 556
	else -- 556
		self.cam:update(0, p, w, h) -- 558
	end -- 558
	self:clearAll() -- 561
	local backdropHandled = false -- 564
	do -- 564
		i = 0 -- 565
		while i < #self.plugins do -- 565
			local pl = self.plugins[i + 1] -- 566
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 567
				backdropHandled = true -- 568
			end -- 568
			i = i + 1 -- 565
		end -- 565
	end -- 565
	if not backdropHandled then -- 571
		self.stage:drawBackdrop( -- 572
			self.bgDraw, -- 572
			self.bgGlow, -- 572
			self.backdropArt, -- 572
			p, -- 572
			self.cam, -- 572
			self.time -- 572
		) -- 572
	end -- 572
	if view.visualMode == "pixel" then -- 574
		self.escortWorld:drawBackdropOverlay( -- 575
			self.bgDraw, -- 575
			self.bgGlow, -- 575
			self.backdropArt, -- 575
			p, -- 575
			self.cam, -- 575
			self.time -- 575
		) -- 575
	end -- 575
	local worldHandled = false -- 579
	do -- 579
		i = 0 -- 580
		while i < #self.plugins do -- 580
			local pl = self.plugins[i + 1] -- 581
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 582
				worldHandled = true -- 583
			end -- 583
			i = i + 1 -- 580
		end -- 580
	end -- 580
	if not worldHandled then -- 586
		self.stage:drawPlayableWorld( -- 587
			self.fgDraw, -- 587
			self.fgGlow, -- 587
			self.worldArt, -- 587
			p, -- 587
			self.cam, -- 587
			self.time, -- 587
			self.occlusion, -- 587
			worldDt -- 587
		) -- 587
	end -- 587
	local propsHandled = false -- 591
	do -- 591
		i = 0 -- 592
		while i < #self.plugins do -- 592
			local pl = self.plugins[i + 1] -- 593
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 594
				propsHandled = true -- 595
			end -- 595
			i = i + 1 -- 592
		end -- 592
	end -- 592
	if not propsHandled then -- 598
		self.props:drawAll( -- 599
			self.fgDraw, -- 599
			self.fgGlow, -- 599
			self.worldArt, -- 599
			p, -- 599
			self.cam, -- 599
			self.time, -- 599
			self.occlusion, -- 599
			worldDt -- 599
		) -- 599
	end -- 599
	if view.visualMode == "pixel" then -- 601
		self.escortWorld:drawWorldSetpieces( -- 602
			self.fgDraw, -- 602
			self.fgGlow, -- 602
			self.worldArt, -- 602
			p, -- 602
			view, -- 602
			self.cam, -- 602
			self.time -- 602
		) -- 602
	end -- 602
	local suppressAllActors = view.visualMode == "museum" -- 606
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 607
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 611
	if not suppressAllActors then -- 619
		self.actors:drawAll( -- 620
			self.fgDraw, -- 620
			self.fgGlow, -- 620
			self.worldArt, -- 620
			p, -- 620
			self.cam, -- 620
			suppressPartner -- 620
		) -- 620
	end -- 620
	do -- 620
		i = 0 -- 622
		while i < #self.plugins do -- 622
			local pl = self.plugins[i + 1] -- 623
			if pl.drawActorsOverlay ~= nil then -- 624
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 625
			end -- 625
			i = i + 1 -- 622
		end -- 622
	end -- 622
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 630
	if view.visualMode == "pixel" then -- 633
		self.stage:drawForegroundFraming( -- 634
			self.fgDraw, -- 634
			w, -- 634
			h, -- 634
			p, -- 634
			self.cam -- 634
		) -- 634
		self.escortWorld:drawForegroundFraming( -- 635
			self.fgDraw, -- 635
			self.fgGlow, -- 635
			self.worldArt, -- 635
			p, -- 635
			self.cam, -- 635
			self.time -- 635
		) -- 635
	end -- 635
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 637
	local action = {type = "none"} -- 640
	if p.paused then -- 641
		action = self.menus:updateAndDrawPause( -- 642
			safeDt, -- 643
			input, -- 644
			self.uiDraw, -- 645
			self.uiInkDraw, -- 646
			self.uiArt, -- 647
			self.uiGlow, -- 648
			self.texts, -- 649
			uiW, -- 650
			uiH, -- 651
			uiScale, -- 652
			view.assistHintsEnabled, -- 653
			function() -- 654
				self.contract:toggleAssistHints() -- 655
			end, -- 654
			self.stageVp.safeUi -- 657
		) -- 657
	else -- 657
		local cutsceneHandled = false -- 661
		do -- 661
			i = 0 -- 662
			while i < #self.plugins do -- 662
				local pl = self.plugins[i + 1] -- 663
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 664
					self.uiDraw, -- 665
					self.uiInkDraw, -- 665
					self.uiArt, -- 665
					self.uiGlow, -- 665
					ctx -- 665
				) then -- 665
					cutsceneHandled = true -- 666
				end -- 666
				i = i + 1 -- 662
			end -- 662
		end -- 662
		if not cutsceneHandled then -- 670
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 671
			self.hud:draw( -- 672
				self.uiDraw, -- 673
				self.uiInkDraw, -- 674
				self.uiArt, -- 675
				self.uiGlow, -- 676
				self.texts, -- 677
				p, -- 678
				self.cam, -- 679
				self.vfx, -- 680
				self.narrative.letterbox, -- 681
				uiScale, -- 682
				view.assistHintsEnabled, -- 683
				true, -- 684
				input.inputMode, -- 685
				input.gamepadLayout, -- 686
				self.stageVp.safeUi, -- 687
				input.retryHoldProgress, -- 688
				touchOverlayVisible -- 689
			) -- 689
			self.narrative:draw( -- 691
				self.uiDraw, -- 692
				self.uiInkDraw, -- 693
				self.uiGlow, -- 694
				self.uiArt, -- 695
				self.texts, -- 696
				p, -- 697
				uiW, -- 698
				uiH, -- 699
				view.assistHintsEnabled, -- 700
				input.inputMode, -- 701
				input.gamepadLayout, -- 702
				self.stageVp.safeUi -- 703
			) -- 703
		end -- 703
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 707
		do -- 707
			i = 0 -- 708
			while i < #self.plugins do -- 708
				local pl = self.plugins[i + 1] -- 709
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 710
					self.uiDraw, -- 711
					self.uiInkDraw, -- 711
					self.uiArt, -- 711
					self.uiGlow, -- 711
					ctx -- 711
				) then -- 711
					suppressReticle = true -- 712
				end -- 712
				i = i + 1 -- 708
			end -- 708
		end -- 708
		if not suppressReticle then -- 715
			self.hud:drawReticleOverlay( -- 716
				self.uiInkDraw, -- 717
				self.uiArt, -- 718
				self.uiGlow, -- 719
				p, -- 720
				self.cam, -- 721
				self.vfx, -- 722
				self.narrative.letterbox, -- 723
				uiScale, -- 724
				input:isTouchMode() -- 725
			) -- 725
		end -- 725
		if view.isRehearsal then -- 730
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 731
			drawSilkVeil( -- 732
				self.uiDraw, -- 732
				self.uiArt, -- 732
				"rehearsal_tag_veil", -- 732
				uiW * 0.5, -- 732
				uiH - 22 - self.stageVp.safeUi.top, -- 732
				168, -- 732
				26, -- 732
				PALETTE.inkWarm, -- 732
				0.74, -- 732
				8 -- 732
			) -- 732
			self.texts:put( -- 733
				"xs", -- 733
				badgeText, -- 733
				uiW * 0.5, -- 733
				uiH - 22 - self.stageVp.safeUi.top, -- 733
				toColor(PALETTE.amberCore), -- 733
				0.5, -- 733
				0.5, -- 733
				"Center", -- 733
				1.2, -- 733
				0.92, -- 733
				0.08 -- 733
			) -- 733
		end -- 733
	end -- 733
	self:drawToast(uiW) -- 737
	self:finishFrame() -- 738
	return action -- 739
end -- 463
return ____exports -- 463
