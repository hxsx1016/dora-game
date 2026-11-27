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
	self.contract = __TS__New(DualRouteContract) -- 64
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
	) end -- 152
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
			if self.plugins[i + 1].id == plugin.id then -- 184
				self.plugins[i + 1] = plugin -- 185
				self:syncRuntimeHooks() -- 186
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 187
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
	local ____self_plugins_0 = self.plugins -- 193
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 193
	self:syncRuntimeHooks() -- 194
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 195
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
			if self.plugins[i + 1].id ~= id then -- 205
				self.plugins[w + 1] = self.plugins[i + 1] -- 206
				w = w + 1 -- 207
			end -- 207
			i = i + 1 -- 204
		end -- 204
	end -- 204
	__TS__ArraySetLength(self.plugins, w) -- 210
	self:syncRuntimeHooks() -- 211
end -- 201
function WatchFrontend.prototype.getPlugin(self, id) -- 215
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 216
		return self.roguelikeUi -- 217
	end -- 217
	local i = 0 -- 219
	do -- 219
		i = 0 -- 220
		while i < #self.plugins do -- 220
			if self.plugins[i + 1].id == id then -- 221
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
	if loaded == nil then -- 240
		return -- 241
	end -- 241
	local rawFe = loaded["watch.fe"] -- 243
	if rawFe ~= nil and type(rawFe) == "table" then -- 244
		local watchFe = rawFe -- 245
		if watchFe.contract ~= self.contract then -- 246
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
	if not v then -- 279
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
	if #self.plugins > 0 then -- 301
		local i = 0 -- 302
		do -- 302
			i = 0 -- 303
			while i < #self.plugins do -- 303
				local pl = self.plugins[i + 1] -- 304
				if pl.onBindPlay ~= nil then -- 305
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
	if self.toastTimer <= 0 or self.toastText == "" then -- 351
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
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 362
	local offers = p:getStoryTalentOffers() -- 363
	if #offers == 0 then -- 364
		return {} -- 365
	end -- 365
	local uiScale = math.max( -- 367
		0.25, -- 367
		math.min(w / 1280, h / 720) -- 367
	) -- 367
	return self.hud:talentCardRects( -- 368
		w / uiScale, -- 368
		h / uiScale, -- 368
		#offers, -- 368
		touchMode, -- 368
		self.stageVp.safeUi.top -- 368
	) -- 368
end -- 362
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 371
	if kind == "hover" then -- 372
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 373
	elseif kind == "confirm" then -- 374
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 375
	elseif kind == "back" then -- 376
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 377
	elseif kind == "start" then -- 378
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 379
	elseif kind == "pauseOpen" then -- 380
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 381
	elseif kind == "pauseClose" then -- 382
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 383
	elseif kind == "toggle" then -- 384
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 385
	end -- 385
end -- 371
function WatchFrontend.prototype.resetTrialAudio(self, p) -- 390
	self.adapter:reset(p) -- 391
	self.audio:stopRoomTransient() -- 392
	self.soundscape:resetForRoom(p) -- 393
end -- 390
function WatchFrontend.prototype.syncTrialAudio(self, dt, p, offerCount) -- 397
	local safeDt = math.min( -- 398
		0.05, -- 398
		math.max(0.001, dt) -- 398
	) -- 398
	self.audio:setPaused(p.paused) -- 399
	self.audio:setCameraRef(p.player.x, 960) -- 400
	self.audio:update(safeDt) -- 401
	if not p.paused then -- 402
		local ev = self.adapter:sample(p) -- 403
		self.audio:ingestEvents(ev, p) -- 404
		self.soundscape:updateTrial(safeDt, p, self.audio, offerCount) -- 405
	end -- 405
end -- 397
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 410
	self:syncRuntimeHooks() -- 411
	local safeDt = math.min( -- 412
		0.05, -- 412
		math.max(0, dt) -- 412
	) -- 412
	if self.toastTimer > 0 then -- 413
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 414
	end -- 414
	if self.screen == "title" and self.boundPlay ~= nil then -- 416
		self.audio:stopRoomTransient() -- 417
		self.boundPlay = nil -- 418
	end -- 418
	self.audio:update(safeDt) -- 420
	self.soundscape:updateMenu(self.screen, self.audio) -- 421
	self:setVisible(true) -- 422
	self:clearAll() -- 423
	local uiScale = self:resizeInterface(w, h) -- 424
	local act = self.menus:updateAndDrawScreen( -- 425
		dt, -- 426
		self.screen, -- 427
		input, -- 428
		self.stage, -- 429
		self.bgDraw, -- 430
		self.bgGlow, -- 431
		self.backdropArt, -- 432
		self.uiArt, -- 433
		self.uiDraw, -- 434
		self.uiInkDraw, -- 435
		self.uiGlow, -- 436
		self.texts, -- 437
		w, -- 438
		h, -- 439
		uiScale, -- 440
		self.stageVp.safeUi -- 441
	) -- 441
	self:drawToast(w / uiScale) -- 443
	self:finishFrame() -- 444
	return act -- 445
