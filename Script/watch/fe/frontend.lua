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
	self:syncRuntimeHooks() -- 267
	self.boundPlay = p -- 268
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 269
	self.cam:snap(p, w, h) -- 270
	self.adapter:reset(p) -- 271
	self.contract:resetForRoom(p) -- 272
	self.audio:stopRoomTransient() -- 273
	self.soundscape:resetForRoom(p) -- 274
	self.actors:reset(p) -- 275
	self.occlusion:reset() -- 276
	self.vfx:reset() -- 277
	self.hud:reset(p) -- 278
	self.narrative:onEnterRoom(p.room.key) -- 279
	if #self.plugins > 0 then -- 279
		local initView = self.contract:peekSnapshot(p) -- 282
		local i = 0 -- 283
		do -- 283
			i = 0 -- 284
			while i < #self.plugins do -- 284
				local pl = self.plugins[i + 1] -- 285
				if pl.onBindPlay ~= nil then -- 285
					pl:onBindPlay(p, initView) -- 287
				end -- 287
				i = i + 1 -- 284
			end -- 284
		end -- 284
	end -- 284
end -- 266
function WatchFrontend.prototype.clearAll(self) -- 293
	self.bgDraw:clear() -- 294
	self.bgGlow:clear() -- 295
	self.fgDraw:clear() -- 296
	self.fgGlow:clear() -- 297
	self.uiDraw:clear() -- 298
	self.uiInkDraw:clear() -- 299
	self.uiGlow:clear() -- 300
	self.backdropArt:beginFrame() -- 301
	self.worldArt:beginFrame() -- 302
	self.uiArt:beginFrame() -- 303
	self.texts:beginFrame() -- 304
end -- 293
function WatchFrontend.prototype.finishFrame(self) -- 307
	self.backdropArt:endFrame() -- 308
	self.worldArt:endFrame() -- 309
	self.uiArt:endFrame() -- 310
	self.texts:endFrame() -- 311
end -- 307
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 315
	self.stageVp = vp -- 316
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 317
end -- 315
function WatchFrontend.prototype.showToast(self, text, duration) -- 321
	if duration == nil then -- 321
		duration = 1.8 -- 321
	end -- 321
	self.toastText = text -- 322
	self.toastTimer = duration -- 323
end -- 321
function WatchFrontend.prototype.getToastText(self) -- 326
	return self.toastTimer > 0 and self.toastText or "" -- 327
end -- 326
function WatchFrontend.prototype.drawToast(self, uiW) -- 330
	if self.toastTimer <= 0 or self.toastText == "" then -- 330
		return -- 332
	end -- 332
	local alpha = math.min(1, self.toastTimer * 2.4) -- 334
	local cx = uiW * 0.5 -- 335
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 336
	drawSilkVeil( -- 337
		self.uiDraw, -- 337
		self.uiArt, -- 337
		"fe_toast_veil", -- 337
		cx, -- 337
		cy, -- 337
		340, -- 337
		38, -- 337
		PALETTE.inkWarm, -- 337
		0.86 * alpha, -- 337
		9 -- 337
	) -- 337
	self.texts:put( -- 338
		"sm", -- 338
		self.toastText, -- 338
		cx, -- 338
		cy, -- 338
		toColor(PALETTE.amberCore), -- 338
		0.5, -- 338
		0.5, -- 338
		"Center", -- 338
		1.4, -- 338
		0.96 * alpha, -- 338
		0.08 -- 338
	) -- 338
end -- 330
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 342
	local offers = p:getStoryTalentOffers() -- 343
	if #offers == 0 then -- 343
		return {} -- 345
	end -- 345
	local uiScale = math.max( -- 347
		0.25, -- 347
		math.min(w / 1280, h / 720) -- 347
	) -- 347
	return self.hud:talentCardRects( -- 348
		w / uiScale, -- 348
		h / uiScale, -- 348
		#offers, -- 348
		touchMode, -- 348
		self.stageVp.safeUi.top -- 348
	) -- 348
end -- 342
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 351
	if kind == "hover" then -- 351
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 353
	elseif kind == "confirm" then -- 353
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 355
	elseif kind == "back" then -- 355
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 357
	elseif kind == "start" then -- 357
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 359
	elseif kind == "pauseOpen" then -- 359
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 361
	elseif kind == "pauseClose" then -- 361
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 363
	elseif kind == "toggle" then -- 363
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 365
	end -- 365
end -- 351
function WatchFrontend.prototype.resetTrialAudio(self, p) -- 370
	self.adapter:reset(p) -- 371
	self.audio:stopRoomTransient() -- 372
	self.soundscape:resetForRoom(p) -- 373
