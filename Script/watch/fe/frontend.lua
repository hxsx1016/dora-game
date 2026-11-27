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
local ____textpool = require("Script.watch.fe.ui.textpool") -- 28
local TextPool = ____textpool.TextPool -- 28
local ____hud = require("Script.watch.fe.ui.hud") -- 29
local HudRenderer = ____hud.HudRenderer -- 29
local ____narrative = require("Script.watch.fe.ui.narrative") -- 30
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 30
local ____menus = require("Script.watch.fe.ui.menus") -- 31
local MenuRenderer = ____menus.MenuRenderer -- 31
local ____theme = require("Script.watch.fe.theme") -- 32
local PALETTE = ____theme.PALETTE -- 32
local drawSilkVeil = ____theme.drawSilkVeil -- 32
local themeOf = ____theme.themeOf -- 32
local toColor = ____theme.toColor -- 32
local ____ming_audit = require("Script.watch.fe.renderer.ming_audit") -- 33
local MingArtAuditPlugin = ____ming_audit.MingArtAuditPlugin -- 33
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 34
local GateTransitionPlugin = ____gate_transition.GateTransitionPlugin -- 34
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 35
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 35
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 36
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 36
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 37
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 37
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 38
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 38
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 39
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 39
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 40
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 40
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 41
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 41
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 42
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 42
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 43
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 43
____exports.WatchFrontend = __TS__Class() -- 45
local WatchFrontend = ____exports.WatchFrontend -- 45
WatchFrontend.name = "WatchFrontend" -- 45
function WatchFrontend.prototype.____constructor(self, parent) -- 83
	self.occlusion = __TS__New(DepthOcclusion) -- 46
	self.cam = __TS__New(CameraDirector) -- 61
	self.adapter = __TS__New(PlayAdapter) -- 62
	self.contract = __TS__New(DualRouteContract) -- 63
	self.audio = __TS__New(AudioDirector) -- 64
	self.soundscape = __TS__New(SoundscapeDirector) -- 65
	self.stage = __TS__New(StageRenderer) -- 66
	self.props = __TS__New(PropsRenderer) -- 67
	self.actors = __TS__New(ActorsRenderer) -- 68
	self.vfx = __TS__New(VfxSystem) -- 69
	self.hud = __TS__New(HudRenderer) -- 70
	self.narrative = __TS__New(NarrativeRenderer) -- 71
	self.menus = __TS__New(MenuRenderer) -- 72
	self.plugins = {} -- 74
	self.screen = "title" -- 76
	self.time = 0 -- 77
	self.stageVp = computeStageViewport(1280, 720) -- 79
	self.toastText = "" -- 80
	self.toastTimer = 0 -- 81
	self.layerRoot = Node() -- 84
	self.layerRoot.order = 5 -- 85
	self.layerRoot:addTo(parent) -- 86
	self.audio:attachHost(self.layerRoot) -- 88
	self.menus.onUiSound = function(____, kind) -- 89
		self:playMenuUiSound(kind) -- 90
	end -- 89
	self.menus.onAudioSettingsChanged = function(____, inp) -- 92
		self.audio:applyUserVolumes(inp.settings) -- 93
	end -- 92
	local additive = BlendFunc("SrcAlpha", "One") -- 96
	self.bgDraw = DrawNode() -- 98
	self.bgDraw.order = 10 -- 99
	self.bgDraw:addTo(self.layerRoot) -- 100
	self.bgGlow = DrawNode() -- 102
	self.bgGlow.order = 15 -- 103
	self.bgGlow.blendFunc = additive -- 104
	self.bgGlow:addTo(self.layerRoot) -- 105
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 107
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 108
	self.fgDraw = DrawNode() -- 110
	self.fgDraw.order = 30 -- 111
	self.fgDraw:addTo(self.layerRoot) -- 112
	self.fgGlow = DrawNode() -- 114
	self.fgGlow.order = 35 -- 115
	self.fgGlow.blendFunc = additive -- 116
	self.fgGlow:addTo(self.layerRoot) -- 117
	self.uiLayer = Node() -- 119
	self.uiLayer.order = 40 -- 120
	self.uiLayer:addTo(self.layerRoot) -- 121
	self.uiDraw = DrawNode() -- 123
	self.uiDraw.order = 0 -- 124
	self.uiDraw:addTo(self.uiLayer) -- 125
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 127
	self.uiInkDraw = DrawNode() -- 129
	self.uiInkDraw.order = 4 -- 130
	self.uiInkDraw:addTo(self.uiLayer) -- 131
	self.uiGlow = DrawNode() -- 133
	self.uiGlow.order = 6 -- 134
	self.uiGlow.blendFunc = additive -- 135
	self.uiGlow:addTo(self.uiLayer) -- 136
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 138
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 152
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 153
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 154
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 155
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 156
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 157
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 158
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 159
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 160
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 161
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 162
end -- 83
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 166
	local i = 0 -- 167
	do -- 167
		i = 0 -- 168
		while i < #self.plugins do -- 168
			if self.plugins[i + 1].id == plugin.id then -- 168
				self.plugins[i + 1] = plugin -- 170
				self:syncRuntimeHooks() -- 171
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 171
					plugin:onBindPlay( -- 173
						self.boundPlay, -- 173
						self.contract:peekSnapshot(self.boundPlay) -- 173
					) -- 173
				end -- 173
				return -- 175
			end -- 175
			i = i + 1 -- 168
		end -- 168
	end -- 168
	local ____self_plugins_0 = self.plugins -- 168
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 178
	self:syncRuntimeHooks() -- 179
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 179
		plugin:onBindPlay( -- 181
			self.boundPlay, -- 181
			self.contract:peekSnapshot(self.boundPlay) -- 181
		) -- 181
	end -- 181
