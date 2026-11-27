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
local ____talent_draft = require("Script.watch.fe.ui.talent_draft") -- 45
local TalentDraftPlugin = ____talent_draft.TalentDraftPlugin -- 46
local computeEscortDeathButtons = ____talent_draft.computeEscortDeathButtons -- 47
local computeTalentSlipRects = ____talent_draft.computeTalentSlipRects -- 48
local ____roguelike_ui = require("Script.watch.fe.ui.roguelike_ui") -- 50
local RoguelikeUiPlugin = ____roguelike_ui.RoguelikeUiPlugin -- 50
____exports.WatchFrontend = __TS__Class() -- 52
local WatchFrontend = ____exports.WatchFrontend -- 52
WatchFrontend.name = "WatchFrontend" -- 52
function WatchFrontend.prototype.____constructor(self, parent) -- 96
	self.occlusion = __TS__New(DepthOcclusion) -- 53
	self.cam = __TS__New(CameraDirector) -- 72
	self.adapter = __TS__New(PlayAdapter) -- 73
	self.contract = __TS__New( -- 74
		DualRouteContract, -- 74
		function(p) return self:canPickStoryTalent(p) end -- 74
	) -- 74
	self.audio = __TS__New(AudioDirector) -- 75
	self.soundscape = __TS__New(SoundscapeDirector) -- 76
	self.stage = __TS__New(StageRenderer) -- 77
	self.props = __TS__New(PropsRenderer) -- 78
	self.actors = __TS__New(ActorsRenderer) -- 79
	self.vfx = __TS__New(VfxSystem) -- 80
	self.hud = __TS__New(HudRenderer) -- 81
	self.narrative = __TS__New(NarrativeRenderer) -- 82
	self.menus = __TS__New(MenuRenderer) -- 83
	self.talentDraft = __TS__New(TalentDraftPlugin) -- 84
	self.plugins = {} -- 87
	self.screen = "title" -- 89
	self.time = 0 -- 90
	self.stageVp = computeStageViewport(1280, 720) -- 92
	self.toastText = "" -- 93
	self.toastTimer = 0 -- 94
	self.layerRoot = Node() -- 97
	self.layerRoot.order = 5 -- 98
	self.layerRoot:addTo(parent) -- 99
	self.audio:attachHost(self.layerRoot) -- 101
	self.menus.onUiSound = function(____, kind) -- 102
		self:playMenuUiSound(kind) -- 103
	end -- 102
	self.menus.onAudioSettingsChanged = function(____, inp) -- 105
		self.audio:applyUserVolumes(inp.settings) -- 106
	end -- 105
	local additive = BlendFunc("SrcAlpha", "One") -- 109
	self.bgDraw = DrawNode() -- 111
	self.bgDraw.order = 10 -- 112
	self.bgDraw:addTo(self.layerRoot) -- 113
	self.bgGlow = DrawNode() -- 115
	self.bgGlow.order = 15 -- 116
	self.bgGlow.blendFunc = additive -- 117
	self.bgGlow:addTo(self.layerRoot) -- 118
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 120
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 121
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 122
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 123
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 124
	self.fgDraw = DrawNode() -- 126
	self.fgDraw.order = 30 -- 127
	self.fgDraw:addTo(self.layerRoot) -- 128
	self.fgGlow = DrawNode() -- 130
	self.fgGlow.order = 35 -- 131
	self.fgGlow.blendFunc = additive -- 132
	self.fgGlow:addTo(self.layerRoot) -- 133
	self.uiLayer = Node() -- 135
	self.uiLayer.order = 40 -- 136
	self.uiLayer:addTo(self.layerRoot) -- 137
	self.uiDraw = DrawNode() -- 139
	self.uiDraw.order = 0 -- 140
	self.uiDraw:addTo(self.uiLayer) -- 141
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 143
	self.uiInkDraw = DrawNode() -- 145
	self.uiInkDraw.order = 4 -- 146
	self.uiInkDraw:addTo(self.uiLayer) -- 147
	self.uiGlow = DrawNode() -- 149
	self.uiGlow.order = 6 -- 150
	self.uiGlow.blendFunc = additive -- 151
	self.uiGlow:addTo(self.uiLayer) -- 152
	self.uiMask = DrawNode() -- 154
	self.uiMask.order = 8 -- 155
	self.uiMask:addTo(self.uiLayer) -- 156
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 158
	self.roguelikeUi = __TS__New( -- 162
		RoguelikeUiPlugin, -- 162
		self.contract, -- 163
		function() return self.hud.talentSelected end, -- 164
		function(idx) -- 165
			self.hud.talentSelected = idx -- 166
			self.talentDraft.selected = idx -- 167
		end -- 165
	) -- 165
	self.hud.roguelikeUiHandled = true -- 170
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) -- 171
		if self.boundPlay ~= nil and self.boundPlay.talentModalActive then -- 172
			return computeTalentSlipRects( -- 173
				w, -- 173
				h, -- 173
				count, -- 173
				touchMode, -- 173
				safeTop -- 173
			) -- 173
		end -- 173
		return self.roguelikeUi:getTalentCardRects( -- 175
			w, -- 175
			h, -- 175
			count, -- 175
			touchMode, -- 175
			safeTop -- 175
		) -- 175
	end -- 171
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 190
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 191
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 192
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 193
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 194
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 195
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 196
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 197
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 198
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 199
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 200
	self:registerPlugin(self.talentDraft) -- 201
