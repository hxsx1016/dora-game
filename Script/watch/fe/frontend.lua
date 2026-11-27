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
function WatchFrontend.prototype.____constructor(self, parent) -- 88
	self.occlusion = __TS__New(DepthOcclusion) -- 47
	self.cam = __TS__New(CameraDirector) -- 66
	self.adapter = __TS__New(PlayAdapter) -- 67
	self.contract = __TS__New(DualRouteContract) -- 68
	self.audio = __TS__New(AudioDirector) -- 69
	self.soundscape = __TS__New(SoundscapeDirector) -- 70
	self.stage = __TS__New(StageRenderer) -- 71
	self.props = __TS__New(PropsRenderer) -- 72
	self.actors = __TS__New(ActorsRenderer) -- 73
	self.vfx = __TS__New(VfxSystem) -- 74
	self.hud = __TS__New(HudRenderer) -- 75
	self.narrative = __TS__New(NarrativeRenderer) -- 76
	self.menus = __TS__New(MenuRenderer) -- 77
	self.plugins = {} -- 79
	self.screen = "title" -- 81
	self.time = 0 -- 82
	self.stageVp = computeStageViewport(1280, 720) -- 84
	self.toastText = "" -- 85
	self.toastTimer = 0 -- 86
	self.layerRoot = Node() -- 89
	self.layerRoot.order = 5 -- 90
	self.layerRoot:addTo(parent) -- 91
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
	self.bgGlow = DrawNode() -- 107
	self.bgGlow.order = 15 -- 108
	self.bgGlow.blendFunc = additive -- 109
	self.bgGlow:addTo(self.layerRoot) -- 110
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 112
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 113
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 114
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 115
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 116
	self.fgDraw = DrawNode() -- 118
	self.fgDraw.order = 30 -- 119
	self.fgDraw:addTo(self.layerRoot) -- 120
	self.fgGlow = DrawNode() -- 122
	self.fgGlow.order = 35 -- 123
	self.fgGlow.blendFunc = additive -- 124
	self.fgGlow:addTo(self.layerRoot) -- 125
	self.uiLayer = Node() -- 127
	self.uiLayer.order = 40 -- 128
	self.uiLayer:addTo(self.layerRoot) -- 129
	self.uiDraw = DrawNode() -- 131
	self.uiDraw.order = 0 -- 132
	self.uiDraw:addTo(self.uiLayer) -- 133
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 135
	self.uiInkDraw = DrawNode() -- 137
	self.uiInkDraw.order = 4 -- 138
	self.uiInkDraw:addTo(self.uiLayer) -- 139
	self.uiGlow = DrawNode() -- 141
	self.uiGlow.order = 6 -- 142
	self.uiGlow.blendFunc = additive -- 143
	self.uiGlow:addTo(self.uiLayer) -- 144
	self.uiMask = DrawNode() -- 146
	self.uiMask.order = 8 -- 147
	self.uiMask:addTo(self.uiLayer) -- 148
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 150
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 164
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 165
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 166
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 167
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 168
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 169
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 170
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 171
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 172
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 173
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 174
end -- 88
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 178
	local i = 0 -- 179
	do -- 179
		i = 0 -- 180
		while i < #self.plugins do -- 180
			if self.plugins[i + 1].id == plugin.id then -- 180
				self.plugins[i + 1] = plugin -- 182
				self:syncRuntimeHooks() -- 183
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 183
					plugin:onBindPlay( -- 185
						self.boundPlay, -- 185
						self.contract:peekSnapshot(self.boundPlay) -- 185
					) -- 185
				end -- 185
				return -- 187
			end -- 187
			i = i + 1 -- 180
		end -- 180
	end -- 180
	local ____self_plugins_0 = self.plugins -- 180
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 190
	self:syncRuntimeHooks() -- 191
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 191
		plugin:onBindPlay( -- 193
			self.boundPlay, -- 193
			self.contract:peekSnapshot(self.boundPlay) -- 193
		) -- 193
	end -- 193
end -- 178
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 198
	local w = 0 -- 199
	local i = 0 -- 200
	do -- 200
		i = 0 -- 201
		while i < #self.plugins do -- 201
			if self.plugins[i + 1].id ~= id then -- 201
				self.plugins[w + 1] = self.plugins[i + 1] -- 203
				w = w + 1 -- 204
			end -- 204
			i = i + 1 -- 201
		end -- 201
	end -- 201
	__TS__ArraySetLength(self.plugins, w) -- 201
	self:syncRuntimeHooks() -- 208