end -- 166
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 186
	local w = 0 -- 187
	local i = 0 -- 188
	do -- 188
		i = 0 -- 189
		while i < #self.plugins do -- 189
			if self.plugins[i + 1].id ~= id then -- 189
				self.plugins[w + 1] = self.plugins[i + 1] -- 191
				w = w + 1 -- 192
			end -- 192
			i = i + 1 -- 189
		end -- 189
	end -- 189
	__TS__ArraySetLength(self.plugins, w) -- 189
	self:syncRuntimeHooks() -- 196
end -- 186
function WatchFrontend.prototype.getPlugin(self, id) -- 200
	local i = 0 -- 201
	do -- 201
		i = 0 -- 202
		while i < #self.plugins do -- 202
			if self.plugins[i + 1].id == id then -- 202
				return self.plugins[i + 1] -- 204
			end -- 204
			i = i + 1 -- 202
		end -- 202
	end -- 202
	return nil -- 207
end -- 200
function WatchFrontend.prototype.getPlugins(self) -- 210
	return self.plugins -- 211
end -- 210
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 219
	local g = _G -- 220
	local ____temp_1 -- 221
	if g.package ~= nil then -- 221
		____temp_1 = g.package.loaded -- 221
	else -- 221
		____temp_1 = nil -- 221
	end -- 221
	local loaded = ____temp_1 -- 221
	if loaded == nil then -- 221
		return -- 223
	end -- 223
	local rawFe = loaded["watch.fe"] -- 225
	if rawFe ~= nil and type(rawFe) == "table" then -- 225
		local watchFe = rawFe -- 227
		if watchFe.contract ~= self.contract then -- 227
			watchFe.contract = self.contract -- 229
			watchFe.audio = self.audio -- 230
			watchFe.soundscape = self.soundscape -- 231
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 232
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 233
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 234
		end -- 234
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 236
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 237
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 238
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 239
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 240
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 241
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 242
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 243
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 244
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 245
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 246
	end -- 246