end -- 96
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 205
	local i = 0 -- 206
	do -- 206
		i = 0 -- 207
		while i < #self.plugins do -- 207
			if self.plugins[i + 1].id == plugin.id then -- 208
				self.plugins[i + 1] = plugin -- 209
				self:syncRuntimeHooks() -- 210
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 211
					plugin:onBindPlay( -- 212
						self.boundPlay, -- 212
						self.contract:peekSnapshot(self.boundPlay) -- 212
					) -- 212
				end -- 212
				return -- 214
			end -- 214
			i = i + 1 -- 207
		end -- 207
	end -- 207
	local ____self_plugins_0 = self.plugins -- 217
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 217
	self:syncRuntimeHooks() -- 218
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 219
		plugin:onBindPlay( -- 220
			self.boundPlay, -- 220
			self.contract:peekSnapshot(self.boundPlay) -- 220
		) -- 220
	end -- 220
end -- 205
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 225
	local w = 0 -- 226
	local i = 0 -- 227
	do -- 227
		i = 0 -- 228
		while i < #self.plugins do -- 228
			if self.plugins[i + 1].id ~= id then -- 229
				self.plugins[w + 1] = self.plugins[i + 1] -- 230
				w = w + 1 -- 231
			end -- 231
			i = i + 1 -- 228
		end -- 228
	end -- 228
	__TS__ArraySetLength(self.plugins, w) -- 234
	self:syncRuntimeHooks() -- 235
end -- 225
function WatchFrontend.prototype.getPlugin(self, id) -- 239
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 240
		return self.roguelikeUi -- 241
	end -- 241
	local i = 0 -- 243
	do -- 243
		i = 0 -- 244
		while i < #self.plugins do -- 244
			if self.plugins[i + 1].id == id then -- 245
				return self.plugins[i + 1] -- 246
			end -- 246
			i = i + 1 -- 244
		end -- 244
	end -- 244
	return nil -- 249
end -- 239
function WatchFrontend.prototype.getPlugins(self) -- 252
	return self.plugins -- 253
end -- 252
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 261
	local g = _G -- 262
	local ____temp_1 -- 263
	if g.package ~= nil then -- 263
		____temp_1 = g.package.loaded -- 263
	else -- 263
		____temp_1 = nil -- 263
	end -- 263
	local loaded = ____temp_1 -- 263
	if loaded == nil then -- 264
		return -- 265
	end -- 265
	local rawFe = loaded["watch.fe"] -- 267
	if rawFe ~= nil and type(rawFe) == "table" then -- 268
		local watchFe = rawFe -- 269
		if watchFe.contract ~= self.contract then -- 270
			watchFe.contract = self.contract -- 271
			watchFe.audio = self.audio -- 272
			watchFe.soundscape = self.soundscape -- 273
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 274
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 275
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 276
		end -- 276
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 278
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 279
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 280
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 281
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 282
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 283
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 284
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 285
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 286
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 287
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 288
		watchFe.talentDraft = self:getPlugin("fe-07-talent-draft") -- 289
		watchFe.roguelikeUi = self.roguelikeUi -- 290
	end -- 290