end -- 370
function WatchFrontend.prototype.syncTrialAudio(self, dt, p, offerCount) -- 377
	local safeDt = math.min( -- 378
		0.05, -- 378
		math.max(0.001, dt) -- 378
	) -- 378
	self.audio:setPaused(p.paused) -- 379
	self.audio:setCameraRef(p.player.x, 960) -- 380
	self.audio:update(safeDt) -- 381
	if not p.paused then -- 381
		local ev = self.adapter:sample(p) -- 383
		self.audio:ingestEvents(ev, p) -- 384
		self.soundscape:updateTrial(safeDt, p, self.audio, offerCount) -- 385
	end -- 385
end -- 377
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 390
	self:syncRuntimeHooks() -- 391
	local safeDt = math.min( -- 392
		0.05, -- 392
		math.max(0, dt) -- 392
	) -- 392
	if self.toastTimer > 0 then -- 392
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 394
	end -- 394
	if self.screen == "title" and self.boundPlay ~= nil then -- 394
		self.audio:stopRoomTransient() -- 397
		self.boundPlay = nil -- 398
	end -- 398
	self.audio:update(safeDt) -- 400
	self.soundscape:updateMenu(self.screen, self.audio) -- 401
	self:setVisible(true) -- 402
	self:clearAll() -- 403
	local uiScale = self:resizeInterface(w, h) -- 404
	local act = self.menus:updateAndDrawScreen( -- 405
		dt, -- 406
		self.screen, -- 407
		input, -- 408
		self.stage, -- 409
		self.bgDraw, -- 410
		self.bgGlow, -- 411
		self.backdropArt, -- 412
		self.uiArt, -- 413
		self.uiDraw, -- 414
		self.uiInkDraw, -- 415
		self.uiGlow, -- 416
		self.texts, -- 417
		w, -- 418
		h, -- 419
		uiScale, -- 420
		self.stageVp.safeUi -- 421
	) -- 421
	self:drawToast(w / uiScale) -- 423
	self:finishFrame() -- 424
	return act -- 425
end -- 390
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 429
	local offers = p:getStoryTalentOffers() -- 430
	if #offers == 0 then -- 430
		return false -- 432
	end -- 432
	local useUiPtr = input.uiInside or input.uiPressed -- 434
	local ____useUiPtr_2 -- 435
	if useUiPtr then -- 435
		____useUiPtr_2 = input.uiInside -- 435
	else -- 435
		____useUiPtr_2 = input.inside -- 435
	end -- 435
	local inside = ____useUiPtr_2 -- 435
	if not inside then -- 435
		return false -- 437
	end -- 437
	local uiScale = math.max( -- 439
		0.25, -- 439
		math.min(w / 1280, h / 720) -- 439
	) -- 439
	local uiW = w / uiScale -- 440
	local uiH = h / uiScale -- 441
	local rawX = useUiPtr and input.uiX or input.mx -- 442
	local rawY = useUiPtr and input.uiY or input.my -- 443
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 444
	local boxes = self.hud:talentCardRects( -- 445
		uiW, -- 445
		uiH, -- 445
		#offers, -- 445
		input:isTouchMode(), -- 445
		self.stageVp.safeUi.top -- 445
	) -- 445
	local i = 0 -- 446
	do -- 446
		i = 0 -- 447
		while i < #boxes do -- 447
			if boxes[i + 1]:containsPoint(pointer) then -- 447
				return p:chooseTalent(i) -- 449
			end -- 449
			i = i + 1 -- 447
		end -- 447
	end -- 447
	return false -- 452
