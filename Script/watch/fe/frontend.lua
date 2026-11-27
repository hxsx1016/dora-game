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
local computeEscortDeathButtons = ____roguelike_ui.computeEscortDeathButtons -- 44
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
	p.useEscortDeathSummary = true -- 288
	p:openTalentDraft() -- 289
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 290
	self.cam:snap(p, w, h) -- 291
	self.adapter:reset(p) -- 292
	self.contract:resetForRoom(p) -- 293
	self.audio:stopRoomTransient() -- 294
	self.soundscape:resetForRoom(p) -- 295
	self.actors:reset(p) -- 296
	self.occlusion:reset() -- 297
	self.vfx:reset() -- 298
	self.hud:reset(p) -- 299
	self.narrative:onEnterRoom(p.room.key) -- 300
	local initView = self.contract:peekSnapshot(p) -- 302
	if #self.plugins > 0 then -- 302
		local i = 0 -- 304
		do -- 304
			i = 0 -- 305
			while i < #self.plugins do -- 305
				local pl = self.plugins[i + 1] -- 306
				if pl.onBindPlay ~= nil then -- 306
					pl:onBindPlay(p, initView) -- 308
				end -- 308
				i = i + 1 -- 305
			end -- 305
		end -- 305
	end -- 305
	self.roguelikeUi:onBindPlay(p, initView) -- 312
end -- 285
function WatchFrontend.prototype.clearAll(self) -- 315
	self.bgDraw:clear() -- 316
	self.bgGlow:clear() -- 317
	self.fgDraw:clear() -- 318
	self.fgGlow:clear() -- 319
	self.uiDraw:clear() -- 320
	self.uiInkDraw:clear() -- 321
	self.uiGlow:clear() -- 322
	self.backdropArt:beginFrame() -- 323
	self.worldArt:beginFrame() -- 324
	self.uiArt:beginFrame() -- 325
	self.texts:beginFrame() -- 326
end -- 315
function WatchFrontend.prototype.finishFrame(self) -- 329
	self.backdropArt:endFrame() -- 330
	self.worldArt:endFrame() -- 331
	self.uiArt:endFrame() -- 332
	self.texts:endFrame() -- 333
end -- 329
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 337
	self.stageVp = vp -- 338
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 339
end -- 337
function WatchFrontend.prototype.showToast(self, text, duration) -- 343
	if duration == nil then -- 343
		duration = 1.8 -- 343
	end -- 343
	self.toastText = text -- 344
	self.toastTimer = duration -- 345
end -- 343
function WatchFrontend.prototype.getToastText(self) -- 348
	return self.toastTimer > 0 and self.toastText or "" -- 349
end -- 348
function WatchFrontend.prototype.drawToast(self, uiW) -- 352
	if self.toastTimer <= 0 or self.toastText == "" then -- 352
		return -- 354
	end -- 354
	local alpha = math.min(1, self.toastTimer * 2.4) -- 356
	local cx = uiW * 0.5 -- 357
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 358
	drawSilkVeil( -- 359
		self.uiDraw, -- 359
		self.uiArt, -- 359
		"fe_toast_veil", -- 359
		cx, -- 359
		cy, -- 359
		340, -- 359
		38, -- 359
		PALETTE.inkWarm, -- 359
		0.86 * alpha, -- 359
		9 -- 359
	) -- 359
	self.texts:put( -- 360
		"sm", -- 360
		self.toastText, -- 360
		cx, -- 360
		cy, -- 360
		toColor(PALETTE.amberCore), -- 360
		0.5, -- 360
		0.5, -- 360
		"Center", -- 360
		1.4, -- 360
		0.96 * alpha, -- 360
		0.08 -- 360
	) -- 360
end -- 352
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 363
	return not p.escortFailed and not p.paused and not p.craftBench.active and not p.reloadOpen and self.roguelikeUi:canPickTalent() -- 364
end -- 363
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 368
	local offers = p:getStoryTalentOffers() -- 369
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 369
		return {} -- 371
	end -- 371
	local uiScale = math.max( -- 373
		0.25, -- 373
		math.min(w / 1280, h / 720) -- 373
	) -- 373
	return self.hud:talentCardRects( -- 374
		w / uiScale, -- 374
		h / uiScale, -- 374
		#offers, -- 374
		touchMode, -- 374
		self.stageVp.safeUi.top -- 374
	) -- 374