end -- 410
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 449
	local offers = p:getStoryTalentOffers() -- 450
	if #offers == 0 then -- 451
		return false -- 452
	end -- 452
	if input.inputMode == "gamepad" and not input.uiPressed then -- 454
		return false -- 455
	end -- 455
	local useUiPtr = input.uiInside or input.uiPressed -- 457
	local ____useUiPtr_2 -- 458
	if useUiPtr then -- 458
		____useUiPtr_2 = input.uiInside -- 458
	else -- 458
		____useUiPtr_2 = input.inside -- 458
	end -- 458
	local inside = ____useUiPtr_2 -- 458
	if not inside then -- 459
		return false -- 460
	end -- 460
	local uiScale = math.max( -- 462
		0.25, -- 462
		math.min(w / 1280, h / 720) -- 462
	) -- 462
	local uiW = w / uiScale -- 463
	local uiH = h / uiScale -- 464
	local rawX = useUiPtr and input.uiX or input.mx -- 465
	local rawY = useUiPtr and input.uiY or input.my -- 466
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 467
	local boxes = self.hud:talentCardRects( -- 468
		uiW, -- 468
		uiH, -- 468
		#offers, -- 468
		input:isTouchMode(), -- 468
		self.stageVp.safeUi.top -- 468
	) -- 468
	local i = 0 -- 469
	do -- 469
		i = 0 -- 470
		while i < #boxes do -- 470
			if boxes[i + 1]:containsPoint(pointer) then -- 471
				return p:chooseTalent(i) -- 472
			end -- 472
			i = i + 1 -- 470
		end -- 470
	end -- 470
	local toggleBox = self.roguelikeUi:getExpandToggleRect() -- 475
	if toggleBox.width > 0 and toggleBox:containsPoint(pointer) then -- 476
		self.roguelikeUi:setCompact(self.roguelikeUi:isExpanded()) -- 477
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.45, 0.045) -- 478
		return true -- 479
	end -- 479
	local ledgerBox = self.roguelikeUi:getLedgerButtonRect() -- 481
	if ledgerBox.width > 0 and ledgerBox:containsPoint(pointer) then -- 482
		self.roguelikeUi:toggleLedger() -- 483
		self.audio:playUi("ui:ledger_open", "assets/audio/ui/pause_open.wav", 0.56, 0.08) -- 484
		return true -- 485
	end -- 485
	return false -- 487
