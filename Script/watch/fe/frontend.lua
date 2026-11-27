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
local ____roguelike_ui = require("Script.watch.fe.ui.roguelike_ui") -- 44
local RoguelikeUiPlugin = ____roguelike_ui.RoguelikeUiPlugin -- 44
____exports.WatchFrontend = __TS__Class() -- 46
local WatchFrontend = ____exports.WatchFrontend -- 46
WatchFrontend.name = "WatchFrontend" -- 46
function WatchFrontend.prototype.____constructor(self, parent) -- 85
	self.occlusion = __TS__New(DepthOcclusion) -- 47
	self.cam = __TS__New(CameraDirector) -- 62
	self.adapter = __TS__New(PlayAdapter) -- 63
	self.contract = __TS__New( -- 64
		DualRouteContract, -- 64
		function(p) return self:canPickStoryTalent(p) end -- 64
	) -- 64
	self.audio = __TS__New(AudioDirector) -- 65
	self.soundscape = __TS__New(SoundscapeDirector) -- 66
	self.stage = __TS__New(StageRenderer) -- 67
	self.props = __TS__New(PropsRenderer) -- 68
	self.actors = __TS__New(ActorsRenderer) -- 69
	self.vfx = __TS__New(VfxSystem) -- 70
	self.hud = __TS__New(HudRenderer) -- 71
	self.narrative = __TS__New(NarrativeRenderer) -- 72
	self.menus = __TS__New(MenuRenderer) -- 73
	self.plugins = {} -- 76
	self.screen = "title" -- 78
	self.time = 0 -- 79
	self.stageVp = computeStageViewport(1280, 720) -- 81
	self.toastText = "" -- 82
	self.toastTimer = 0 -- 83
	self.layerRoot = Node() -- 86
	self.layerRoot.order = 5 -- 87
	self.layerRoot:addTo(parent) -- 88
	self.audio:attachHost(self.layerRoot) -- 90
	self.menus.onUiSound = function(____, kind) -- 91
		self:playMenuUiSound(kind) -- 92
	end -- 91
	self.menus.onAudioSettingsChanged = function(____, inp) -- 94
		self.audio:applyUserVolumes(inp.settings) -- 95
	end -- 94
	local additive = BlendFunc("SrcAlpha", "One") -- 98
	self.bgDraw = DrawNode() -- 100
	self.bgDraw.order = 10 -- 101
	self.bgDraw:addTo(self.layerRoot) -- 102
	self.bgGlow = DrawNode() -- 104
	self.bgGlow.order = 15 -- 105
	self.bgGlow.blendFunc = additive -- 106
	self.bgGlow:addTo(self.layerRoot) -- 107
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 109
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 110
	self.fgDraw = DrawNode() -- 112
	self.fgDraw.order = 30 -- 113
	self.fgDraw:addTo(self.layerRoot) -- 114
	self.fgGlow = DrawNode() -- 116
	self.fgGlow.order = 35 -- 117
	self.fgGlow.blendFunc = additive -- 118
	self.fgGlow:addTo(self.layerRoot) -- 119
	self.uiLayer = Node() -- 121
	self.uiLayer.order = 40 -- 122
	self.uiLayer:addTo(self.layerRoot) -- 123
	self.uiDraw = DrawNode() -- 125
	self.uiDraw.order = 0 -- 126
	self.uiDraw:addTo(self.uiLayer) -- 127
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 129
	self.uiInkDraw = DrawNode() -- 131
	self.uiInkDraw.order = 4 -- 132
	self.uiInkDraw:addTo(self.uiLayer) -- 133
	self.uiGlow = DrawNode() -- 135
	self.uiGlow.order = 6 -- 136
	self.uiGlow.blendFunc = additive -- 137
	self.uiGlow:addTo(self.uiLayer) -- 138
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 140
	self.roguelikeUi = __TS__New( -- 144
		RoguelikeUiPlugin, -- 144
		self.contract, -- 145
		function() return self.hud.talentSelected end, -- 146
		function(idx) -- 147
			self.hud.talentSelected = idx -- 148
		end -- 147
	) -- 147
	self.hud.roguelikeUiHandled = true -- 151
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) return self.roguelikeUi:getTalentCardRects( -- 152
		w, -- 153
		h, -- 153
		count, -- 153
		touchMode, -- 153
		safeTop -- 153
	) end -- 153
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 167
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 168
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 169
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 170
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 171
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 172
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 173
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 174
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 175
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 176
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 177
end -- 85
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 181
	local i = 0 -- 182
	do -- 182
		i = 0 -- 183
		while i < #self.plugins do -- 183
			if self.plugins[i + 1].id == plugin.id then -- 183
				self.plugins[i + 1] = plugin -- 185
				self:syncRuntimeHooks() -- 186
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 186
					plugin:onBindPlay( -- 188
						self.boundPlay, -- 188
						self.contract:peekSnapshot(self.boundPlay) -- 188
					) -- 188
				end -- 188
				return -- 190
			end -- 190
			i = i + 1 -- 183
		end -- 183
	end -- 183
	local ____self_plugins_0 = self.plugins -- 183
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 193
	self:syncRuntimeHooks() -- 194
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 194
		plugin:onBindPlay( -- 196
			self.boundPlay, -- 196
			self.contract:peekSnapshot(self.boundPlay) -- 196
		) -- 196
	end -- 196