end -- 368
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 378
	if not p.escortFailed then -- 378
		return nil -- 380
	end -- 380
	local uiScale = math.max( -- 382
		0.25, -- 382
		math.min(w / 1280, h / 720) -- 382
	) -- 382
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 383
end -- 378
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 387
	if not p.escortFailed then -- 387
		return "" -- 389
	end -- 389
	if input.inputMode == "gamepad" and not input.uiPressed then -- 389
		return "" -- 392
	end -- 392
	local useUiPtr = input.uiInside or input.uiPressed -- 394
	local ____useUiPtr_2 -- 395
	if useUiPtr then -- 395
		____useUiPtr_2 = input.uiInside -- 395
	else -- 395
		____useUiPtr_2 = input.inside -- 395
	end -- 395
	local inside = ____useUiPtr_2 -- 395
	if not inside then -- 395
		return "" -- 397
	end -- 397
	local uiScale = math.max( -- 399
		0.25, -- 399
		math.min(w / 1280, h / 720) -- 399
	) -- 399
	local rawX = useUiPtr and input.uiX or input.mx -- 400
	local rawY = useUiPtr and input.uiY or input.my -- 401
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 402
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 403
	if btns.retry:containsPoint(pointer) then -- 403
		self.roguelikeUi.deathSelected = 0 -- 405
		return "retry" -- 406
	end -- 406
	if btns.title:containsPoint(pointer) then -- 406
		self.roguelikeUi.deathSelected = 1 -- 409
		return "title" -- 410
	end -- 410
	return "" -- 412
end -- 387
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 415
	if kind == "hover" then -- 415
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 417
	elseif kind == "confirm" then -- 417
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 419
	elseif kind == "back" then -- 419
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 421
	elseif kind == "start" then -- 421
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 423
	elseif kind == "pauseOpen" then -- 423
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 425
	elseif kind == "pauseClose" then -- 425
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 427
	elseif kind == "toggle" then -- 427
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 429
	end -- 429
end -- 415
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 434
	self:syncRuntimeHooks() -- 435
	local safeDt = math.min( -- 436
		0.05, -- 436
		math.max(0, dt) -- 436
	) -- 436
	if self.toastTimer > 0 then -- 436
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 438
	end -- 438
	if self.screen == "title" and self.boundPlay ~= nil then -- 438
		self.audio:stopRoomTransient() -- 441
		self.boundPlay = nil -- 442
	end -- 442
	self.audio:update(safeDt) -- 444
	self.soundscape:updateMenu(self.screen, self.audio) -- 445
	self:setVisible(true) -- 446
	self:clearAll() -- 447
	local uiScale = self:resizeInterface(w, h) -- 448
	local act = self.menus:updateAndDrawScreen( -- 449
		dt, -- 450
		self.screen, -- 451
		input, -- 452
		self.stage, -- 453
		self.bgDraw, -- 454
		self.bgGlow, -- 455
		self.backdropArt, -- 456
		self.uiArt, -- 457
		self.uiDraw, -- 458
		self.uiInkDraw, -- 459
		self.uiGlow, -- 460
		self.texts, -- 461
		w, -- 462
		h, -- 463
		uiScale, -- 464
		self.stageVp.safeUi -- 465
	) -- 465
	self:drawToast(w / uiScale) -- 467
	self:finishFrame() -- 468
	return act -- 469