end -- 219
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 250
	local scale = math.max( -- 251
		0.25, -- 251
		math.min(w / 1280, h / 720) -- 251
	) -- 251
	self.uiLayer.scaleX = scale -- 252
	self.uiLayer.scaleY = scale -- 253
	return scale -- 254
end -- 250
function WatchFrontend.prototype.setVisible(self, v) -- 258
	self.layerRoot.visible = v -- 259
	if not v then -- 259
		self.texts:hideAll() -- 261
	end -- 261
end -- 258
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 266
	local hdCast = p.room.key == "gate" or p.room.key == "gatepath" or p.room.key == "outside" -- 267
	self.worldArt:setHdCast(hdCast) -- 268
	self.uiArt:setHdCast(hdCast) -- 269
	self:syncRuntimeHooks() -- 270
	self.boundPlay = p -- 271
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 272
	self.cam:snap(p, w, h) -- 273
	self.adapter:reset(p) -- 274
	self.contract:resetForRoom(p) -- 275
	self.audio:stopRoomTransient() -- 276
	self.soundscape:resetForRoom(p) -- 277
	self.actors:reset(p) -- 278
	self.occlusion:reset() -- 279
	self.vfx:reset() -- 280
	self.hud:reset(p) -- 281
	self.narrative:onEnterRoom(p.room.key) -- 282
	if #self.plugins > 0 then -- 282
		local initView = self.contract:peekSnapshot(p) -- 285
		local i = 0 -- 286
		do -- 286
			i = 0 -- 287
			while i < #self.plugins do -- 287
				local pl = self.plugins[i + 1] -- 288
				if pl.onBindPlay ~= nil then -- 288
					pl:onBindPlay(p, initView) -- 290
				end -- 290
				i = i + 1 -- 287
			end -- 287
		end -- 287
	end -- 287
end -- 266
function WatchFrontend.prototype.clearAll(self) -- 296
	self.bgDraw:clear() -- 297
	self.bgGlow:clear() -- 298
	self.fgDraw:clear() -- 299
	self.fgGlow:clear() -- 300
	self.uiDraw:clear() -- 301
	self.uiInkDraw:clear() -- 302
	self.uiGlow:clear() -- 303
	self.backdropArt:beginFrame() -- 304
	self.worldArt:beginFrame() -- 305
	self.uiArt:beginFrame() -- 306
	self.texts:beginFrame() -- 307
end -- 296
function WatchFrontend.prototype.finishFrame(self) -- 310
	self.backdropArt:endFrame() -- 311
	self.worldArt:endFrame() -- 312
	self.uiArt:endFrame() -- 313
	self.texts:endFrame() -- 314
end -- 310
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 318
	self.stageVp = vp -- 319
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 320
end -- 318
function WatchFrontend.prototype.showToast(self, text, duration) -- 324
	if duration == nil then -- 324
		duration = 1.8 -- 324
	end -- 324
	self.toastText = text -- 325
	self.toastTimer = duration -- 326
end -- 324
function WatchFrontend.prototype.getToastText(self) -- 329
	return self.toastTimer > 0 and self.toastText or "" -- 330
end -- 329
function WatchFrontend.prototype.drawToast(self, uiW) -- 333
	if self.toastTimer <= 0 or self.toastText == "" then -- 333
		return -- 335
	end -- 335
	local alpha = math.min(1, self.toastTimer * 2.4) -- 337
	local cx = uiW * 0.5 -- 338
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 339
	drawSilkVeil( -- 340
		self.uiDraw, -- 340
		self.uiArt, -- 340
		"fe_toast_veil", -- 340
		cx, -- 340
		cy, -- 340
		340, -- 340
		38, -- 340
		PALETTE.inkWarm, -- 340
		0.86 * alpha, -- 340
		9 -- 340
	) -- 340
	self.texts:put( -- 341
		"sm", -- 341
		self.toastText, -- 341
		cx, -- 341
		cy, -- 341
		toColor(PALETTE.amberCore), -- 341
		0.5, -- 341
		0.5, -- 341
		"Center", -- 341
		1.4, -- 341
		0.96 * alpha, -- 341
		0.08 -- 341
	) -- 341