end -- 198
function WatchFrontend.prototype.getPlugin(self, id) -- 212
	local i = 0 -- 213
	do -- 213
		i = 0 -- 214
		while i < #self.plugins do -- 214
			if self.plugins[i + 1].id == id then -- 214
				return self.plugins[i + 1] -- 216
			end -- 216
			i = i + 1 -- 214
		end -- 214
	end -- 214
	return nil -- 219
end -- 212
function WatchFrontend.prototype.getPlugins(self) -- 222
	return self.plugins -- 223
end -- 222
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 231
	local g = _G -- 232
	local ____temp_1 -- 233
	if g.package ~= nil then -- 233
		____temp_1 = g.package.loaded -- 233
	else -- 233
		____temp_1 = nil -- 233
	end -- 233
	local loaded = ____temp_1 -- 233
	if loaded == nil then -- 233
		return -- 235
	end -- 235
	local rawFe = loaded["watch.fe"] -- 237
	if rawFe ~= nil and type(rawFe) == "table" then -- 237
		local watchFe = rawFe -- 239
		if watchFe.contract ~= self.contract then -- 239
			watchFe.contract = self.contract -- 241
			watchFe.audio = self.audio -- 242
			watchFe.soundscape = self.soundscape -- 243
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 244
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 245
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 246
		end -- 246
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 248
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 249
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 250
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 251
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 252
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 253
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 254
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 255
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 256
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 257
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 258
	end -- 258
end -- 231
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 262
	local scale = math.max( -- 263
		0.25, -- 263
		math.min(w / 1280, h / 720) -- 263
	) -- 263
	self.uiLayer.scaleX = scale -- 264
	self.uiLayer.scaleY = scale -- 265
	return scale -- 266
end -- 262
function WatchFrontend.prototype.setVisible(self, v) -- 270
	self.layerRoot.visible = v -- 271
	if not v then -- 271
		self.texts:hideAll() -- 273
	end -- 273
end -- 270
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 278
	self:syncRuntimeHooks() -- 279
	self.boundPlay = p -- 280
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 281
	self.cam:snap(p, w, h) -- 282
	self.adapter:reset(p) -- 283
	self.contract:resetForRoom(p) -- 284
	self.audio:stopRoomTransient() -- 285
	self.soundscape:resetForRoom(p) -- 286
	self.actors:reset(p) -- 287
	self.occlusion:reset() -- 288
	self.vfx:reset() -- 289
	self.hud:reset(p) -- 290
	self.narrative:onEnterRoom(p.room.key) -- 291
	if #self.plugins > 0 then -- 291
		local initView = self.contract:peekSnapshot(p) -- 294
		local i = 0 -- 295
		do -- 295
			i = 0 -- 296
			while i < #self.plugins do -- 296
				local pl = self.plugins[i + 1] -- 297
				if pl.onBindPlay ~= nil then -- 297
					pl:onBindPlay(p, initView) -- 299
				end -- 299
				i = i + 1 -- 296
			end -- 296
		end -- 296
	end -- 296
end -- 278
function WatchFrontend.prototype.clearAll(self) -- 305
	self.bgDraw:clear() -- 306
	self.bgGlow:clear() -- 307
	self.fgDraw:clear() -- 308
	self.fgGlow:clear() -- 309
	self.uiDraw:clear() -- 310
	self.uiInkDraw:clear() -- 311
	self.uiGlow:clear() -- 312
	self.uiMask:clear() -- 313
	self.backdropArt:beginFrame() -- 314
	self.dioramaBg:beginFrame() -- 315
	self.dioramaWorld:beginFrame() -- 316
	self.dioramaFg:beginFrame() -- 317
	self.worldArt:beginFrame() -- 318
	self.uiArt:beginFrame() -- 319
	self.texts:beginFrame() -- 320
end -- 305
function WatchFrontend.prototype.finishFrame(self) -- 323
	self.backdropArt:endFrame() -- 324
	self.dioramaBg:endFrame() -- 325
	self.dioramaWorld:endFrame() -- 326
	self.dioramaFg:endFrame() -- 327
	self.worldArt:endFrame() -- 328
	self.uiArt:endFrame() -- 329
	self.texts:endFrame() -- 330