end -- 434
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 473
	local offers = p:getStoryTalentOffers() -- 474
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 474
		return false -- 476
	end -- 476
	if input.inputMode == "gamepad" and not input.uiPressed then -- 476
		return false -- 479
	end -- 479
	local useUiPtr = input.uiInside or input.uiPressed -- 481
	local ____useUiPtr_3 -- 482
	if useUiPtr then -- 482
		____useUiPtr_3 = input.uiInside -- 482
	else -- 482
		____useUiPtr_3 = input.inside -- 482
	end -- 482
	local inside = ____useUiPtr_3 -- 482
	if not inside then -- 482
		return false -- 484
	end -- 484
	local uiScale = math.max( -- 486
		0.25, -- 486
		math.min(w / 1280, h / 720) -- 486
	) -- 486
	local uiW = w / uiScale -- 487
	local uiH = h / uiScale -- 488
	local rawX = useUiPtr and input.uiX or input.mx -- 489
	local rawY = useUiPtr and input.uiY or input.my -- 490
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 491
	local boxes = self.hud:talentCardRects( -- 492
		uiW, -- 492
		uiH, -- 492
		#offers, -- 492
		input:isTouchMode(), -- 492
		self.stageVp.safeUi.top -- 492
	) -- 492
	local i = 0 -- 493
	do -- 493
		i = 0 -- 494
		while i < #boxes do -- 494
			if boxes[i + 1]:containsPoint(pointer) then -- 494
				return p:chooseTalent(i) -- 496
			end -- 496
			i = i + 1 -- 494
		end -- 494
	end -- 494
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 500
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 501
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 502
end -- 473
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 507
	self:syncRuntimeHooks() -- 508
	self:setVisible(true) -- 509
	if self.boundPlay ~= p then -- 509
		self:bindPlay(p, w, h) -- 511
	end -- 511
	local safeDt = math.min( -- 513
		0.05, -- 513
		math.max(0.001, dt) -- 513
	) -- 513
	if self.toastTimer > 0 then -- 513
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 515
	end -- 515
	self.audio:setPaused(p.paused) -- 517
	self.audio:setCameraRef( -- 518
		self.cam.x, -- 518
		w / math.max(0.25, self.cam.ppu) -- 518
	) -- 518
	self.audio:update(safeDt) -- 519
	local ev -- 521
	local worldDt = 0 -- 522
	local uiDt = 0 -- 523
	if not p.paused then -- 523
		ev = self.adapter:sample(p) -- 527
		self.vfx:ingest(ev, p, self.cam) -- 528
		self.audio:ingestEvents(ev, p) -- 529
		if ev.playerHit then -- 529
			input:vibrate(0.036) -- 531
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 531
			input:vibrate(0.024) -- 533
		elseif ev.coverDeflect then -- 533
			input:vibrate(0.018) -- 535
		elseif ev.knockPulse then -- 535
			input:vibrate(0.014) -- 537
		end -- 537
	else -- 537
		ev = self.adapter:emptyFrame(p) -- 541
		self.narrative.wipeT = 0 -- 542
	end -- 542
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 545
	if not p.paused then -- 545
		local clampedScale = math.max( -- 547
			0, -- 547
			math.min(2, view.timeScale) -- 547
		) -- 547
		uiDt = safeDt -- 548
		worldDt = safeDt * clampedScale -- 549
	end -- 549
	local uiScale = self:resizeInterface(w, h) -- 552
	local uiW = w / uiScale -- 553
	local uiH = h / uiScale -- 554
	local ctx = { -- 556
		p = p, -- 557
		view = view, -- 558
		events = ev, -- 559
		input = input, -- 560
		cam = self.cam, -- 561
		audio = self.audio, -- 562
		assets = self.worldArt, -- 563
		backdropArt = self.backdropArt, -- 564
		worldArt = self.worldArt, -- 565
		uiArt = self.uiArt, -- 566
		texts = self.texts, -- 567
		worldDt = worldDt, -- 568
		uiDt = uiDt, -- 569
		w = w, -- 570
		h = h, -- 571
		uiW = uiW, -- 572
		uiH = uiH, -- 573
		uiScale = uiScale, -- 574
		safeUi = self.stageVp.safeUi, -- 575
		paused = p.paused -- 576
	} -- 576
	local i = 0 -- 580
	do -- 580
		i = 0 -- 581
		while i < #self.plugins do -- 581
			local pl = self.plugins[i + 1] -- 582
			if pl.update ~= nil then -- 582
				pl:update(ctx) -- 584
			end -- 584
			i = i + 1 -- 581
		end -- 581
	end -- 581
	self.roguelikeUi:update(ctx) -- 587
	if not p.paused then -- 587
		self.time = self.time + worldDt -- 590
		self.cam:update(worldDt, p, w, h) -- 591
		self.audio:setCameraRef( -- 592
			self.cam.x, -- 592
			w / math.max(0.25, self.cam.ppu) -- 592
		) -- 592
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 593
		self.actors:update(worldDt, p) -- 594
		self.vfx:update( -- 595
			worldDt, -- 595
			themeOf(p.room.key).ambient -- 595
		) -- 595
		self.hud:update(safeDt, p) -- 596
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 597
	else -- 597
		self.cam:update(0, p, w, h) -- 599
	end -- 599
	self:clearAll() -- 602
	local backdropHandled = false -- 605
	do -- 605
		i = 0 -- 606
		while i < #self.plugins do -- 606
			local pl = self.plugins[i + 1] -- 607
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 607
				backdropHandled = true -- 609
			end -- 609
			i = i + 1 -- 606
		end -- 606
	end -- 606
	if not backdropHandled then -- 606
		self.stage:drawBackdrop( -- 613
			self.bgDraw, -- 613
			self.bgGlow, -- 613
			self.backdropArt, -- 613
			p, -- 613
			self.cam, -- 613
			self.time -- 613
		) -- 613
	end -- 613
	local worldHandled = false -- 617
	do -- 617
		i = 0 -- 618
		while i < #self.plugins do -- 618
			local pl = self.plugins[i + 1] -- 619
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 619
				worldHandled = true -- 621
			end -- 621
			i = i + 1 -- 618
		end -- 618
	end -- 618
	if not worldHandled then -- 618
		self.stage:drawPlayableWorld( -- 625
			self.fgDraw, -- 625
			self.fgGlow, -- 625
			self.worldArt, -- 625
			p, -- 625
			self.cam, -- 625
			self.time, -- 625
			self.occlusion, -- 625
			worldDt -- 625
		) -- 625
	end -- 625
	local propsHandled = false -- 629
	do -- 629
		i = 0 -- 630
		while i < #self.plugins do -- 630
			local pl = self.plugins[i + 1] -- 631
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 631
				propsHandled = true -- 633
			end -- 633
			i = i + 1 -- 630
		end -- 630
	end -- 630
	if not propsHandled then -- 630
		self.props:drawAll( -- 637
			self.fgDraw, -- 637
			self.fgGlow, -- 637
			self.worldArt, -- 637
			p, -- 637
			self.cam, -- 637
			self.time, -- 637
			self.occlusion, -- 637
			worldDt -- 637
		) -- 637
	end -- 637
	local suppressAllActors = view.visualMode == "museum" -- 641
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 642
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 646
	if not suppressAllActors then -- 646
		self.actors:drawAll( -- 655
			self.fgDraw, -- 655
			self.fgGlow, -- 655
			self.worldArt, -- 655
			p, -- 655
			self.cam, -- 655
			suppressPartner -- 655
		) -- 655
	end -- 655
	do -- 655
		i = 0 -- 657
		while i < #self.plugins do -- 657
			local pl = self.plugins[i + 1] -- 658
			if pl.drawActorsOverlay ~= nil then -- 658
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 660
			end -- 660
			i = i + 1 -- 657
		end -- 657
	end -- 657
	self.roguelikeUi:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 663
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 666
	if view.visualMode == "pixel" then -- 666
		self.stage:drawForegroundFraming( -- 670
			self.fgDraw, -- 670
			w, -- 670
			h, -- 670
			p, -- 670
			self.cam -- 670
		) -- 670
	end -- 670
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 672
	local action = {type = "none"} -- 675
	if p.paused then -- 675
		action = self.menus:updateAndDrawPause( -- 677
			safeDt, -- 678
			input, -- 679
			self.uiDraw, -- 680
			self.uiInkDraw, -- 681
			self.uiArt, -- 682
			self.uiGlow, -- 683
			self.texts, -- 684
			uiW, -- 685
			uiH, -- 686
			uiScale, -- 687
			view.assistHintsEnabled, -- 688
			function() -- 689
				self.contract:toggleAssistHints() -- 690
			end, -- 689
			self.stageVp.safeUi, -- 692
			p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom(), -- 693
			view.roguelike.active, -- 694
			function() -- 695
				self.roguelikeUi:openLedger() -- 696
			end -- 695
		) -- 695
	else -- 695
		local cutsceneHandled = false -- 701
		do -- 701
			i = 0 -- 702
			while i < #self.plugins do -- 702
				local pl = self.plugins[i + 1] -- 703
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 703
					self.uiDraw, -- 705
					self.uiInkDraw, -- 705
					self.uiArt, -- 705
					self.uiGlow, -- 705
					ctx -- 705
				) then -- 705
					cutsceneHandled = true -- 706
				end -- 706
				i = i + 1 -- 702
			end -- 702
		end -- 702
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 710
		if not cutsceneHandled and not roguelikeModal then -- 710
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 712
			self.hud:draw( -- 713
				self.uiDraw, -- 714
				self.uiInkDraw, -- 715
				self.uiArt, -- 716
				self.uiGlow, -- 717
				self.texts, -- 718
				p, -- 719
				self.cam, -- 720
				self.vfx, -- 721
				self.narrative.letterbox, -- 722
				uiScale, -- 723
				view.assistHintsEnabled, -- 724
				true, -- 725
				input.inputMode, -- 726
				input.gamepadLayout, -- 727
				self.stageVp.safeUi, -- 728
				input.retryHoldProgress, -- 729
				touchOverlayVisible -- 730
			) -- 730
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 732
			local savedBannerT = self.narrative.bannerT -- 733
			if suppressBanner then -- 733
				self.narrative.bannerT = 0 -- 735
			end -- 735
			self.narrative:draw( -- 737
				self.uiDraw, -- 738
				self.uiInkDraw, -- 739
				self.uiGlow, -- 740
				self.uiArt, -- 741
				self.texts, -- 742
				p, -- 743
				uiW, -- 744
				uiH, -- 745
				view.assistHintsEnabled, -- 746
				input.inputMode, -- 747
				input.gamepadLayout, -- 748
				self.stageVp.safeUi -- 749
			) -- 749
			if suppressBanner then -- 749
				self.narrative.bannerT = savedBannerT -- 752
			end -- 752
		elseif cutsceneHandled then -- 752
			self.narrative:drawCutsceneDialogue( -- 756
				self.uiDraw, -- 757
				self.uiInkDraw, -- 758
				self.uiArt, -- 759
				self.texts, -- 760
				p, -- 761
				uiW, -- 762
				uiH, -- 763
				self.stageVp.safeUi -- 764
			) -- 764
		end -- 764
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 768
		do -- 768
			i = 0 -- 769
			while i < #self.plugins do -- 769
				local pl = self.plugins[i + 1] -- 770
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 770
					self.uiDraw, -- 772
					self.uiInkDraw, -- 772
					self.uiArt, -- 772
					self.uiGlow, -- 772
					ctx -- 772
				) then -- 772
					suppressReticle = true -- 773
				end -- 773
				i = i + 1 -- 769
			end -- 769
		end -- 769
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 769
			self.uiDraw, -- 777
			self.uiInkDraw, -- 777
			self.uiArt, -- 777
			self.uiGlow, -- 777
			ctx -- 777
		) then -- 777
			suppressReticle = true -- 778
		end -- 778
		if not suppressReticle then -- 778
			self.hud:drawReticleOverlay( -- 781
				self.uiInkDraw, -- 782
				self.uiArt, -- 783
				self.uiGlow, -- 784
				p, -- 785
				self.cam, -- 786
				self.vfx, -- 787
				self.narrative.letterbox, -- 788
				uiScale, -- 789
				input:isTouchMode() -- 790
			) -- 790
		end -- 790
		if view.isRehearsal then -- 790
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 796
			drawSilkVeil( -- 797
				self.uiDraw, -- 797
				self.uiArt, -- 797
				"rehearsal_tag_veil", -- 797
				uiW * 0.5, -- 797
				uiH - 22 - self.stageVp.safeUi.top, -- 797
				168, -- 797
				26, -- 797
				PALETTE.inkWarm, -- 797
				0.74, -- 797
				8 -- 797
			) -- 797
			self.texts:put( -- 798
				"xs", -- 798
				badgeText, -- 798
				uiW * 0.5, -- 798
				uiH - 22 - self.stageVp.safeUi.top, -- 798
				toColor(PALETTE.amberCore), -- 798
				0.5, -- 798
				0.5, -- 798
				"Center", -- 798
				1.2, -- 798
				0.92, -- 798
				0.08 -- 798
			) -- 798
		end -- 798
	end -- 798
	self:drawToast(uiW) -- 802
	self:finishFrame() -- 803
	return action -- 804
end -- 507
return ____exports -- 507