end -- 261
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 294
	local scale = math.max( -- 295
		0.25, -- 295
		math.min(w / 1280, h / 720) -- 295
	) -- 295
	self.uiLayer.scaleX = scale -- 296
	self.uiLayer.scaleY = scale -- 297
	return scale -- 298
end -- 294
function WatchFrontend.prototype.setVisible(self, v) -- 302
	self.layerRoot.visible = v -- 303
	if not v then -- 304
		self.texts:hideAll() -- 305
	end -- 305
end -- 302
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 310
	self:syncRuntimeHooks() -- 311
	self.boundPlay = p -- 312
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 313
	p.useEscortDeathSummary = true -- 314
	p:openTalentDraft() -- 315
	self.cam:snap(p, w, h) -- 316
	self.adapter:reset(p) -- 317
	self.contract:resetForRoom(p) -- 318
	self.audio:stopRoomTransient() -- 319
	self.soundscape:resetForRoom(p) -- 320
	self.actors:reset(p) -- 321
	self.occlusion:reset() -- 322
	self.vfx:reset() -- 323
	self.hud:reset(p) -- 324
	self.narrative:onEnterRoom(p.room.key) -- 325
	local initView = self.contract:peekSnapshot(p) -- 327
	if #self.plugins > 0 then -- 328
		local i = 0 -- 329
		do -- 329
			i = 0 -- 330
			while i < #self.plugins do -- 330
				local pl = self.plugins[i + 1] -- 331
				if pl.onBindPlay ~= nil then -- 332
					pl:onBindPlay(p, initView) -- 333
				end -- 333
				i = i + 1 -- 330
			end -- 330
		end -- 330
	end -- 330
	self.roguelikeUi:onBindPlay(p, initView) -- 337
end -- 310
function WatchFrontend.prototype.clearAll(self) -- 340
	self.bgDraw:clear() -- 341
	self.bgGlow:clear() -- 342
	self.fgDraw:clear() -- 343
	self.fgGlow:clear() -- 344
	self.uiDraw:clear() -- 345
	self.uiInkDraw:clear() -- 346
	self.uiGlow:clear() -- 347
	self.uiMask:clear() -- 348
	self.backdropArt:beginFrame() -- 349
	self.dioramaBg:beginFrame() -- 350
	self.dioramaWorld:beginFrame() -- 351
	self.dioramaFg:beginFrame() -- 352
	self.worldArt:beginFrame() -- 353
	self.uiArt:beginFrame() -- 354
	self.texts:beginFrame() -- 355
end -- 340
function WatchFrontend.prototype.finishFrame(self) -- 358
	self.backdropArt:endFrame() -- 359
	self.dioramaBg:endFrame() -- 360
	self.dioramaWorld:endFrame() -- 361
	self.dioramaFg:endFrame() -- 362
	self.worldArt:endFrame() -- 363
	self.uiArt:endFrame() -- 364
	self.texts:endFrame() -- 365
end -- 358
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 369
	self.stageVp = vp -- 370
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 371
end -- 369
function WatchFrontend.prototype.showToast(self, text, duration) -- 375
	if duration == nil then -- 375
		duration = 1.8 -- 375
	end -- 375
	self.toastText = text -- 376
	self.toastTimer = duration -- 377
end -- 375
function WatchFrontend.prototype.getToastText(self) -- 380
	return self.toastTimer > 0 and self.toastText or "" -- 381