end -- 323
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 334
	self.stageVp = vp -- 335
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 336
end -- 334
function WatchFrontend.prototype.showToast(self, text, duration) -- 340
	if duration == nil then -- 340
		duration = 1.8 -- 340
	end -- 340
	self.toastText = text -- 341
	self.toastTimer = duration -- 342
end -- 340
function WatchFrontend.prototype.getToastText(self) -- 345
	return self.toastTimer > 0 and self.toastText or "" -- 346
end -- 345
function WatchFrontend.prototype.drawToast(self, uiW) -- 349
	if self.toastTimer <= 0 or self.toastText == "" then -- 349
		return -- 351
	end -- 351
	local alpha = math.min(1, self.toastTimer * 2.4) -- 353
	local cx = uiW * 0.5 -- 354
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 355
	drawSilkVeil( -- 356
		self.uiDraw, -- 356
		self.uiArt, -- 356
		"fe_toast_veil", -- 356
		cx, -- 356
		cy, -- 356
		340, -- 356
		38, -- 356
		PALETTE.inkWarm, -- 356
		0.86 * alpha, -- 356
		9 -- 356
	) -- 356
	self.texts:put( -- 357
		"sm", -- 357
		self.toastText, -- 357
		cx, -- 357
		cy, -- 357
		toColor(PALETTE.amberCore), -- 357
		0.5, -- 357
		0.5, -- 357
		"Center", -- 357
		1.4, -- 357
		0.96 * alpha, -- 357
		0.08 -- 357
	) -- 357
end -- 349
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 361
	local offers = p:getStoryTalentOffers() -- 362
	if #offers == 0 then -- 362
		return {} -- 364
	end -- 364
	local uiScale = math.max( -- 366
		0.25, -- 366
		math.min(w / 1280, h / 720) -- 366
	) -- 366
	return self.hud:talentCardRects( -- 367
		w / uiScale, -- 367
		h / uiScale, -- 367
		#offers, -- 367
		touchMode, -- 367
		self.stageVp.safeUi.top -- 367
	) -- 367
end -- 361
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 370
	if kind == "hover" then -- 370
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 372
	elseif kind == "confirm" then -- 372
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 374
	elseif kind == "back" then -- 374
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 376
	elseif kind == "start" then -- 376
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 378
	elseif kind == "pauseOpen" then -- 378
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 380
	elseif kind == "pauseClose" then -- 380
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 382
	elseif kind == "toggle" then -- 382
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 384
	end -- 384
end -- 370
function WatchFrontend.prototype.resetTrialAudio(self, p) -- 389
	self.adapter:reset(p) -- 390
	self.audio:stopRoomTransient() -- 391
	self.soundscape:resetForRoom(p) -- 392
end -- 389
function WatchFrontend.prototype.syncTrialAudio(self, dt, p, offerCount) -- 396
	local safeDt = math.min( -- 397
		0.05, -- 397
		math.max(0.001, dt) -- 397
	) -- 397
	self.audio:setPaused(p.paused) -- 398
	self.audio:setCameraRef(p.player.x, 960) -- 399
	self.audio:update(safeDt) -- 400
	if not p.paused then -- 400
		local ev = self.adapter:sample(p) -- 402
		self.audio:ingestEvents(ev, p) -- 403
		self.soundscape:updateTrial(safeDt, p, self.audio, offerCount) -- 404
	end -- 404
end -- 396
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 409
	self:syncRuntimeHooks() -- 410
	local safeDt = math.min( -- 411
		0.05, -- 411
		math.max(0, dt) -- 411
	) -- 411
	if self.toastTimer > 0 then -- 411
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 413
	end -- 413
	if self.screen == "title" and self.boundPlay ~= nil then -- 413
		self.audio:stopRoomTransient() -- 416
		self.boundPlay = nil -- 417
	end -- 417
	self.audio:update(safeDt) -- 419
	self.soundscape:updateMenu(self.screen, self.audio) -- 420
	self:setVisible(true) -- 421
	self:clearAll() -- 422
	local uiScale = self:resizeInterface(w, h) -- 423
	local act = self.menus:updateAndDrawScreen( -- 424
		dt, -- 425
		self.screen, -- 426
		input, -- 427
		self.stage, -- 428
		self.bgDraw, -- 429
		self.bgGlow, -- 430
		self.backdropArt, -- 431
		self.uiArt, -- 432
		self.uiDraw, -- 433
		self.uiInkDraw, -- 434
		self.uiGlow, -- 435
		self.texts, -- 436
		w, -- 437
		h, -- 438
		uiScale, -- 439
		self.stageVp.safeUi -- 440
	) -- 440
	self:drawToast(w / uiScale) -- 442
	self:finishFrame() -- 443
	return act -- 444