end -- 429
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 456
	self:syncRuntimeHooks() -- 457
	self:setVisible(true) -- 458
	if self.boundPlay ~= p then -- 458
		self:bindPlay(p, w, h) -- 460
	end -- 460
	local safeDt = math.min( -- 462
		0.05, -- 462
		math.max(0.001, dt) -- 462
	) -- 462
	if self.toastTimer > 0 then -- 462
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 464
	end -- 464
	self.audio:setPaused(p.paused) -- 466
	self.audio:setCameraRef( -- 467
		self.cam.x, -- 467
		w / math.max(0.25, self.cam.ppu) -- 467
	) -- 467
	self.audio:update(safeDt) -- 468
	local ev -- 470
	local worldDt = 0 -- 471
	local uiDt = 0 -- 472
	if not p.paused then -- 472
		ev = self.adapter:sample(p) -- 476
		self.vfx:ingest(ev, p, self.cam) -- 477
		self.audio:ingestEvents(ev, p) -- 478
		local touch = input:getTouch() -- 479
		if touch ~= nil then -- 479
			if ev.playerHit then -- 479
				touch:vibrate(0.036) -- 482
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 482
				touch:vibrate(0.024) -- 484
			elseif ev.coverDeflect then -- 484
				touch:vibrate(0.018) -- 486
			elseif ev.knockPulse then -- 486
				touch:vibrate(0.014) -- 488
			end -- 488
		end -- 488
	else -- 488
		ev = self.adapter:emptyFrame(p) -- 493
		self.narrative.wipeT = 0 -- 494
	end -- 494
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 497
	if not p.paused then -- 497
		local clampedScale = math.max( -- 499
			0, -- 499
			math.min(2, view.timeScale) -- 499
		) -- 499
		uiDt = safeDt -- 500
		worldDt = safeDt * clampedScale -- 501
	end -- 501
	local uiScale = self:resizeInterface(w, h) -- 504
	local uiW = w / uiScale -- 505
	local uiH = h / uiScale -- 506
	local ctx = { -- 508
		p = p, -- 509
		view = view, -- 510
		events = ev, -- 511
		input = input, -- 512
		cam = self.cam, -- 513
		audio = self.audio, -- 514
		assets = self.worldArt, -- 515
		backdropArt = self.backdropArt, -- 516
		worldArt = self.worldArt, -- 517
		uiArt = self.uiArt, -- 518
		texts = self.texts, -- 519
		worldDt = worldDt, -- 520
		uiDt = uiDt, -- 521
		w = w, -- 522
		h = h, -- 523
		uiW = uiW, -- 524
		uiH = uiH, -- 525
		uiScale = uiScale, -- 526
		safeUi = self.stageVp.safeUi, -- 527
		paused = p.paused -- 528
	} -- 528
	local i = 0 -- 532
	do -- 532
		i = 0 -- 533
		while i < #self.plugins do -- 533
			local pl = self.plugins[i + 1] -- 534
			if pl.update ~= nil then -- 534
				pl:update(ctx) -- 536
			end -- 536
			i = i + 1 -- 533
		end -- 533
	end -- 533
	if not p.paused then -- 533
		self.time = self.time + worldDt -- 541
		self.cam:update(worldDt, p, w, h) -- 542
		self.audio:setCameraRef( -- 543
			self.cam.x, -- 543
			w / math.max(0.25, self.cam.ppu) -- 543
		) -- 543
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 544
		self.actors:update(worldDt, p) -- 545
		self.vfx:update( -- 546
			worldDt, -- 546
			themeOf(p.room.key).ambient -- 546
		) -- 546
		self.hud:update(worldDt, p) -- 547
		self.narrative:update(worldDt, p) -- 548
	else -- 548
		self.cam:update(0, p, w, h) -- 550
	end -- 550
	self:clearAll() -- 553
	local backdropHandled = false -- 556
	do -- 556
		i = 0 -- 557
		while i < #self.plugins do -- 557
			local pl = self.plugins[i + 1] -- 558
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 558
				backdropHandled = true -- 560
			end -- 560
			i = i + 1 -- 557
		end -- 557
	end -- 557
	if not backdropHandled then -- 557
		self.stage:drawBackdrop( -- 564
			self.bgDraw, -- 564
			self.bgGlow, -- 564
			self.backdropArt, -- 564
			p, -- 564
			self.cam, -- 564
			self.time -- 564
		) -- 564
	end -- 564
	local worldHandled = false -- 568
	do -- 568
		i = 0 -- 569
		while i < #self.plugins do -- 569
			local pl = self.plugins[i + 1] -- 570
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 570
				worldHandled = true -- 572
			end -- 572
			i = i + 1 -- 569
		end -- 569
	end -- 569
	if not worldHandled then -- 569
		self.stage:drawPlayableWorld( -- 576
			self.fgDraw, -- 576
			self.fgGlow, -- 576
			self.worldArt, -- 576
			p, -- 576
			self.cam, -- 576
			self.time, -- 576
			self.occlusion, -- 576
			worldDt -- 576
		) -- 576
	end -- 576
	local propsHandled = false -- 580
	do -- 580
		i = 0 -- 581
		while i < #self.plugins do -- 581
			local pl = self.plugins[i + 1] -- 582
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 582
				propsHandled = true -- 584
			end -- 584
			i = i + 1 -- 581
		end -- 581
	end -- 581
	if not propsHandled then -- 581
		self.props:drawAll( -- 588
			self.fgDraw, -- 588
			self.fgGlow, -- 588
			self.worldArt, -- 588
			p, -- 588
			self.cam, -- 588
			self.time, -- 588
			self.occlusion, -- 588
			worldDt -- 588
		) -- 588
	end -- 588
	local suppressAllActors = view.visualMode == "museum" -- 592
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 593
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 597
	if not suppressAllActors then -- 597
		self.actors:drawAll( -- 606
			self.fgDraw, -- 606
			self.fgGlow, -- 606
			self.worldArt, -- 606
			p, -- 606
			self.cam, -- 606
			suppressPartner -- 606
		) -- 606
	end -- 606
	do -- 606
		i = 0 -- 608
		while i < #self.plugins do -- 608
			local pl = self.plugins[i + 1] -- 609
			if pl.drawActorsOverlay ~= nil then -- 609
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 611
			end -- 611
			i = i + 1 -- 608
		end -- 608
	end -- 608
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 616
	self.stage:drawForegroundFraming( -- 619
		self.fgDraw, -- 619
		w, -- 619
		h, -- 619
		p, -- 619
		self.cam -- 619
	) -- 619
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 620
	local action = {type = "none"} -- 623
	if p.paused then -- 623
		action = self.menus:updateAndDrawPause( -- 625
			safeDt, -- 626
			input, -- 627
			self.uiDraw, -- 628
			self.uiInkDraw, -- 629
			self.uiArt, -- 630
			self.uiGlow, -- 631
			self.texts, -- 632
			uiW, -- 633
			uiH, -- 634
			uiScale, -- 635
			view.assistHintsEnabled, -- 636
			function() -- 637
				self.contract:toggleAssistHints() -- 638
			end, -- 637
			self.stageVp.safeUi -- 640
		) -- 640
	else -- 640
		local cutsceneHandled = false -- 644
		do -- 644
			i = 0 -- 645
			while i < #self.plugins do -- 645
				local pl = self.plugins[i + 1] -- 646
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 646
					self.uiDraw, -- 648
					self.uiInkDraw, -- 648
					self.uiArt, -- 648
					self.uiGlow, -- 648
					ctx -- 648
				) then -- 648
					cutsceneHandled = true -- 649
				end -- 649
				i = i + 1 -- 645
			end -- 645
		end -- 645
		if not cutsceneHandled then -- 645
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 654
			self.hud:draw( -- 655
				self.uiDraw, -- 656
				self.uiInkDraw, -- 657
				self.uiArt, -- 658
				self.uiGlow, -- 659
				self.texts, -- 660
				p, -- 661
				self.cam, -- 662
				self.vfx, -- 663
				self.narrative.letterbox, -- 664
				uiScale, -- 665
				view.assistHintsEnabled, -- 666
				true, -- 667
				input.inputMode, -- 668
				input.gamepadLayout, -- 669
				self.stageVp.safeUi, -- 670
				input.retryHoldProgress, -- 671
				touchOverlayVisible -- 672
			) -- 672
			self.narrative:draw( -- 674
				self.uiDraw, -- 675
				self.uiInkDraw, -- 676
				self.uiGlow, -- 677
				self.uiArt, -- 678
				self.texts, -- 679
				p, -- 680
				uiW, -- 681
				uiH, -- 682
				view.assistHintsEnabled, -- 683
				input.inputMode, -- 684
				input.gamepadLayout, -- 685
				self.stageVp.safeUi -- 686
			) -- 686
		end -- 686
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 690
		do -- 690
			i = 0 -- 691
			while i < #self.plugins do -- 691
				local pl = self.plugins[i + 1] -- 692
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 692
					self.uiDraw, -- 694
					self.uiInkDraw, -- 694
					self.uiArt, -- 694
					self.uiGlow, -- 694
					ctx -- 694
				) then -- 694
					suppressReticle = true -- 695
				end -- 695
				i = i + 1 -- 691
			end -- 691
		end -- 691
		if not suppressReticle then -- 691
			self.hud:drawReticleOverlay( -- 699
				self.uiInkDraw, -- 700
				self.uiArt, -- 701
				self.uiGlow, -- 702
				p, -- 703
				self.cam, -- 704
				self.vfx, -- 705
				self.narrative.letterbox, -- 706
				uiScale, -- 707
				input:isTouchMode() -- 708
			) -- 708
		end -- 708
		if view.isRehearsal then -- 708
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 714
			drawSilkVeil( -- 715
				self.uiDraw, -- 715
				self.uiArt, -- 715
				"rehearsal_tag_veil", -- 715
				uiW * 0.5, -- 715
				uiH - 22 - self.stageVp.safeUi.top, -- 715
				168, -- 715
				26, -- 715
				PALETTE.inkWarm, -- 715
				0.74, -- 715
				8 -- 715
			) -- 715
			self.texts:put( -- 716
				"xs", -- 716
				badgeText, -- 716
				uiW * 0.5, -- 716
				uiH - 22 - self.stageVp.safeUi.top, -- 716
				toColor(PALETTE.amberCore), -- 716
				0.5, -- 716
				0.5, -- 716
				"Center", -- 716
				1.2, -- 716
				0.92, -- 716
				0.08 -- 716
			) -- 716
		end -- 716
	end -- 716
	self:drawToast(uiW) -- 720
	self:finishFrame() -- 721
	return action -- 722
end -- 456
return ____exports -- 456