end -- 181
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 201
	local w = 0 -- 202
	local i = 0 -- 203
	do -- 203
		i = 0 -- 204
		while i < #self.plugins do -- 204
			if self.plugins[i + 1].id ~= id then -- 204
				self.plugins[w + 1] = self.plugins[i + 1] -- 206
				w = w + 1 -- 207
			end -- 207
			i = i + 1 -- 204
		end -- 204
	end -- 204
	__TS__ArraySetLength(self.plugins, w) -- 204
	self:syncRuntimeHooks() -- 211
end -- 201
function WatchFrontend.prototype.getPlugin(self, id) -- 215
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 215
		return self.roguelikeUi -- 217
	end -- 217
	local i = 0 -- 219
	do -- 219
		i = 0 -- 220
		while i < #self.plugins do -- 220
			if self.plugins[i + 1].id == id then -- 220
				return self.plugins[i + 1] -- 222
			end -- 222
			i = i + 1 -- 220
		end -- 220
	end -- 220
	return nil -- 225
end -- 215
function WatchFrontend.prototype.getPlugins(self) -- 228
	return self.plugins -- 229
end -- 228
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 237
	local g = _G -- 238
	local ____temp_1 -- 239
	if g.package ~= nil then -- 239
		____temp_1 = g.package.loaded -- 239
	else -- 239
		____temp_1 = nil -- 239
	end -- 239
	local loaded = ____temp_1 -- 239
	if loaded == nil then -- 239
		return -- 241
	end -- 241
	local rawFe = loaded["watch.fe"] -- 243
	if rawFe ~= nil and type(rawFe) == "table" then -- 243
		local watchFe = rawFe -- 245
		if watchFe.contract ~= self.contract then -- 245
			watchFe.contract = self.contract -- 247
			watchFe.audio = self.audio -- 248
			watchFe.soundscape = self.soundscape -- 249
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 250
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 251
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 252
		end -- 252
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 254
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 255
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 256
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 257
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 258
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 259
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 260
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 261
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 262
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 263
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 264
		watchFe.roguelikeUi = self.roguelikeUi -- 265
	end -- 265
end -- 237
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 269
	local scale = math.max( -- 270
		0.25, -- 270
		math.min(w / 1280, h / 720) -- 270
	) -- 270
	self.uiLayer.scaleX = scale -- 271
	self.uiLayer.scaleY = scale -- 272
	return scale -- 273
end -- 269
function WatchFrontend.prototype.setVisible(self, v) -- 277
	self.layerRoot.visible = v -- 278
	if not v then -- 278
		self.texts:hideAll() -- 280
	end -- 280