end -- 409
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 448
	local offers = p:getStoryTalentOffers() -- 449
	if #offers == 0 then -- 449
		return false -- 451
	end -- 451
	if input.inputMode == "gamepad" and not input.uiPressed then -- 451
		return false -- 454
	end -- 454
	local useUiPtr = input.uiInside or input.uiPressed -- 456
	local ____useUiPtr_2 -- 457
	if useUiPtr then -- 457
		____useUiPtr_2 = input.uiInside -- 457
	else -- 457
		____useUiPtr_2 = input.inside -- 457
	end -- 457
	local inside = ____useUiPtr_2 -- 457
	if not inside then -- 457
		return false -- 459
	end -- 459
	local uiScale = math.max( -- 461
		0.25, -- 461
		math.min(w / 1280, h / 720) -- 461
	) -- 461
	local uiW = w / uiScale -- 462
	local uiH = h / uiScale -- 463
	local rawX = useUiPtr and input.uiX or input.mx -- 464
	local rawY = useUiPtr and input.uiY or input.my -- 465
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 466
	local boxes = self.hud:talentCardRects( -- 467
		uiW, -- 467
		uiH, -- 467
		#offers, -- 467
		input:isTouchMode(), -- 467
		self.stageVp.safeUi.top -- 467
	) -- 467
	local i = 0 -- 468
	do -- 468
		i = 0 -- 469
		while i < #boxes do -- 469
			if boxes[i + 1]:containsPoint(pointer) then -- 469
				return p:chooseTalent(i) -- 471
			end -- 471
			i = i + 1 -- 469
		end -- 469
	end -- 469
	return false -- 474