end -- 380
function WatchFrontend.prototype.drawToast(self, uiW) -- 384
	if self.toastTimer <= 0 or self.toastText == "" then -- 385
		return -- 386
	end -- 386
	local alpha = math.min(1, self.toastTimer * 2.4) -- 388
	local cx = uiW * 0.5 -- 389
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 390
	drawSilkVeil( -- 391
		self.uiDraw, -- 391
		self.uiArt, -- 391
		"fe_toast_veil", -- 391
		cx, -- 391
		cy, -- 391
		340, -- 391
		38, -- 391
		PALETTE.inkWarm, -- 391
		0.86 * alpha, -- 391
		9 -- 391
	) -- 391
	self.texts:put( -- 392
		"sm", -- 392
		self.toastText, -- 392
		cx, -- 392
		cy, -- 392
		toColor(PALETTE.amberCore), -- 392
		0.5, -- 392
		0.5, -- 392
		"Center", -- 392
		1.4, -- 392
		0.96 * alpha, -- 392
		0.08 -- 392
	) -- 392
end -- 384
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 395
	if p.paused or p.craftBench.active or p.reloadOpen or p.escortFailed then -- 396
		return false -- 397
	end -- 397
	if self.roguelikeUi:isLedgerOpen() then -- 399
		return false -- 400
	end -- 400
	if p.talentModalActive then -- 402
		return #p:getStoryTalentOffers() > 0 -- 403
	end -- 403
	return self.roguelikeUi:canPickTalent() -- 405
end -- 395
function WatchFrontend.prototype.isLedgerOpen(self) -- 408
	return self.roguelikeUi:isLedgerOpen() -- 409
end -- 408
function WatchFrontend.prototype.getLedgerButtonBox(self) -- 412
	local box = self.roguelikeUi:getLedgerButtonRect() -- 413
	return box.width > 0 and box.height > 0 and box or nil -- 414
end -- 412
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 418
	local offers = p:getStoryTalentOffers() -- 419
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 420
		return {} -- 421
	end -- 421
	local uiScale = math.max( -- 423
		0.25, -- 423
		math.min(w / 1280, h / 720) -- 423
	) -- 423
	return self.hud:talentCardRects( -- 424
		w / uiScale, -- 424
		h / uiScale, -- 424
		#offers, -- 424
		touchMode, -- 424
		self.stageVp.safeUi.top -- 424
	) -- 424
end -- 418
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 428
	if not p.escortFailed then -- 429
		return nil -- 430
	end -- 430
	local uiScale = math.max( -- 432
		0.25, -- 432
		math.min(w / 1280, h / 720) -- 432
	) -- 432
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 433
end -- 428
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 437
	if not p.escortFailed then -- 438
		return "" -- 439
	end -- 439
	if input.inputMode == "gamepad" and not input.uiPressed then -- 441
		return "" -- 442
	end -- 442
	local useUiPtr = input.uiInside or input.uiPressed -- 444
	local ____useUiPtr_2 -- 445
	if useUiPtr then -- 445
		____useUiPtr_2 = input.uiInside -- 445
	else -- 445
		____useUiPtr_2 = input.inside -- 445
	end -- 445
	local inside = ____useUiPtr_2 -- 445
	if not inside then -- 446
		return "" -- 447
	end -- 447
	local uiScale = math.max( -- 449
		0.25, -- 449
		math.min(w / 1280, h / 720) -- 449
	) -- 449
	local rawX = useUiPtr and input.uiX or input.mx -- 450
	local rawY = useUiPtr and input.uiY or input.my -- 451
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 452
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 453
	if btns.retry:containsPoint(pointer) then -- 454
		self.talentDraft.deathSelected = 0 -- 455
		return "retry" -- 456
	end -- 456
	if btns.title:containsPoint(pointer) then -- 458
		self.talentDraft.deathSelected = 1 -- 459
		return "title" -- 460
	end -- 460
	return "" -- 462