end -- 333
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 345
	local offers = p:getStoryTalentOffers() -- 346
	if #offers == 0 then -- 346
		return {} -- 348
	end -- 348
	local uiScale = math.max( -- 350
		0.25, -- 350
		math.min(w / 1280, h / 720) -- 350
	) -- 350
	return self.hud:talentCardRects( -- 351
		w / uiScale, -- 351
		h / uiScale, -- 351
		#offers, -- 351
		touchMode, -- 351
		self.stageVp.safeUi.top -- 351
	) -- 351
end -- 345
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 354
	if kind == "hover" then -- 354
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 356
	elseif kind == "confirm" then -- 356
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 358
	elseif kind == "back" then -- 358
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 360
	elseif kind == "start" then -- 360
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 362
	elseif kind == "pauseOpen" then -- 362
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 364
	elseif kind == "pauseClose" then -- 364
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 366
	elseif kind == "toggle" then -- 366
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 368
	end -- 368
end -- 354
function WatchFrontend.prototype.resetTrialAudio(self, p) -- 373
	self.adapter:reset(p) -- 374
	self.audio:stopRoomTransient() -- 375
	self.soundscape:resetForRoom(p) -- 376
end -- 373
function WatchFrontend.prototype.syncTrialAudio(self, dt, p, offerCount) -- 380
	local safeDt = math.min( -- 381
		0.05, -- 381
		math.max(0.001, dt) -- 381
	) -- 381
	self.audio:setPaused(p.paused) -- 382
	self.audio:setCameraRef(p.player.x, 960) -- 383
	self.audio:update(safeDt) -- 384
	if not p.paused then -- 384
		local ev = self.adapter:sample(p) -- 386
		self.audio:ingestEvents(ev, p) -- 387
		self.soundscape:updateTrial(safeDt, p, self.audio, offerCount) -- 388
	end -- 388
end -- 380
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 393
	self:syncRuntimeHooks() -- 394
	local safeDt = math.min( -- 395
		0.05, -- 395
		math.max(0, dt) -- 395
	) -- 395
	if self.toastTimer > 0 then -- 395
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 397
	end -- 397
	if self.screen == "title" and self.boundPlay ~= nil then -- 397
		self.audio:stopRoomTransient() -- 400
		self.boundPlay = nil -- 401
	end -- 401
	self.audio:update(safeDt) -- 403
	self.soundscape:updateMenu(self.screen, self.audio) -- 404
	self:setVisible(true) -- 405
	self:clearAll() -- 406
	local uiScale = self:resizeInterface(w, h) -- 407
	local act = self.menus:updateAndDrawScreen( -- 408
		dt, -- 409
		self.screen, -- 410
		input, -- 411
		self.stage, -- 412
		self.bgDraw, -- 413
		self.bgGlow, -- 414
		self.backdropArt, -- 415
		self.uiArt, -- 416
		self.uiDraw, -- 417
		self.uiInkDraw, -- 418
		self.uiGlow, -- 419
		self.texts, -- 420
		w, -- 421
		h, -- 422
		uiScale, -- 423
		self.stageVp.safeUi -- 424
	) -- 424
	self:drawToast(w / uiScale) -- 426
	self:finishFrame() -- 427
	return act -- 428