end -- 448
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 478
	self:syncRuntimeHooks() -- 479
	self:setVisible(true) -- 480
	if self.boundPlay ~= p then -- 480
		self:bindPlay(p, w, h) -- 482
	end -- 482
	local safeDt = math.min( -- 484
		0.05, -- 484
		math.max(0.001, dt) -- 484
	) -- 484
	if self.toastTimer > 0 then -- 484
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 486
	end -- 486
	self.audio:setPaused(p.paused) -- 488
	self.audio:setCameraRef( -- 489
		self.cam.x, -- 489
		w / math.max(0.25, self.cam.ppu) -- 489
	) -- 489
	self.audio:update(safeDt) -- 490
	local ev -- 492
	local worldDt = 0 -- 493
	local uiDt = 0 -- 494
	if not p.paused then -- 494
		ev = self.adapter:sample(p) -- 498
		self.vfx:ingest(ev, p, self.cam) -- 499
		self.audio:ingestEvents(ev, p) -- 500
		local touch = input:getTouch() -- 501
		if touch ~= nil then -- 501
			if ev.playerHit then -- 501
				touch:vibrate(0.036) -- 504
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 504
				touch:vibrate(0.024) -- 506
			elseif ev.coverDeflect then -- 506
				touch:vibrate(0.018) -- 508
			elseif ev.knockPulse then -- 508
				touch:vibrate(0.014) -- 510
			end -- 510
		end -- 510
	else -- 510
		ev = self.adapter:emptyFrame(p) -- 515
		self.narrative.wipeT = 0 -- 516
	end -- 516
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 519
	if not p.paused then -- 519
		local clampedScale = math.max( -- 521
			0, -- 521
			math.min(2, view.timeScale) -- 521
		) -- 521
		uiDt = safeDt -- 522
		worldDt = safeDt * clampedScale -- 523
	end -- 523
	local uiScale = self:resizeInterface(w, h) -- 526
	local uiW = w / uiScale -- 527
	local uiH = h / uiScale -- 528
	local ctx = { -- 530
		p = p, -- 531
		view = view, -- 532
		events = ev, -- 533
		input = input, -- 534
		cam = self.cam, -- 535
		audio = self.audio, -- 536
		assets = self.worldArt, -- 537
		backdropArt = self.backdropArt, -- 538
		worldArt = self.worldArt, -- 539
		uiArt = self.uiArt, -- 540
		uiMask = self.uiMask, -- 541
		dioramaBg = self.dioramaBg, -- 542
		dioramaWorld = self.dioramaWorld, -- 543
		dioramaFg = self.dioramaFg, -- 544
		texts = self.texts, -- 545
		worldDt = worldDt, -- 546
		uiDt = uiDt, -- 547
		w = w, -- 548
		h = h, -- 549
		uiW = uiW, -- 550
		uiH = uiH, -- 551
		uiScale = uiScale, -- 552
		safeUi = self.stageVp.safeUi, -- 553
		paused = p.paused -- 554
	} -- 554
	local i = 0 -- 558
	do -- 558
		i = 0 -- 559
		while i < #self.plugins do -- 559
			local pl = self.plugins[i + 1] -- 560
			if pl.update ~= nil then -- 560
				pl:update(ctx) -- 562
			end -- 562
			i = i + 1 -- 559
		end -- 559
	end -- 559
	if not p.paused then -- 559
		self.time = self.time + worldDt -- 567
		self.cam:update(worldDt, p, w, h) -- 568
		self.audio:setCameraRef( -- 569
			self.cam.x, -- 569
			w / math.max(0.25, self.cam.ppu) -- 569
		) -- 569
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 570
		self.actors:update(worldDt, p) -- 571
		self.vfx:update( -- 572
			worldDt, -- 572
			themeOf(p.room.key).ambient -- 572
		) -- 572
		self.hud:update(safeDt, p) -- 573
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 574
	else -- 574
		self.cam:update(0, p, w, h) -- 576
	end -- 576
	self:clearAll() -- 579
	local backdropHandled = false -- 582
	do -- 582
		i = 0 -- 583
		while i < #self.plugins do -- 583
			local pl = self.plugins[i + 1] -- 584
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 584
				backdropHandled = true -- 586
			end -- 586
			i = i + 1 -- 583
		end -- 583
	end -- 583
	if not backdropHandled then -- 583
		self.stage:drawBackdrop( -- 590
			self.bgDraw, -- 590
			self.bgGlow, -- 590
			self.backdropArt, -- 590
			p, -- 590
			self.cam, -- 590
			self.time -- 590
		) -- 590
	end -- 590
	local worldHandled = false -- 594
	do -- 594
		i = 0 -- 595
		while i < #self.plugins do -- 595
			local pl = self.plugins[i + 1] -- 596
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 596
				worldHandled = true -- 598
			end -- 598
			i = i + 1 -- 595
		end -- 595
	end -- 595
	if not worldHandled then -- 595
		self.stage:drawPlayableWorld( -- 602
			self.fgDraw, -- 602
			self.fgGlow, -- 602
			self.worldArt, -- 602
			p, -- 602
			self.cam, -- 602
			self.time, -- 602
			self.occlusion, -- 602
			worldDt -- 602
		) -- 602
	end -- 602
	local propsHandled = false -- 606
	do -- 606
		i = 0 -- 607
		while i < #self.plugins do -- 607
			local pl = self.plugins[i + 1] -- 608
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 608
				propsHandled = true -- 610
			end -- 610
			i = i + 1 -- 607
		end -- 607
	end -- 607
	if not propsHandled then -- 607
		self.props:drawAll( -- 614
			self.fgDraw, -- 614
			self.fgGlow, -- 614
			self.worldArt, -- 614
			p, -- 614
			self.cam, -- 614
			self.time, -- 614
			self.occlusion, -- 614
			worldDt -- 614
		) -- 614
	end -- 614
	if view.visualMode ~= "museum" then -- 614
		local pose -- 619
		for ____, pl in ipairs(self.plugins) do -- 620
			if pl.drawPartyPose ~= nil then -- 620
				pose = pl:drawPartyPose(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 622
				if pose ~= nil then -- 622
					break -- 623
				end -- 623
			end -- 623
		end -- 623
		self.actors:drawAll( -- 626
			self.fgDraw, -- 626
			self.fgGlow, -- 626
			self.worldArt, -- 626
			p, -- 626
			self.cam, -- 626
			pose -- 626
		) -- 626
	end -- 626
	do -- 626
		i = 0 -- 628
		while i < #self.plugins do -- 628
			local pl = self.plugins[i + 1] -- 629
			if pl.drawActorsOverlay ~= nil then -- 629
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 631
			end -- 631
			i = i + 1 -- 628
		end -- 628
	end -- 628
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 636
	if view.visualMode == "pixel" then -- 636
		self.stage:drawForegroundFraming( -- 640
			self.fgDraw, -- 640
			w, -- 640
			h, -- 640
			p, -- 640
			self.cam -- 640
		) -- 640
	end -- 640
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 642
	local action = {type = "none"} -- 645
	if p.paused then -- 645
		action = self.menus:updateAndDrawPause( -- 647
			safeDt, -- 648
			input, -- 649
			self.uiDraw, -- 650
			self.uiInkDraw, -- 651
			self.uiArt, -- 652
			self.uiGlow, -- 653
			self.texts, -- 654
			uiW, -- 655
			uiH, -- 656
			uiScale, -- 657
			view.assistHintsEnabled, -- 658
			function() -- 659
				self.contract:toggleAssistHints() -- 660
			end, -- 659
			self.stageVp.safeUi -- 662
		) -- 662
	else -- 662
		local cutsceneHandled = false -- 666
		do -- 666
			i = 0 -- 667
			while i < #self.plugins do -- 667
				local pl = self.plugins[i + 1] -- 668
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 668
					self.uiDraw, -- 670
					self.uiInkDraw, -- 670
					self.uiArt, -- 670
					self.uiGlow, -- 670
					ctx -- 670
				) then -- 670
					cutsceneHandled = true -- 671
				end -- 671
				i = i + 1 -- 667
			end -- 667
		end -- 667
		if not cutsceneHandled then -- 667
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 676
			self.hud:draw( -- 677
				self.uiDraw, -- 678
				self.uiInkDraw, -- 679
				self.uiArt, -- 680
				self.uiGlow, -- 681
				self.texts, -- 682
				p, -- 683
				self.cam, -- 684
				self.vfx, -- 685
				self.narrative.letterbox, -- 686
				uiScale, -- 687
				view.assistHintsEnabled, -- 688
				true, -- 689
				input.inputMode, -- 690
				input.gamepadLayout, -- 691
				self.stageVp.safeUi, -- 692
				input.retryHoldProgress, -- 693
				touchOverlayVisible -- 694
			) -- 694
			self.narrative:draw( -- 696
				self.uiDraw, -- 697
				self.uiInkDraw, -- 698
				self.uiGlow, -- 699
				self.uiArt, -- 700
				self.texts, -- 701
				p, -- 702
				uiW, -- 703
				uiH, -- 704
				view.assistHintsEnabled, -- 705
				input.inputMode, -- 706
				input.gamepadLayout, -- 707
				self.stageVp.safeUi -- 708
			) -- 708
		end -- 708
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 712
		do -- 712
			i = 0 -- 713
			while i < #self.plugins do -- 713
				local pl = self.plugins[i + 1] -- 714
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 714
					self.uiDraw, -- 716
					self.uiInkDraw, -- 716
					self.uiArt, -- 716
					self.uiGlow, -- 716
					ctx -- 716
				) then -- 716
					suppressReticle = true -- 717
				end -- 717
				i = i + 1 -- 713
			end -- 713
		end -- 713
		if not suppressReticle then -- 713
			self.hud:drawReticleOverlay( -- 721
				self.uiInkDraw, -- 722
				self.uiArt, -- 723
				self.uiGlow, -- 724
				p, -- 725
				self.cam, -- 726
				self.vfx, -- 727
				self.narrative.letterbox, -- 728
				uiScale, -- 729
				input:isTouchMode() -- 730
			) -- 730
		end -- 730
		if view.isRehearsal then -- 730
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 736
			drawSilkVeil( -- 737
				self.uiDraw, -- 737
				self.uiArt, -- 737
				"rehearsal_tag_veil", -- 737
				uiW * 0.5, -- 737
				uiH - 22 - self.stageVp.safeUi.top, -- 737
				168, -- 737
				26, -- 737
				PALETTE.inkWarm, -- 737
				0.74, -- 737
				8 -- 737
			) -- 737
			self.texts:put( -- 738
				"xs", -- 738
				badgeText, -- 738
				uiW * 0.5, -- 738
				uiH - 22 - self.stageVp.safeUi.top, -- 738
				toColor(PALETTE.amberCore), -- 738
				0.5, -- 738
				0.5, -- 738
				"Center", -- 738
				1.2, -- 738
				0.92, -- 738
				0.08 -- 738
			) -- 738
		end -- 738
	end -- 738
	self:drawToast(uiW) -- 742
	self:finishFrame() -- 743
	return action -- 744
end -- 478
return ____exports -- 478