end -- 277
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 285
	self:syncRuntimeHooks() -- 286
	self.boundPlay = p -- 287
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 288
	self.cam:snap(p, w, h) -- 289
	self.adapter:reset(p) -- 290
	self.contract:resetForRoom(p) -- 291
	self.audio:stopRoomTransient() -- 292
	self.soundscape:resetForRoom(p) -- 293
	self.actors:reset(p) -- 294
	self.occlusion:reset() -- 295
	self.vfx:reset() -- 296
	self.hud:reset(p) -- 297
	self.narrative:onEnterRoom(p.room.key) -- 298
	local initView = self.contract:peekSnapshot(p) -- 300
	if #self.plugins > 0 then -- 300
		local i = 0 -- 302
		do -- 302
			i = 0 -- 303
			while i < #self.plugins do -- 303
				local pl = self.plugins[i + 1] -- 304
				if pl.onBindPlay ~= nil then -- 304
					pl:onBindPlay(p, initView) -- 306
				end -- 306
				i = i + 1 -- 303
			end -- 303
		end -- 303
	end -- 303
	self.roguelikeUi:onBindPlay(p, initView) -- 310
end -- 285
function WatchFrontend.prototype.clearAll(self) -- 313
	self.bgDraw:clear() -- 314
	self.bgGlow:clear() -- 315
	self.fgDraw:clear() -- 316
	self.fgGlow:clear() -- 317
	self.uiDraw:clear() -- 318
	self.uiInkDraw:clear() -- 319
	self.uiGlow:clear() -- 320
	self.backdropArt:beginFrame() -- 321
	self.worldArt:beginFrame() -- 322
	self.uiArt:beginFrame() -- 323
	self.texts:beginFrame() -- 324
end -- 313
function WatchFrontend.prototype.finishFrame(self) -- 327
	self.backdropArt:endFrame() -- 328
	self.worldArt:endFrame() -- 329
	self.uiArt:endFrame() -- 330
	self.texts:endFrame() -- 331
end -- 327
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 335
	self.stageVp = vp -- 336
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 337
end -- 335
function WatchFrontend.prototype.showToast(self, text, duration) -- 341
	if duration == nil then -- 341
		duration = 1.8 -- 341
	end -- 341
	self.toastText = text -- 342
	self.toastTimer = duration -- 343
end -- 341
function WatchFrontend.prototype.getToastText(self) -- 346
	return self.toastTimer > 0 and self.toastText or "" -- 347
end -- 346
function WatchFrontend.prototype.drawToast(self, uiW) -- 350
	if self.toastTimer <= 0 or self.toastText == "" then -- 350
		return -- 352
	end -- 352
	local alpha = math.min(1, self.toastTimer * 2.4) -- 354
	local cx = uiW * 0.5 -- 355
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 356
	drawSilkVeil( -- 357
		self.uiDraw, -- 357
		self.uiArt, -- 357
		"fe_toast_veil", -- 357
		cx, -- 357
		cy, -- 357
		340, -- 357
		38, -- 357
		PALETTE.inkWarm, -- 357
		0.86 * alpha, -- 357
		9 -- 357
	) -- 357
	self.texts:put( -- 358
		"sm", -- 358
		self.toastText, -- 358
		cx, -- 358
		cy, -- 358
		toColor(PALETTE.amberCore), -- 358
		0.5, -- 358
		0.5, -- 358
		"Center", -- 358
		1.4, -- 358
		0.96 * alpha, -- 358
		0.08 -- 358
	) -- 358
end -- 350
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 361
	return not p.paused and not p.craftBench.active and not p.reloadOpen and self.roguelikeUi:canPickTalent() -- 362