end -- 393
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 432
	local offers = p:getStoryTalentOffers() -- 433
	if #offers == 0 then -- 433
		return false -- 435
	end -- 435
	if input.inputMode == "gamepad" and not input.uiPressed then -- 435
		return false -- 438
	end -- 438
	local useUiPtr = input.uiInside or input.uiPressed -- 440
	local ____useUiPtr_2 -- 441
	if useUiPtr then -- 441
		____useUiPtr_2 = input.uiInside -- 441
	else -- 441
		____useUiPtr_2 = input.inside -- 441
	end -- 441
	local inside = ____useUiPtr_2 -- 441
	if not inside then -- 441
		return false -- 443
	end -- 443
	local uiScale = math.max( -- 445
		0.25, -- 445
		math.min(w / 1280, h / 720) -- 445
	) -- 445
	local uiW = w / uiScale -- 446
	local uiH = h / uiScale -- 447
	local rawX = useUiPtr and input.uiX or input.mx -- 448
	local rawY = useUiPtr and input.uiY or input.my -- 449
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 450
	local boxes = self.hud:talentCardRects( -- 451
		uiW, -- 451
		uiH, -- 451
		#offers, -- 451
		input:isTouchMode(), -- 451
		self.stageVp.safeUi.top -- 451
	) -- 451
	local i = 0 -- 452
	do -- 452
		i = 0 -- 453
		while i < #boxes do -- 453
			if boxes[i + 1]:containsPoint(pointer) then -- 453
				return p:chooseTalent(i) -- 455
			end -- 455
			i = i + 1 -- 453
		end -- 453
	end -- 453
	return false -- 458