end -- 449
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 491
	self:syncRuntimeHooks() -- 492
	self:setVisible(true) -- 493
	if self.boundPlay ~= p then -- 494
		self:bindPlay(p, w, h) -- 495
	end -- 495
	local safeDt = math.min( -- 497
		0.05, -- 497
		math.max(0.001, dt) -- 497
	) -- 497
	if self.toastTimer > 0 then -- 498
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 499
	end -- 499
	self.audio:setPaused(p.paused) -- 501
	self.audio:setCameraRef( -- 502
		self.cam.x, -- 502
		w / math.max(0.25, self.cam.ppu) -- 502
	) -- 502
	self.audio:update(safeDt) -- 503
	local ev -- 505
	local worldDt = 0 -- 506
	local uiDt = 0 -- 507
	if not p.paused then -- 509
		ev = self.adapter:sample(p) -- 511
		self.vfx:ingest(ev, p, self.cam) -- 512
		self.audio:ingestEvents(ev, p) -- 513
		local touch = input:getTouch() -- 514
		if touch ~= nil then -- 515
			if ev.playerHit then -- 516
				touch:vibrate(0.036) -- 517
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 518
				touch:vibrate(0.024) -- 519
			elseif ev.coverDeflect then -- 520
				touch:vibrate(0.018) -- 521
			elseif ev.knockPulse then -- 522
				touch:vibrate(0.014) -- 523
			end -- 523
		end -- 523
	else -- 523
		ev = self.adapter:emptyFrame(p) -- 528
		self.narrative.wipeT = 0 -- 529
	end -- 529
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 532
	if not p.paused then -- 533
		local clampedScale = math.max( -- 534
			0, -- 534
			math.min(2, view.timeScale) -- 534
		) -- 534
		uiDt = safeDt -- 535
		worldDt = safeDt * clampedScale -- 536
	end -- 536
	local uiScale = self:resizeInterface(w, h) -- 539
	local uiW = w / uiScale -- 540
	local uiH = h / uiScale -- 541
	local ctx = { -- 543
		p = p, -- 544
		view = view, -- 545
		events = ev, -- 546
		input = input, -- 547
		cam = self.cam, -- 548
		audio = self.audio, -- 549
		assets = self.worldArt, -- 550
		backdropArt = self.backdropArt, -- 551
		worldArt = self.worldArt, -- 552
		uiArt = self.uiArt, -- 553
		texts = self.texts, -- 554
		worldDt = worldDt, -- 555
		uiDt = uiDt, -- 556
		w = w, -- 557
		h = h, -- 558
		uiW = uiW, -- 559
		uiH = uiH, -- 560
		uiScale = uiScale, -- 561
		safeUi = self.stageVp.safeUi, -- 562
		paused = p.paused -- 563
	} -- 563
	local i = 0 -- 567
	do -- 567
		i = 0 -- 568
		while i < #self.plugins do -- 568
			local pl = self.plugins[i + 1] -- 569
			if pl.update ~= nil then -- 570
				pl:update(ctx) -- 571
			end -- 571
			i = i + 1 -- 568
		end -- 568
	end -- 568
	self.roguelikeUi:update(ctx) -- 574
	if not p.paused then -- 576
		self.time = self.time + worldDt -- 577
		self.cam:update(worldDt, p, w, h) -- 578
		self.audio:setCameraRef( -- 579
			self.cam.x, -- 579
			w / math.max(0.25, self.cam.ppu) -- 579
		) -- 579
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 580
		self.actors:update(worldDt, p) -- 581
		self.vfx:update( -- 582
			worldDt, -- 582
			themeOf(p.room.key).ambient -- 582
		) -- 582
		self.hud:update(safeDt, p) -- 583
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 584
	else -- 584
		self.cam:update(0, p, w, h) -- 586
	end -- 586
	self:clearAll() -- 589
	local backdropHandled = false -- 592
	do -- 592
		i = 0 -- 593
		while i < #self.plugins do -- 593
			local pl = self.plugins[i + 1] -- 594
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 595
				backdropHandled = true -- 596
			end -- 596
			i = i + 1 -- 593
		end -- 593
	end -- 593
	if not backdropHandled then -- 599
		self.stage:drawBackdrop( -- 600
			self.bgDraw, -- 600
			self.bgGlow, -- 600
			self.backdropArt, -- 600
			p, -- 600
			self.cam, -- 600
			self.time -- 600
		) -- 600
	end -- 600
	local worldHandled = false -- 604
	do -- 604
		i = 0 -- 605
		while i < #self.plugins do -- 605
			local pl = self.plugins[i + 1] -- 606
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 607
				worldHandled = true -- 608
			end -- 608
			i = i + 1 -- 605
		end -- 605
	end -- 605
	if not worldHandled then -- 611
		self.stage:drawPlayableWorld( -- 612
			self.fgDraw, -- 612
			self.fgGlow, -- 612
			self.worldArt, -- 612
			p, -- 612
			self.cam, -- 612
			self.time, -- 612
			self.occlusion, -- 612
			worldDt -- 612
		) -- 612
	end -- 612
	local propsHandled = false -- 616
	do -- 616
		i = 0 -- 617
		while i < #self.plugins do -- 617
			local pl = self.plugins[i + 1] -- 618
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 619
				propsHandled = true -- 620
			end -- 620
			i = i + 1 -- 617
		end -- 617
	end -- 617
	if not propsHandled then -- 623
		self.props:drawAll( -- 624
			self.fgDraw, -- 624
			self.fgGlow, -- 624
			self.worldArt, -- 624
			p, -- 624
			self.cam, -- 624
			self.time, -- 624
			self.occlusion, -- 624
			worldDt -- 624
		) -- 624
	end -- 624
	local suppressAllActors = view.visualMode == "museum" -- 628
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 629
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 633
	if not suppressAllActors then -- 641
		self.actors:drawAll( -- 642
			self.fgDraw, -- 642
			self.fgGlow, -- 642
			self.worldArt, -- 642
			p, -- 642
			self.cam, -- 642
			suppressPartner -- 642
		) -- 642
	end -- 642
	do -- 642
		i = 0 -- 644
		while i < #self.plugins do -- 644
			local pl = self.plugins[i + 1] -- 645
			if pl.drawActorsOverlay ~= nil then -- 646
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 647
			end -- 647
			i = i + 1 -- 644
		end -- 644
	end -- 644
	self.roguelikeUi:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 650
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 653
	if view.visualMode == "pixel" then -- 656
		self.stage:drawForegroundFraming( -- 657
			self.fgDraw, -- 657
			w, -- 657
			h, -- 657
			p, -- 657
			self.cam -- 657
		) -- 657
	end -- 657
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 659
	local action = {type = "none"} -- 662
	if p.paused then -- 663
		action = self.menus:updateAndDrawPause( -- 664
			safeDt, -- 665
			input, -- 666
			self.uiDraw, -- 667
			self.uiInkDraw, -- 668
			self.uiArt, -- 669
			self.uiGlow, -- 670
			self.texts, -- 671
			uiW, -- 672
			uiH, -- 673
			uiScale, -- 674
			view.assistHintsEnabled, -- 675
			function() -- 676
				self.contract:toggleAssistHints() -- 677
			end, -- 676
			self.stageVp.safeUi, -- 679
			view.roguelike.active, -- 680
			function() -- 681
				self.roguelikeUi:openLedger() -- 682
			end -- 681
		) -- 681
	else -- 681
		local cutsceneHandled = false -- 687
		do -- 687
			i = 0 -- 688
			while i < #self.plugins do -- 688
				local pl = self.plugins[i + 1] -- 689
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 690
					self.uiDraw, -- 691
					self.uiInkDraw, -- 691
					self.uiArt, -- 691
					self.uiGlow, -- 691
					ctx -- 691
				) then -- 691
					cutsceneHandled = true -- 692
				end -- 692
				i = i + 1 -- 688
			end -- 688
		end -- 688
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 696
		if not cutsceneHandled and not roguelikeModal then -- 697
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 698
			self.hud:draw( -- 699
				self.uiDraw, -- 700
				self.uiInkDraw, -- 701
				self.uiArt, -- 702
				self.uiGlow, -- 703
				self.texts, -- 704
				p, -- 705
				self.cam, -- 706
				self.vfx, -- 707
				self.narrative.letterbox, -- 708
				uiScale, -- 709
				view.assistHintsEnabled, -- 710
				true, -- 711
				input.inputMode, -- 712
				input.gamepadLayout, -- 713
				self.stageVp.safeUi, -- 714
				input.retryHoldProgress, -- 715
				touchOverlayVisible -- 716
			) -- 716
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 718
			local savedBannerT = self.narrative.bannerT -- 719
			if suppressBanner then -- 720
				self.narrative.bannerT = 0 -- 721
			end -- 721
			self.narrative:draw( -- 723
				self.uiDraw, -- 724
				self.uiInkDraw, -- 725
				self.uiGlow, -- 726
				self.uiArt, -- 727
				self.texts, -- 728
				p, -- 729
				uiW, -- 730
				uiH, -- 731
				view.assistHintsEnabled, -- 732
				input.inputMode, -- 733
				input.gamepadLayout, -- 734
				self.stageVp.safeUi -- 735
			) -- 735
			if suppressBanner then -- 737
				self.narrative.bannerT = savedBannerT -- 738
			end -- 738
		end -- 738
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 742
		do -- 742
			i = 0 -- 743
			while i < #self.plugins do -- 743
				local pl = self.plugins[i + 1] -- 744
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 745
					self.uiDraw, -- 746
					self.uiInkDraw, -- 746
					self.uiArt, -- 746
					self.uiGlow, -- 746
					ctx -- 746
				) then -- 746
					suppressReticle = true -- 747
				end -- 747
				i = i + 1 -- 743
			end -- 743
		end -- 743
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 750
			self.uiDraw, -- 751
			self.uiInkDraw, -- 751
			self.uiArt, -- 751
			self.uiGlow, -- 751
			ctx -- 751
		) then -- 751
			suppressReticle = true -- 752
		end -- 752
		if not suppressReticle then -- 754
			self.hud:drawReticleOverlay( -- 755
				self.uiInkDraw, -- 756
				self.uiArt, -- 757
				self.uiGlow, -- 758
				p, -- 759
				self.cam, -- 760
				self.vfx, -- 761
				self.narrative.letterbox, -- 762
				uiScale, -- 763
				input:isTouchMode() -- 764
			) -- 764
		end -- 764
		if view.isRehearsal then -- 769
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 770
			drawSilkVeil( -- 771
				self.uiDraw, -- 771
				self.uiArt, -- 771
				"rehearsal_tag_veil", -- 771
				uiW * 0.5, -- 771
				uiH - 22 - self.stageVp.safeUi.top, -- 771
				168, -- 771
				26, -- 771
				PALETTE.inkWarm, -- 771
				0.74, -- 771
				8 -- 771
			) -- 771
			self.texts:put( -- 772
				"xs", -- 772
				badgeText, -- 772
				uiW * 0.5, -- 772
				uiH - 22 - self.stageVp.safeUi.top, -- 772
				toColor(PALETTE.amberCore), -- 772
				0.5, -- 772
				0.5, -- 772
				"Center", -- 772
				1.2, -- 772
				0.92, -- 772
				0.08 -- 772
			) -- 772
		end -- 772
	end -- 772
	self:drawToast(uiW) -- 776
	self:finishFrame() -- 777
	return action -- 778
end -- 491
return ____exports -- 491