end -- 361
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 366
	local offers = p:getStoryTalentOffers() -- 367
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 367
		return {} -- 369
	end -- 369
	local uiScale = math.max( -- 371
		0.25, -- 371
		math.min(w / 1280, h / 720) -- 371
	) -- 371
	return self.hud:talentCardRects( -- 372
		w / uiScale, -- 372
		h / uiScale, -- 372
		#offers, -- 372
		touchMode, -- 372
		self.stageVp.safeUi.top -- 372
	) -- 372
end -- 366
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 375
	if kind == "hover" then -- 375
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 377
	elseif kind == "confirm" then -- 377
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 379
	elseif kind == "back" then -- 379
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 381
	elseif kind == "start" then -- 381
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 383
	elseif kind == "pauseOpen" then -- 383
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 385
	elseif kind == "pauseClose" then -- 385
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 387
	elseif kind == "toggle" then -- 387
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 389
	end -- 389
end -- 375
function WatchFrontend.prototype.resetTrialAudio(self, p) -- 394
	self.adapter:reset(p) -- 395
	self.audio:stopRoomTransient() -- 396
	self.soundscape:resetForRoom(p) -- 397
end -- 394
function WatchFrontend.prototype.syncTrialAudio(self, dt, p, offerCount) -- 401
	local safeDt = math.min( -- 402
		0.05, -- 402
		math.max(0.001, dt) -- 402
	) -- 402
	self.audio:setPaused(p.paused) -- 403
	self.audio:setCameraRef(p.player.x, 960) -- 404
	self.audio:update(safeDt) -- 405
	if not p.paused then -- 405
		local ev = self.adapter:sample(p) -- 407
		self.audio:ingestEvents(ev, p) -- 408
		self.soundscape:updateTrial(safeDt, p, self.audio, offerCount) -- 409
	end -- 409
end -- 401
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 414
	self:syncRuntimeHooks() -- 415
	local safeDt = math.min( -- 416
		0.05, -- 416
		math.max(0, dt) -- 416
	) -- 416
	if self.toastTimer > 0 then -- 416
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 418
	end -- 418
	if self.screen == "title" and self.boundPlay ~= nil then -- 418
		self.audio:stopRoomTransient() -- 421
		self.boundPlay = nil -- 422
	end -- 422
	self.audio:update(safeDt) -- 424
	self.soundscape:updateMenu(self.screen, self.audio) -- 425
	self:setVisible(true) -- 426
	self:clearAll() -- 427
	local uiScale = self:resizeInterface(w, h) -- 428
	local act = self.menus:updateAndDrawScreen( -- 429
		dt, -- 430
		self.screen, -- 431
		input, -- 432
		self.stage, -- 433
		self.bgDraw, -- 434
		self.bgGlow, -- 435
		self.backdropArt, -- 436
		self.uiArt, -- 437
		self.uiDraw, -- 438
		self.uiInkDraw, -- 439
		self.uiGlow, -- 440
		self.texts, -- 441
		w, -- 442
		h, -- 443
		uiScale, -- 444
		self.stageVp.safeUi -- 445
	) -- 445
	self:drawToast(w / uiScale) -- 447
	self:finishFrame() -- 448
	return act -- 449