end -- 437
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 465
	if kind == "hover" then -- 466
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 467
	elseif kind == "confirm" then -- 468
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 469
	elseif kind == "back" then -- 470
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 471
	elseif kind == "start" then -- 472
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 473
	elseif kind == "pauseOpen" then -- 474
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 475
	elseif kind == "pauseClose" then -- 476
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 477
	elseif kind == "toggle" then -- 478
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 479
	end -- 479
end -- 465
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 484
	self:syncRuntimeHooks() -- 485
	local safeDt = math.min( -- 486
		0.05, -- 486
		math.max(0, dt) -- 486
	) -- 486
	if self.toastTimer > 0 then -- 487
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 488
	end -- 488
	if self.screen == "title" and self.boundPlay ~= nil then -- 490
		self.audio:stopRoomTransient() -- 491
		self.boundPlay = nil -- 492
	end -- 492
	self.audio:update(safeDt) -- 494
	self.soundscape:updateMenu(self.screen, self.audio) -- 495
	self:setVisible(true) -- 496
	self:clearAll() -- 497
	local uiScale = self:resizeInterface(w, h) -- 498
	local act = self.menus:updateAndDrawScreen( -- 499
		dt, -- 500
		self.screen, -- 501
		input, -- 502
		self.stage, -- 503
		self.bgDraw, -- 504
		self.bgGlow, -- 505
		self.backdropArt, -- 506
		self.uiArt, -- 507
		self.uiDraw, -- 508
		self.uiInkDraw, -- 509
		self.uiGlow, -- 510
		self.texts, -- 511
		w, -- 512
		h, -- 513
		uiScale, -- 514
		self.stageVp.safeUi -- 515
	) -- 515
	self:drawToast(w / uiScale) -- 517
	self:finishFrame() -- 518
	return act -- 519