end -- 432
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 462
	self:syncRuntimeHooks() -- 463
	self:setVisible(true) -- 464
	if self.boundPlay ~= p then -- 464
		self:bindPlay(p, w, h) -- 466
	end -- 466
	local safeDt = math.min( -- 468
		0.05, -- 468
		math.max(0.001, dt) -- 468
	) -- 468
	if self.toastTimer > 0 then -- 468
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 470
	end -- 470
	self.audio:setPaused(p.paused) -- 472
	self.audio:setCameraRef( -- 473
		self.cam.x, -- 473
		w / math.max(0.25, self.cam.ppu) -- 473
	) -- 473
	self.audio:update(safeDt) -- 474
	local ev -- 476
	local worldDt = 0 -- 477
	local uiDt = 0 -- 478
	if not p.paused then -- 478
		ev = self.adapter:sample(p) -- 482
		self.vfx:ingest(ev, p, self.cam) -- 483
		self.audio:ingestEvents(ev, p) -- 484
		local touch = input:getTouch() -- 485
		if touch ~= nil then -- 485
			if ev.playerHit then -- 485
				touch:vibrate(0.036) -- 488
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 488
				touch:vibrate(0.024) -- 490
			elseif ev.coverDeflect then -- 490
				touch:vibrate(0.018) -- 492
			elseif ev.knockPulse then -- 492
				touch:vibrate(0.014) -- 494
			end -- 494
		end -- 494
	else -- 494
		ev = self.adapter:emptyFrame(p) -- 499
		self.narrative.wipeT = 0 -- 500
	end -- 500
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 503
	if not p.paused then -- 503
		local clampedScale = math.max( -- 505
			0, -- 505
			math.min(2, view.timeScale) -- 505
		) -- 505
		uiDt = safeDt -- 506
		worldDt = safeDt * clampedScale -- 507
	end -- 507
	local uiScale = self:resizeInterface(w, h) -- 510
	local uiW = w / uiScale -- 511
	local uiH = h / uiScale -- 512
	local ctx = { -- 514
		p = p, -- 515
		view = view, -- 516
		events = ev, -- 517
		input = input, -- 518
		cam = self.cam, -- 519
		audio = self.audio, -- 520
		assets = self.worldArt, -- 521
		backdropArt = self.backdropArt, -- 522
		worldArt = self.worldArt, -- 523
		uiArt = self.uiArt, -- 524
		texts = self.texts, -- 525
		worldDt = worldDt, -- 526
		uiDt = uiDt, -- 527
		w = w, -- 528
		h = h, -- 529
		uiW = uiW, -- 530
		uiH = uiH, -- 531
		uiScale = uiScale, -- 532
		safeUi = self.stageVp.safeUi, -- 533
		paused = p.paused -- 534
	} -- 534
	local i = 0 -- 538
	do -- 538
		i = 0 -- 539
		while i < #self.plugins do -- 539
			local pl = self.plugins[i + 1] -- 540
			if pl.update ~= nil then -- 540
				pl:update(ctx) -- 542
			end -- 542
			i = i + 1 -- 539
		end -- 539
	end -- 539
	if not p.paused then -- 539
		self.time = self.time + worldDt -- 547
		self.cam:update(worldDt, p, w, h) -- 548
		self.audio:setCameraRef( -- 549
			self.cam.x, -- 549
			w / math.max(0.25, self.cam.ppu) -- 549
		) -- 549
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 550
		self.actors:update(worldDt, p) -- 551
		self.vfx:update( -- 552
			worldDt, -- 552
			themeOf(p.room.key).ambient -- 552
		) -- 552
		self.hud:update(safeDt, p) -- 553
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 554
	else -- 554
		self.cam:update(0, p, w, h) -- 556
	end -- 556
	self:clearAll() -- 559
	local backdropHandled = false -- 562
	do -- 562
		i = 0 -- 563
		while i < #self.plugins do -- 563
			local pl = self.plugins[i + 1] -- 564
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 564
				backdropHandled = true -- 566
			end -- 566
			i = i + 1 -- 563
		end -- 563
	end -- 563
	if not backdropHandled then -- 563
		self.stage:drawBackdrop( -- 570
			self.bgDraw, -- 570
			self.bgGlow, -- 570
			self.backdropArt, -- 570
			p, -- 570
			self.cam, -- 570
			self.time -- 570
		) -- 570
	end -- 570
	local worldHandled = false -- 574
	do -- 574
		i = 0 -- 575
		while i < #self.plugins do -- 575
			local pl = self.plugins[i + 1] -- 576
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 576
				worldHandled = true -- 578
			end -- 578
			i = i + 1 -- 575
		end -- 575
	end -- 575
	if not worldHandled then -- 575
		self.stage:drawPlayableWorld( -- 582
			self.fgDraw, -- 582
			self.fgGlow, -- 582
			self.worldArt, -- 582
			p, -- 582
			self.cam, -- 582
			self.time, -- 582
			self.occlusion, -- 582
			worldDt -- 582
		) -- 582
	end -- 582
	local propsHandled = false -- 586
	do -- 586
		i = 0 -- 587
		while i < #self.plugins do -- 587
			local pl = self.plugins[i + 1] -- 588
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 588
				propsHandled = true -- 590
			end -- 590
			i = i + 1 -- 587
		end -- 587
	end -- 587
	if not propsHandled then -- 587
		self.props:drawAll( -- 594
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
	local suppressAllActors = view.visualMode == "museum" -- 598
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 599
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 603
	if not suppressAllActors then -- 603
		self.actors:drawAll( -- 612
			self.fgDraw, -- 612
			self.fgGlow, -- 612
			self.worldArt, -- 612
			p, -- 612
			self.cam, -- 612
			suppressPartner -- 612
		) -- 612
	end -- 612
	do -- 612
		i = 0 -- 614
		while i < #self.plugins do -- 614
			local pl = self.plugins[i + 1] -- 615
			if pl.drawActorsOverlay ~= nil then -- 615
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 617
			end -- 617
			i = i + 1 -- 614
		end -- 614
	end -- 614
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 622
	if view.visualMode == "pixel" then -- 622
		self.stage:drawForegroundFraming( -- 626
			self.fgDraw, -- 626
			w, -- 626
			h, -- 626
			p, -- 626
			self.cam -- 626
		) -- 626
	end -- 626
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 628
	local action = {type = "none"} -- 631
	if p.paused then -- 631
		action = self.menus:updateAndDrawPause( -- 633
			safeDt, -- 634
			input, -- 635
			self.uiDraw, -- 636
			self.uiInkDraw, -- 637
			self.uiArt, -- 638
			self.uiGlow, -- 639
			self.texts, -- 640
			uiW, -- 641
			uiH, -- 642
			uiScale, -- 643
			view.assistHintsEnabled, -- 644
			function() -- 645
				self.contract:toggleAssistHints() -- 646
			end, -- 645
			self.stageVp.safeUi -- 648
		) -- 648
	else -- 648
		local cutsceneHandled = false -- 652
		do -- 652
			i = 0 -- 653
			while i < #self.plugins do -- 653
				local pl = self.plugins[i + 1] -- 654
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 654
					self.uiDraw, -- 656
					self.uiInkDraw, -- 656
					self.uiArt, -- 656
					self.uiGlow, -- 656
					ctx -- 656
				) then -- 656
					cutsceneHandled = true -- 657
				end -- 657
				i = i + 1 -- 653
			end -- 653
		end -- 653
		if not cutsceneHandled then -- 653
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 662
			self.hud:draw( -- 663
				self.uiDraw, -- 664
				self.uiInkDraw, -- 665
				self.uiArt, -- 666
				self.uiGlow, -- 667
				self.texts, -- 668
				p, -- 669
				self.cam, -- 670
				self.vfx, -- 671
				self.narrative.letterbox, -- 672
				uiScale, -- 673
				view.assistHintsEnabled, -- 674
				true, -- 675
				input.inputMode, -- 676
				input.gamepadLayout, -- 677
				self.stageVp.safeUi, -- 678
				input.retryHoldProgress, -- 679
				touchOverlayVisible -- 680
			) -- 680
			self.narrative:draw( -- 682
				self.uiDraw, -- 683
				self.uiInkDraw, -- 684
				self.uiGlow, -- 685
				self.uiArt, -- 686
				self.texts, -- 687
				p, -- 688
				uiW, -- 689
				uiH, -- 690
				view.assistHintsEnabled, -- 691
				input.inputMode, -- 692
				input.gamepadLayout, -- 693
				self.stageVp.safeUi -- 694
			) -- 694
		end -- 694
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 698
		do -- 698
			i = 0 -- 699
			while i < #self.plugins do -- 699
				local pl = self.plugins[i + 1] -- 700
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 700
					self.uiDraw, -- 702
					self.uiInkDraw, -- 702
					self.uiArt, -- 702
					self.uiGlow, -- 702
					ctx -- 702
				) then -- 702
					suppressReticle = true -- 703
				end -- 703
				i = i + 1 -- 699
			end -- 699
		end -- 699
		if not suppressReticle then -- 699
			self.hud:drawReticleOverlay( -- 707
				self.uiInkDraw, -- 708
				self.uiArt, -- 709
				self.uiGlow, -- 710
				p, -- 711
				self.cam, -- 712
				self.vfx, -- 713
				self.narrative.letterbox, -- 714
				uiScale, -- 715
				input:isTouchMode() -- 716
			) -- 716
		end -- 716
		if view.isRehearsal then -- 716
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 722
			drawSilkVeil( -- 723
				self.uiDraw, -- 723
				self.uiArt, -- 723
				"rehearsal_tag_veil", -- 723
				uiW * 0.5, -- 723
				uiH - 22 - self.stageVp.safeUi.top, -- 723
				168, -- 723
				26, -- 723
				PALETTE.inkWarm, -- 723
				0.74, -- 723
				8 -- 723
			) -- 723
			self.texts:put( -- 724
				"xs", -- 724
				badgeText, -- 724
				uiW * 0.5, -- 724
				uiH - 22 - self.stageVp.safeUi.top, -- 724
				toColor(PALETTE.amberCore), -- 724
				0.5, -- 724
				0.5, -- 724
				"Center", -- 724
				1.2, -- 724
				0.92, -- 724
				0.08 -- 724
			) -- 724
		end -- 724
	end -- 724
	self:drawToast(uiW) -- 728
	self:finishFrame() -- 729
	return action -- 730
end -- 462
return ____exports -- 462