end -- 414
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 453
	local offers = p:getStoryTalentOffers() -- 454
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 454
		return false -- 456
	end -- 456
	if input.inputMode == "gamepad" and not input.uiPressed then -- 456
		return false -- 459
	end -- 459
	local useUiPtr = input.uiInside or input.uiPressed -- 461
	local ____useUiPtr_2 -- 462
	if useUiPtr then -- 462
		____useUiPtr_2 = input.uiInside -- 462
	else -- 462
		____useUiPtr_2 = input.inside -- 462
	end -- 462
	local inside = ____useUiPtr_2 -- 462
	if not inside then -- 462
		return false -- 464
	end -- 464
	local uiScale = math.max( -- 466
		0.25, -- 466
		math.min(w / 1280, h / 720) -- 466
	) -- 466
	local uiW = w / uiScale -- 467
	local uiH = h / uiScale -- 468
	local rawX = useUiPtr and input.uiX or input.mx -- 469
	local rawY = useUiPtr and input.uiY or input.my -- 470
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 471
	local boxes = self.hud:talentCardRects( -- 472
		uiW, -- 472
		uiH, -- 472
		#offers, -- 472
		input:isTouchMode(), -- 472
		self.stageVp.safeUi.top -- 472
	) -- 472
	local i = 0 -- 473
	do -- 473
		i = 0 -- 474
		while i < #boxes do -- 474
			if boxes[i + 1]:containsPoint(pointer) then -- 474
				return p:chooseTalent(i) -- 476
			end -- 476
			i = i + 1 -- 474
		end -- 474
	end -- 474
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 480
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 481
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 482
end -- 453
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 487
	self:syncRuntimeHooks() -- 488
	self:setVisible(true) -- 489
	if self.boundPlay ~= p then -- 489
		self:bindPlay(p, w, h) -- 491
	end -- 491
	local safeDt = math.min( -- 493
		0.05, -- 493
		math.max(0.001, dt) -- 493
	) -- 493
	if self.toastTimer > 0 then -- 493
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 495
	end -- 495
	self.audio:setPaused(p.paused) -- 497
	self.audio:setCameraRef( -- 498
		self.cam.x, -- 498
		w / math.max(0.25, self.cam.ppu) -- 498
	) -- 498
	self.audio:update(safeDt) -- 499
	local ev -- 501
	local worldDt = 0 -- 502
	local uiDt = 0 -- 503
	if not p.paused then -- 503
		ev = self.adapter:sample(p) -- 507
		self.vfx:ingest(ev, p, self.cam) -- 508
		self.audio:ingestEvents(ev, p) -- 509
		local touch = input:getTouch() -- 510
		if touch ~= nil then -- 510
			if ev.playerHit then -- 510
				touch:vibrate(0.036) -- 513
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 513
				touch:vibrate(0.024) -- 515
			elseif ev.coverDeflect then -- 515
				touch:vibrate(0.018) -- 517
			elseif ev.knockPulse then -- 517
				touch:vibrate(0.014) -- 519
			end -- 519
		end -- 519
	else -- 519
		ev = self.adapter:emptyFrame(p) -- 524
		self.narrative.wipeT = 0 -- 525
	end -- 525
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 528
	if not p.paused then -- 528
		local clampedScale = math.max( -- 530
			0, -- 530
			math.min(2, view.timeScale) -- 530
		) -- 530
		uiDt = safeDt -- 531
		worldDt = safeDt * clampedScale -- 532
	end -- 532
	local uiScale = self:resizeInterface(w, h) -- 535
	local uiW = w / uiScale -- 536
	local uiH = h / uiScale -- 537
	local ctx = { -- 539
		p = p, -- 540
		view = view, -- 541
		events = ev, -- 542
		input = input, -- 543
		cam = self.cam, -- 544
		audio = self.audio, -- 545
		assets = self.worldArt, -- 546
		backdropArt = self.backdropArt, -- 547
		worldArt = self.worldArt, -- 548
		uiArt = self.uiArt, -- 549
		texts = self.texts, -- 550
		worldDt = worldDt, -- 551
		uiDt = uiDt, -- 552
		w = w, -- 553
		h = h, -- 554
		uiW = uiW, -- 555
		uiH = uiH, -- 556
		uiScale = uiScale, -- 557
		safeUi = self.stageVp.safeUi, -- 558
		paused = p.paused -- 559
	} -- 559
	local i = 0 -- 563
	do -- 563
		i = 0 -- 564
		while i < #self.plugins do -- 564
			local pl = self.plugins[i + 1] -- 565
			if pl.update ~= nil then -- 565
				pl:update(ctx) -- 567
			end -- 567
			i = i + 1 -- 564
		end -- 564
	end -- 564
	self.roguelikeUi:update(ctx) -- 570
	if not p.paused then -- 570
		self.time = self.time + worldDt -- 573
		self.cam:update(worldDt, p, w, h) -- 574
		self.audio:setCameraRef( -- 575
			self.cam.x, -- 575
			w / math.max(0.25, self.cam.ppu) -- 575
		) -- 575
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 576
		self.actors:update(worldDt, p) -- 577
		self.vfx:update( -- 578
			worldDt, -- 578
			themeOf(p.room.key).ambient -- 578
		) -- 578
		self.hud:update(safeDt, p) -- 579
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 580
	else -- 580
		self.cam:update(0, p, w, h) -- 582
	end -- 582
	self:clearAll() -- 585
	local backdropHandled = false -- 588
	do -- 588
		i = 0 -- 589
		while i < #self.plugins do -- 589
			local pl = self.plugins[i + 1] -- 590
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 590
				backdropHandled = true -- 592
			end -- 592
			i = i + 1 -- 589
		end -- 589
	end -- 589
	if not backdropHandled then -- 589
		self.stage:drawBackdrop( -- 596
			self.bgDraw, -- 596
			self.bgGlow, -- 596
			self.backdropArt, -- 596
			p, -- 596
			self.cam, -- 596
			self.time -- 596
		) -- 596
	end -- 596
	local worldHandled = false -- 600
	do -- 600
		i = 0 -- 601
		while i < #self.plugins do -- 601
			local pl = self.plugins[i + 1] -- 602
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 602
				worldHandled = true -- 604
			end -- 604
			i = i + 1 -- 601
		end -- 601
	end -- 601
	if not worldHandled then -- 601
		self.stage:drawPlayableWorld( -- 608
			self.fgDraw, -- 608
			self.fgGlow, -- 608
			self.worldArt, -- 608
			p, -- 608
			self.cam, -- 608
			self.time, -- 608
			self.occlusion, -- 608
			worldDt -- 608
		) -- 608
	end -- 608
	local propsHandled = false -- 612
	do -- 612
		i = 0 -- 613
		while i < #self.plugins do -- 613
			local pl = self.plugins[i + 1] -- 614
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 614
				propsHandled = true -- 616
			end -- 616
			i = i + 1 -- 613
		end -- 613
	end -- 613
	if not propsHandled then -- 613
		self.props:drawAll( -- 620
			self.fgDraw, -- 620
			self.fgGlow, -- 620
			self.worldArt, -- 620
			p, -- 620
			self.cam, -- 620
			self.time, -- 620
			self.occlusion, -- 620
			worldDt -- 620
		) -- 620
	end -- 620
	local suppressAllActors = view.visualMode == "museum" -- 624
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 625
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 629
	if not suppressAllActors then -- 629
		self.actors:drawAll( -- 638
			self.fgDraw, -- 638
			self.fgGlow, -- 638
			self.worldArt, -- 638
			p, -- 638
			self.cam, -- 638
			suppressPartner -- 638
		) -- 638
	end -- 638
	do -- 638
		i = 0 -- 640
		while i < #self.plugins do -- 640
			local pl = self.plugins[i + 1] -- 641
			if pl.drawActorsOverlay ~= nil then -- 641
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 643
			end -- 643
			i = i + 1 -- 640
		end -- 640
	end -- 640
	self.roguelikeUi:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 646
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 649
	if view.visualMode == "pixel" then -- 649
		self.stage:drawForegroundFraming( -- 653
			self.fgDraw, -- 653
			w, -- 653
			h, -- 653
			p, -- 653
			self.cam -- 653
		) -- 653
	end -- 653
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 655
	local action = {type = "none"} -- 658
	if p.paused then -- 658
		action = self.menus:updateAndDrawPause( -- 660
			safeDt, -- 661
			input, -- 662
			self.uiDraw, -- 663
			self.uiInkDraw, -- 664
			self.uiArt, -- 665
			self.uiGlow, -- 666
			self.texts, -- 667
			uiW, -- 668
			uiH, -- 669
			uiScale, -- 670
			view.assistHintsEnabled, -- 671
			function() -- 672
				self.contract:toggleAssistHints() -- 673
			end, -- 672
			self.stageVp.safeUi, -- 675
			view.roguelike.active, -- 676
			function() -- 677
				self.roguelikeUi:openLedger() -- 678
			end -- 677
		) -- 677
	else -- 677
		local cutsceneHandled = false -- 683
		do -- 683
			i = 0 -- 684
			while i < #self.plugins do -- 684
				local pl = self.plugins[i + 1] -- 685
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 685
					self.uiDraw, -- 687
					self.uiInkDraw, -- 687
					self.uiArt, -- 687
					self.uiGlow, -- 687
					ctx -- 687
				) then -- 687
					cutsceneHandled = true -- 688
				end -- 688
				i = i + 1 -- 684
			end -- 684
		end -- 684
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 692
		if not cutsceneHandled and not roguelikeModal then -- 692
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 694
			self.hud:draw( -- 695
				self.uiDraw, -- 696
				self.uiInkDraw, -- 697
				self.uiArt, -- 698
				self.uiGlow, -- 699
				self.texts, -- 700
				p, -- 701
				self.cam, -- 702
				self.vfx, -- 703
				self.narrative.letterbox, -- 704
				uiScale, -- 705
				view.assistHintsEnabled, -- 706
				true, -- 707
				input.inputMode, -- 708
				input.gamepadLayout, -- 709
				self.stageVp.safeUi, -- 710
				input.retryHoldProgress, -- 711
				touchOverlayVisible -- 712
			) -- 712
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 714
			local savedBannerT = self.narrative.bannerT -- 715
			if suppressBanner then -- 715
				self.narrative.bannerT = 0 -- 717
			end -- 717
			self.narrative:draw( -- 719
				self.uiDraw, -- 720
				self.uiInkDraw, -- 721
				self.uiGlow, -- 722
				self.uiArt, -- 723
				self.texts, -- 724
				p, -- 725
				uiW, -- 726
				uiH, -- 727
				view.assistHintsEnabled, -- 728
				input.inputMode, -- 729
				input.gamepadLayout, -- 730
				self.stageVp.safeUi -- 731
			) -- 731
			if suppressBanner then -- 731
				self.narrative.bannerT = savedBannerT -- 734
			end -- 734
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
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 739
			self.uiDraw, -- 747
			self.uiInkDraw, -- 747
			self.uiArt, -- 747
			self.uiGlow, -- 747
			ctx -- 747
		) then -- 747
			suppressReticle = true -- 748
		end -- 748
		if not suppressReticle then -- 748
			self.hud:drawReticleOverlay( -- 751
				self.uiInkDraw, -- 752
				self.uiArt, -- 753
				self.uiGlow, -- 754
				p, -- 755
				self.cam, -- 756
				self.vfx, -- 757
				self.narrative.letterbox, -- 758
				uiScale, -- 759
				input:isTouchMode() -- 760
			) -- 760
		end -- 760
		if view.isRehearsal then -- 760
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 766
			drawSilkVeil( -- 767
				self.uiDraw, -- 767
				self.uiArt, -- 767
				"rehearsal_tag_veil", -- 767
				uiW * 0.5, -- 767
				uiH - 22 - self.stageVp.safeUi.top, -- 767
				168, -- 767
				26, -- 767
				PALETTE.inkWarm, -- 767
				0.74, -- 767
				8 -- 767
			) -- 767
			self.texts:put( -- 768
				"xs", -- 768
				badgeText, -- 768
				uiW * 0.5, -- 768
				uiH - 22 - self.stageVp.safeUi.top, -- 768
				toColor(PALETTE.amberCore), -- 768
				0.5, -- 768
				0.5, -- 768
				"Center", -- 768
				1.2, -- 768
				0.92, -- 768
				0.08 -- 768
			) -- 768
		end -- 768
	end -- 768
	self:drawToast(uiW) -- 772
	self:finishFrame() -- 773
	return action -- 774
end -- 487
return ____exports -- 487