end -- 484
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 523
	local offers = p:getStoryTalentOffers() -- 524
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 525
		return false -- 526
	end -- 526
	if input.inputMode == "gamepad" and not input.uiPressed then -- 528
		return false -- 529
	end -- 529
	local useUiPtr = input.uiInside or input.uiPressed -- 531
	local ____useUiPtr_3 -- 532
	if useUiPtr then -- 532
		____useUiPtr_3 = input.uiInside -- 532
	else -- 532
		____useUiPtr_3 = input.inside -- 532
	end -- 532
	local inside = ____useUiPtr_3 -- 532
	if not inside then -- 533
		return false -- 534
	end -- 534
	local uiScale = math.max( -- 536
		0.25, -- 536
		math.min(w / 1280, h / 720) -- 536
	) -- 536
	local uiW = w / uiScale -- 537
	local uiH = h / uiScale -- 538
	local rawX = useUiPtr and input.uiX or input.mx -- 539
	local rawY = useUiPtr and input.uiY or input.my -- 540
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 541
	local boxes = self.hud:talentCardRects( -- 542
		uiW, -- 542
		uiH, -- 542
		#offers, -- 542
		input:isTouchMode(), -- 542
		self.stageVp.safeUi.top -- 542
	) -- 542
	local i = 0 -- 543
	do -- 543
		i = 0 -- 544
		while i < #boxes do -- 544
			if boxes[i + 1]:containsPoint(pointer) then -- 545
				self.talentDraft.selected = i -- 546
				self.hud.talentSelected = i -- 547
				return p:chooseTalent(i) -- 548
			end -- 548
			i = i + 1 -- 544
		end -- 544
	end -- 544
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 551
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 552
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 553
end -- 523
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h, trialMode, evIn) -- 558
	if trialMode == nil then -- 558
		trialMode = false -- 558
	end -- 558
	self:syncRuntimeHooks() -- 559
	self:setVisible(true) -- 560
	if self.boundPlay ~= p then -- 561
		self:bindPlay(p, w, h) -- 562
	end -- 562
	local safeDt = math.min( -- 564
		0.05, -- 564
		math.max(0.001, dt) -- 564
	) -- 564
	if self.toastTimer > 0 then -- 565
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 566
	end -- 566
	if not trialMode then -- 568
		self.audio:setPaused(p.paused) -- 569
		self.audio:setCameraRef( -- 570
			self.cam.x, -- 570
			w / math.max(0.25, self.cam.ppu) -- 570
		) -- 570
		self.audio:update(safeDt) -- 571
	end -- 571
	local ev -- 574
	local worldDt = 0 -- 575
	local uiDt = 0 -- 576
	if not p.paused then -- 578
		ev = evIn ~= nil and evIn or self.adapter:sample(p) -- 580
		self.vfx:ingest(ev, p, self.cam) -- 581
		if not trialMode then -- 582
			self.audio:ingestEvents(ev, p) -- 583
		end -- 583
		if ev.playerHit then -- 585
			input:vibrate(0.036) -- 586
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 587
			input:vibrate(0.024) -- 588
		elseif ev.coverDeflect then -- 589
			input:vibrate(0.018) -- 590
		elseif ev.knockPulse then -- 591
			input:vibrate(0.014) -- 592
		end -- 592
	else -- 592
		ev = self.adapter:emptyFrame(p) -- 596
		self.narrative.wipeT = 0 -- 597
	end -- 597
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 600
	if not p.paused then -- 601
		local clampedScale = math.max( -- 602
			0, -- 602
			math.min(2, view.timeScale) -- 602
		) -- 602
		uiDt = safeDt -- 603
		worldDt = safeDt * clampedScale -- 604
	end -- 604
	local uiScale = self:resizeInterface(w, h) -- 607
	local uiW = w / uiScale -- 608
	local uiH = h / uiScale -- 609
	local ctx = { -- 611
		p = p, -- 612
		view = view, -- 613
		events = ev, -- 614
		input = input, -- 615
		cam = self.cam, -- 616
		audio = self.audio, -- 617
		assets = self.worldArt, -- 618
		backdropArt = self.backdropArt, -- 619
		worldArt = self.worldArt, -- 620
		uiArt = self.uiArt, -- 621
		uiMask = self.uiMask, -- 622
		dioramaBg = self.dioramaBg, -- 623
		dioramaWorld = self.dioramaWorld, -- 624
		dioramaFg = self.dioramaFg, -- 625
		texts = self.texts, -- 626
		worldDt = worldDt, -- 627
		uiDt = uiDt, -- 628
		w = w, -- 629
		h = h, -- 630
		uiW = uiW, -- 631
		uiH = uiH, -- 632
		uiScale = uiScale, -- 633
		safeUi = self.stageVp.safeUi, -- 634
		paused = p.paused -- 635
	} -- 635
	local i = 0 -- 639
	do -- 639
		i = 0 -- 640
		while i < #self.plugins do -- 640
			local pl = self.plugins[i + 1] -- 641
			if pl.update ~= nil then -- 642
				pl:update(ctx) -- 643
			end -- 643
			i = i + 1 -- 640
		end -- 640
	end -- 640
	self.roguelikeUi:update(ctx) -- 646
	if not p.paused then -- 648
		self.time = self.time + worldDt -- 649
		self.cam:update(worldDt, p, w, h) -- 650
		if not trialMode then -- 651
			self.audio:setCameraRef( -- 652
				self.cam.x, -- 652
				w / math.max(0.25, self.cam.ppu) -- 652
			) -- 652
			self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 653
		end -- 653
		self.actors:update(worldDt, p) -- 655
		self.vfx:update( -- 656
			worldDt, -- 656
			themeOf(p.room.key).ambient -- 656
		) -- 656
		self.hud:update(safeDt, p) -- 657
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 658
	else -- 658
		self.cam:update(0, p, w, h) -- 660
	end -- 660
	self:clearAll() -- 663
	local backdropHandled = false -- 666
	do -- 666
		i = 0 -- 667
		while i < #self.plugins do -- 667
			local pl = self.plugins[i + 1] -- 668
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 669
				backdropHandled = true -- 670
			end -- 670
			i = i + 1 -- 667
		end -- 667
	end -- 667
	if not backdropHandled then -- 673
		self.stage:drawBackdrop( -- 674
			self.bgDraw, -- 674
			self.bgGlow, -- 674
			self.backdropArt, -- 674
			p, -- 674
			self.cam, -- 674
			self.time -- 674
		) -- 674
	end -- 674
	local worldHandled = false -- 678
	do -- 678
		i = 0 -- 679
		while i < #self.plugins do -- 679
			local pl = self.plugins[i + 1] -- 680
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 681
				worldHandled = true -- 682
			end -- 682
			i = i + 1 -- 679
		end -- 679
	end -- 679
	if not worldHandled then -- 685
		self.stage:drawPlayableWorld( -- 686
			self.fgDraw, -- 686
			self.fgGlow, -- 686
			self.worldArt, -- 686
			p, -- 686
			self.cam, -- 686
			self.time, -- 686
			self.occlusion, -- 686
			worldDt -- 686
		) -- 686
	end -- 686
	local propsHandled = false -- 690
	do -- 690
		i = 0 -- 691
		while i < #self.plugins do -- 691
			local pl = self.plugins[i + 1] -- 692
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 693
				propsHandled = true -- 694
			end -- 694
			i = i + 1 -- 691
		end -- 691
	end -- 691
	if not propsHandled then -- 697
		self.props:drawAll( -- 698
			self.fgDraw, -- 698
			self.fgGlow, -- 698
			self.worldArt, -- 698
			p, -- 698
			self.cam, -- 698
			self.time, -- 698
			self.occlusion, -- 698
			worldDt -- 698
		) -- 698
	end -- 698
	local suppressAllActors = view.visualMode == "museum" -- 702
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 703
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 707
	if not suppressAllActors then -- 715
		self.actors:drawAll( -- 716
			self.fgDraw, -- 716
			self.fgGlow, -- 716
			self.worldArt, -- 716
			p, -- 716
			self.cam, -- 716
			suppressPartner -- 716
		) -- 716
	end -- 716
	do -- 716
		i = 0 -- 718
		while i < #self.plugins do -- 718
			local pl = self.plugins[i + 1] -- 719
			if pl.drawActorsOverlay ~= nil then -- 720
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 721
			end -- 721
			i = i + 1 -- 718
		end -- 718
	end -- 718
	self.roguelikeUi:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 724
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 727
	if view.visualMode == "pixel" then -- 730
		self.stage:drawForegroundFraming( -- 731
			self.fgDraw, -- 731
			w, -- 731
			h, -- 731
			p, -- 731
			self.cam -- 731
		) -- 731
	end -- 731
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 733
	local action = {type = "none"} -- 736
	if p.paused then -- 737
		local isMaleRoguelike = p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() -- 738
		action = self.menus:updateAndDrawPause( -- 739
			safeDt, -- 740
			input, -- 741
			self.uiDraw, -- 742
			self.uiInkDraw, -- 743
			self.uiArt, -- 744
			self.uiGlow, -- 745
			self.texts, -- 746
			uiW, -- 747
			uiH, -- 748
			uiScale, -- 749
			view.assistHintsEnabled, -- 750
			function() -- 751
				self.contract:toggleAssistHints() -- 752
			end, -- 751
			self.stageVp.safeUi, -- 754
			isMaleRoguelike, -- 755
			view.roguelike.active, -- 756
			function() -- 757
				self.roguelikeUi:openLedger() -- 758
			end -- 757
		) -- 757
	else -- 757
		local cutsceneHandled = false -- 763
		do -- 763
			i = 0 -- 764
			while i < #self.plugins do -- 764
				local pl = self.plugins[i + 1] -- 765
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 766
					self.uiDraw, -- 767
					self.uiInkDraw, -- 767
					self.uiArt, -- 767
					self.uiGlow, -- 767
					ctx -- 767
				) then -- 767
					cutsceneHandled = true -- 768
				end -- 768
				i = i + 1 -- 764
			end -- 764
		end -- 764
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 772
		if not cutsceneHandled and not roguelikeModal then -- 773
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 774
			self.hud:draw( -- 775
				self.uiDraw, -- 776
				self.uiInkDraw, -- 777
				self.uiArt, -- 778
				self.uiGlow, -- 779
				self.texts, -- 780
				p, -- 781
				self.cam, -- 782
				self.vfx, -- 783
				self.narrative.letterbox, -- 784
				uiScale, -- 785
				view.assistHintsEnabled, -- 786
				true, -- 787
				input.inputMode, -- 788
				input.gamepadLayout, -- 789
				self.stageVp.safeUi, -- 790
				input.retryHoldProgress, -- 791
				touchOverlayVisible -- 792
			) -- 792
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 794
			local savedBannerT = self.narrative.bannerT -- 795
			if suppressBanner then -- 796
				self.narrative.bannerT = 0 -- 797
			end -- 797
			self.narrative:draw( -- 799
				self.uiDraw, -- 800
				self.uiInkDraw, -- 801
				self.uiGlow, -- 802
				self.uiArt, -- 803
				self.texts, -- 804
				p, -- 805
				uiW, -- 806
				uiH, -- 807
				view.assistHintsEnabled, -- 808
				input.inputMode, -- 809
				input.gamepadLayout, -- 810
				self.stageVp.safeUi -- 811
			) -- 811
			if suppressBanner then -- 813
				self.narrative.bannerT = savedBannerT -- 814
			end -- 814
		elseif cutsceneHandled then -- 816
			self.narrative:drawCutsceneDialogue( -- 818
				self.uiDraw, -- 819
				self.uiInkDraw, -- 820
				self.uiArt, -- 821
				self.texts, -- 822
				p, -- 823
				uiW, -- 824
				uiH, -- 825
				self.stageVp.safeUi -- 826
			) -- 826
		end -- 826
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 830
		do -- 830
			i = 0 -- 831
			while i < #self.plugins do -- 831
				do -- 831
					local pl = self.plugins[i + 1] -- 832
					if roguelikeModal and pl == self.talentDraft then -- 833
						goto __continue130 -- 834
					end -- 834
					if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 836
						self.uiDraw, -- 837
						self.uiInkDraw, -- 837
						self.uiArt, -- 837
						self.uiGlow, -- 837
						ctx -- 837
					) then -- 837
						suppressReticle = true -- 838
					end -- 838
				end -- 838
				::__continue130:: -- 838
				i = i + 1 -- 831
			end -- 831
		end -- 831
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 841
			self.uiDraw, -- 842
			self.uiInkDraw, -- 842
			self.uiArt, -- 842
			self.uiGlow, -- 842
			ctx -- 842
		) then -- 842
			suppressReticle = true -- 843
		end -- 843
		if not suppressReticle then -- 845
			self.hud:drawReticleOverlay( -- 846
				self.uiInkDraw, -- 847
				self.uiArt, -- 848
				self.uiGlow, -- 849
				p, -- 850
				self.cam, -- 851
				self.vfx, -- 852
				self.narrative.letterbox, -- 853
				uiScale, -- 854
				input:isTouchMode() -- 855
			) -- 855
		end -- 855
		if view.isRehearsal then -- 860
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 861
			drawSilkVeil( -- 862
				self.uiDraw, -- 862
				self.uiArt, -- 862
				"rehearsal_tag_veil", -- 862
				uiW * 0.5, -- 862
				uiH - 22 - self.stageVp.safeUi.top, -- 862
				168, -- 862
				26, -- 862
				PALETTE.inkWarm, -- 862
				0.74, -- 862
				8 -- 862
			) -- 862
			self.texts:put( -- 863
				"xs", -- 863
				badgeText, -- 863
				uiW * 0.5, -- 863
				uiH - 22 - self.stageVp.safeUi.top, -- 863
				toColor(PALETTE.amberCore), -- 863
				0.5, -- 863
				0.5, -- 863
				"Center", -- 863
				1.2, -- 863
				0.92, -- 863
				0.08 -- 863
			) -- 863
		end -- 863
	end -- 863
	self:drawToast(uiW) -- 867
	self:finishFrame() -- 868
	return action -- 869
end -- 558
return ____exports -- 558
