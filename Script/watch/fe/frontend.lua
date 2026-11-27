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
local ____escort_world = require("Script.watch.fe.scenes.escort_world") -- 29
local EscortWorldRenderer = ____escort_world.EscortWorldRenderer -- 29
local ____second_half_assets = require("Script.watch.fe.scenes.second_half_assets") -- 30
local ensureSecondHalfAssetsRegistered = ____second_half_assets.ensureSecondHalfAssetsRegistered -- 30
local ____textpool = require("Script.watch.fe.ui.textpool") -- 31
local TextPool = ____textpool.TextPool -- 31
local ____hud = require("Script.watch.fe.ui.hud") -- 32
local HudRenderer = ____hud.HudRenderer -- 32
local ____narrative = require("Script.watch.fe.ui.narrative") -- 33
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 33
local ____menus = require("Script.watch.fe.ui.menus") -- 34
local MenuRenderer = ____menus.MenuRenderer -- 34
local ____theme = require("Script.watch.fe.theme") -- 35
local PALETTE = ____theme.PALETTE -- 35
local drawSilkVeil = ____theme.drawSilkVeil -- 35
local themeOf = ____theme.themeOf -- 35
local toColor = ____theme.toColor -- 35
local ____ming_audit = require("Script.watch.fe.renderer.ming_audit") -- 36
local MingArtAuditPlugin = ____ming_audit.MingArtAuditPlugin -- 36
local ____gate_transition = require("Script.watch.fe.scenes.gate_transition") -- 37
local GateTransitionPlugin = ____gate_transition.GateTransitionPlugin -- 37
local ____lowpoly_world = require("Script.watch.fe.scenes.lowpoly_world") -- 38
local LowpolyWorldPlugin = ____lowpoly_world.LowpolyWorldPlugin -- 38
local ____afterimage_artifact = require("Script.watch.fe.renderer.afterimage_artifact") -- 39
local AfterimageArtifactPlugin = ____afterimage_artifact.AfterimageArtifactPlugin -- 39
local ____carry_pose = require("Script.watch.fe.renderer.carry_pose") -- 40
local CarryPosePlugin = ____carry_pose.CarryPosePlugin -- 40
local ____prologue_intro = require("Script.watch.fe.cutscenes.prologue_intro") -- 41
local PrologueIntroPlugin = ____prologue_intro.PrologueIntroPlugin -- 41
local ____cuff_shots = require("Script.watch.fe.cutscenes.cuff_shots") -- 42
local CuffShotsPlugin = ____cuff_shots.CuffShotsPlugin -- 42
local ____tower_endings = require("Script.watch.fe.cutscenes.tower_endings") -- 43
local TowerEndingsPlugin = ____tower_endings.TowerEndingsPlugin -- 43
local ____well_museum = require("Script.watch.fe.scenes.well_museum") -- 44
local WellMuseumPlugin = ____well_museum.WellMuseumPlugin -- 44
local ____reload_wheel = require("Script.watch.fe.ui.reload_wheel") -- 45
local ReloadWheelPlugin = ____reload_wheel.ReloadWheelPlugin -- 45
local ____craft_bench = require("Script.watch.fe.ui.craft_bench") -- 46
local CraftBenchPlugin = ____craft_bench.CraftBenchPlugin -- 46
local ____talent_draft = require("Script.watch.fe.ui.talent_draft") -- 47
local TalentDraftPlugin = ____talent_draft.TalentDraftPlugin -- 48
local computeEscortDeathButtons = ____talent_draft.computeEscortDeathButtons -- 49
local computeTalentSlipRects = ____talent_draft.computeTalentSlipRects -- 50
local ____roguelike_ui = require("Script.watch.fe.ui.roguelike_ui") -- 52
local RoguelikeUiPlugin = ____roguelike_ui.RoguelikeUiPlugin -- 52
____exports.WatchFrontend = __TS__Class() -- 54
local WatchFrontend = ____exports.WatchFrontend -- 54
WatchFrontend.name = "WatchFrontend" -- 54
function WatchFrontend.prototype.____constructor(self, parent) -- 100
	self.occlusion = __TS__New(DepthOcclusion) -- 55
	self.cam = __TS__New(CameraDirector) -- 75
	self.adapter = __TS__New(PlayAdapter) -- 76
	self.contract = __TS__New( -- 77
		DualRouteContract, -- 77
		function(p) return self:canPickStoryTalent(p) end -- 77
	) -- 77
	self.audio = __TS__New(AudioDirector) -- 78
	self.soundscape = __TS__New(SoundscapeDirector) -- 79
	self.stage = __TS__New(StageRenderer) -- 80
	self.escortWorld = __TS__New(EscortWorldRenderer) -- 81
	self.props = __TS__New(PropsRenderer) -- 82
	self.actors = __TS__New(ActorsRenderer) -- 83
	self.vfx = __TS__New(VfxSystem) -- 84
	self.hud = __TS__New(HudRenderer) -- 85
	self.narrative = __TS__New(NarrativeRenderer) -- 86
	self.menus = __TS__New(MenuRenderer) -- 87
	self.talentDraft = __TS__New(TalentDraftPlugin) -- 88
	self.plugins = {} -- 91
	self.screen = "title" -- 93
	self.time = 0 -- 94
	self.stageVp = computeStageViewport(1280, 720) -- 96
	self.toastText = "" -- 97
	self.toastTimer = 0 -- 98
	self.layerRoot = Node() -- 101
	self.layerRoot.order = 5 -- 102
	self.layerRoot:addTo(parent) -- 103
	ensureSecondHalfAssetsRegistered() -- 104
	self.audio:attachHost(self.layerRoot) -- 106
	self.menus.onUiSound = function(____, kind) -- 107
		self:playMenuUiSound(kind) -- 108
	end -- 107
	self.menus.onAudioSettingsChanged = function(____, inp) -- 110
		self.audio:applyUserVolumes(inp.settings) -- 111
	end -- 110
	local additive = BlendFunc("SrcAlpha", "One") -- 114
	self.bgDraw = DrawNode() -- 116
	self.bgDraw.order = 10 -- 117
	self.bgDraw:addTo(self.layerRoot) -- 118
	self.escortTowerDraw = DrawNode() -- 121
	self.escortTowerDraw.order = 13 -- 122
	self.escortTowerDraw:addTo(self.layerRoot) -- 123
	self.bgGlow = DrawNode() -- 125
	self.bgGlow.order = 15 -- 126
	self.bgGlow.blendFunc = additive -- 127
	self.bgGlow:addTo(self.layerRoot) -- 128
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 130
	self.dioramaBg = __TS__New(DioramaLayerHost, self.layerRoot, 14) -- 131
	self.dioramaWorld = __TS__New(DioramaLayerHost, self.layerRoot, 28) -- 132
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 133
	self.dioramaFg = __TS__New(DioramaLayerHost, self.layerRoot, 34) -- 134
	self.fgDraw = DrawNode() -- 136
	self.fgDraw.order = 30 -- 137
	self.fgDraw:addTo(self.layerRoot) -- 138
	self.fgGlow = DrawNode() -- 140
	self.fgGlow.order = 35 -- 141
	self.fgGlow.blendFunc = additive -- 142
	self.fgGlow:addTo(self.layerRoot) -- 143
	self.uiLayer = Node() -- 145
	self.uiLayer.order = 40 -- 146
	self.uiLayer:addTo(self.layerRoot) -- 147
	self.uiDraw = DrawNode() -- 149
	self.uiDraw.order = 0 -- 150
	self.uiDraw:addTo(self.uiLayer) -- 151
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 153
	self.uiInkDraw = DrawNode() -- 155
	self.uiInkDraw.order = 4 -- 156
	self.uiInkDraw:addTo(self.uiLayer) -- 157
	self.uiGlow = DrawNode() -- 159
	self.uiGlow.order = 6 -- 160
	self.uiGlow.blendFunc = additive -- 161
	self.uiGlow:addTo(self.uiLayer) -- 162
	self.uiMask = DrawNode() -- 164
	self.uiMask.order = 8 -- 165
	self.uiMask:addTo(self.uiLayer) -- 166
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 168
	self.roguelikeUi = __TS__New( -- 172
		RoguelikeUiPlugin, -- 172
		self.contract, -- 173
		function() return self.hud.talentSelected end, -- 174
		function(idx) -- 175
			self.hud.talentSelected = idx -- 176
			self.talentDraft.selected = idx -- 177
		end -- 175
	) -- 175
	self.hud.roguelikeUiHandled = true -- 180
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) -- 181
		if self.boundPlay ~= nil and self.boundPlay.talentModalActive then -- 182
			return computeTalentSlipRects( -- 183
				w, -- 183
				h, -- 183
				count, -- 183
				touchMode, -- 183
				safeTop -- 183
			) -- 183
		end -- 183
		return self.roguelikeUi:getTalentCardRects( -- 185
			w, -- 185
			h, -- 185
			count, -- 185
			touchMode, -- 185
			safeTop -- 185
		) -- 185
	end -- 181
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 200
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 201
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 202
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 203
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 204
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 205
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 206
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 207
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 208
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 209
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 210
	self:registerPlugin(self.talentDraft) -- 211
end -- 100
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 215
	local i = 0 -- 216
	do -- 216
		i = 0 -- 217
		while i < #self.plugins do -- 217
			if self.plugins[i + 1].id == plugin.id then -- 218
				self.plugins[i + 1] = plugin -- 219
				self:syncRuntimeHooks() -- 220
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 221
					plugin:onBindPlay( -- 222
						self.boundPlay, -- 222
						self.contract:peekSnapshot(self.boundPlay) -- 222
					) -- 222
				end -- 222
				return -- 224
			end -- 224
			i = i + 1 -- 217
		end -- 217
	end -- 217
	local ____self_plugins_0 = self.plugins -- 227
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 227
	self:syncRuntimeHooks() -- 228
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 229
		plugin:onBindPlay( -- 230
			self.boundPlay, -- 230
			self.contract:peekSnapshot(self.boundPlay) -- 230
		) -- 230
	end -- 230
end -- 215
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 235
	local w = 0 -- 236
	local i = 0 -- 237
	do -- 237
		i = 0 -- 238
		while i < #self.plugins do -- 238
			if self.plugins[i + 1].id ~= id then -- 239
				self.plugins[w + 1] = self.plugins[i + 1] -- 240
				w = w + 1 -- 241
			end -- 241
			i = i + 1 -- 238
		end -- 238
	end -- 238
	__TS__ArraySetLength(self.plugins, w) -- 244
	self:syncRuntimeHooks() -- 245
end -- 235
function WatchFrontend.prototype.getPlugin(self, id) -- 249
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 250
		return self.roguelikeUi -- 251
	end -- 251
	local i = 0 -- 253
	do -- 253
		i = 0 -- 254
		while i < #self.plugins do -- 254
			if self.plugins[i + 1].id == id then -- 255
				return self.plugins[i + 1] -- 256
			end -- 256
			i = i + 1 -- 254
		end -- 254
	end -- 254
	return nil -- 259
end -- 249
function WatchFrontend.prototype.getPlugins(self) -- 262
	return self.plugins -- 263
end -- 262
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 271
	local g = _G -- 272
	local ____temp_1 -- 273
	if g.package ~= nil then -- 273
		____temp_1 = g.package.loaded -- 273
	else -- 273
		____temp_1 = nil -- 273
	end -- 273
	local loaded = ____temp_1 -- 273
	if loaded == nil then -- 274
		return -- 275
	end -- 275
	local rawFe = loaded["watch.fe"] -- 277
	if rawFe ~= nil and type(rawFe) == "table" then -- 278
		local watchFe = rawFe -- 279
		if watchFe.contract ~= self.contract then -- 280
			watchFe.contract = self.contract -- 281
			watchFe.audio = self.audio -- 282
			watchFe.soundscape = self.soundscape -- 283
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 284
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 285
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 286
		end -- 286
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 288
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 289
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 290
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 291
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 292
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 293
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 294
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 295
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 296
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 297
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 298
		watchFe.talentDraft = self:getPlugin("fe-07-talent-draft") -- 299
		watchFe.roguelikeUi = self.roguelikeUi -- 300
	end -- 300
end -- 271
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 304
	local scale = math.max( -- 305
		0.25, -- 305
		math.min(w / 1280, h / 720) -- 305
	) -- 305
	self.uiLayer.scaleX = scale -- 306
	self.uiLayer.scaleY = scale -- 307
	return scale -- 308
end -- 304
function WatchFrontend.prototype.setVisible(self, v) -- 312
	self.layerRoot.visible = v -- 313
	if not v then -- 314
		self.texts:hideAll() -- 315
	end -- 315
end -- 312
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 320
	self:syncRuntimeHooks() -- 321
	self.boundPlay = p -- 322
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 323
	p.useEscortDeathSummary = true -- 324
	p:openTalentDraft() -- 325
	self.cam:snap(p, w, h) -- 326
	self.adapter:reset(p) -- 327
	self.contract:resetForRoom(p) -- 328
	self.audio:stopRoomTransient() -- 329
	self.soundscape:resetForRoom(p) -- 330
	self.actors:reset(p) -- 331
	self.occlusion:reset() -- 332
	self.vfx:reset() -- 333
	self.hud:reset(p) -- 334
	self.narrative:onEnterRoom(p.room.key) -- 335
	local initView = self.contract:peekSnapshot(p) -- 337
	if #self.plugins > 0 then -- 338
		local i = 0 -- 339
		do -- 339
			i = 0 -- 340
			while i < #self.plugins do -- 340
				local pl = self.plugins[i + 1] -- 341
				if pl.onBindPlay ~= nil then -- 342
					pl:onBindPlay(p, initView) -- 343
				end -- 343
				i = i + 1 -- 340
			end -- 340
		end -- 340
	end -- 340
	self.roguelikeUi:onBindPlay(p, initView) -- 347
end -- 320
function WatchFrontend.prototype.clearAll(self) -- 350
	self.bgDraw:clear() -- 351
	self.escortTowerDraw:clear() -- 352
	self.bgGlow:clear() -- 353
	self.fgDraw:clear() -- 354
	self.fgGlow:clear() -- 355
	self.uiDraw:clear() -- 356
	self.uiInkDraw:clear() -- 357
	self.uiGlow:clear() -- 358
	self.uiMask:clear() -- 359
	self.backdropArt:beginFrame() -- 360
	self.dioramaBg:beginFrame() -- 361
	self.dioramaWorld:beginFrame() -- 362
	self.dioramaFg:beginFrame() -- 363
	self.worldArt:beginFrame() -- 364
	self.uiArt:beginFrame() -- 365
	self.texts:beginFrame() -- 366
end -- 350
function WatchFrontend.prototype.finishFrame(self) -- 369
	self.backdropArt:endFrame() -- 370
	self.dioramaBg:endFrame() -- 371
	self.dioramaWorld:endFrame() -- 372
	self.dioramaFg:endFrame() -- 373
	self.worldArt:endFrame() -- 374
	self.uiArt:endFrame() -- 375
	self.texts:endFrame() -- 376
end -- 369
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 380
	self.stageVp = vp -- 381
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 382
end -- 380
function WatchFrontend.prototype.showToast(self, text, duration) -- 386
	if duration == nil then -- 386
		duration = 1.8 -- 386
	end -- 386
	self.toastText = text -- 387
	self.toastTimer = duration -- 388
end -- 386
function WatchFrontend.prototype.getToastText(self) -- 391
	return self.toastTimer > 0 and self.toastText or "" -- 392
end -- 391
function WatchFrontend.prototype.drawToast(self, uiW) -- 395
	if self.toastTimer <= 0 or self.toastText == "" then -- 396
		return -- 397
	end -- 397
	local alpha = math.min(1, self.toastTimer * 2.4) -- 399
	local cx = uiW * 0.5 -- 400
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 401
	drawSilkVeil( -- 402
		self.uiDraw, -- 402
		self.uiArt, -- 402
		"fe_toast_veil", -- 402
		cx, -- 402
		cy, -- 402
		340, -- 402
		38, -- 402
		PALETTE.inkWarm, -- 402
		0.86 * alpha, -- 402
		9 -- 402
	) -- 402
	self.texts:put( -- 403
		"sm", -- 403
		self.toastText, -- 403
		cx, -- 403
		cy, -- 403
		toColor(PALETTE.amberCore), -- 403
		0.5, -- 403
		0.5, -- 403
		"Center", -- 403
		1.4, -- 403
		0.96 * alpha, -- 403
		0.08 -- 403
	) -- 403
end -- 395
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 406
	if p.paused or p.craftBench.active or p.reloadOpen or p.escortFailed then -- 407
		return false -- 408
	end -- 408
	if self.roguelikeUi:isLedgerOpen() then -- 410
		return false -- 411
	end -- 411
	if p.talentModalActive then -- 413
		return #p:getStoryTalentOffers() > 0 -- 414
	end -- 414
	return self.roguelikeUi:canPickTalent() -- 416
end -- 406
function WatchFrontend.prototype.isLedgerOpen(self) -- 419
	return self.roguelikeUi:isLedgerOpen() -- 420
end -- 419
function WatchFrontend.prototype.getLedgerButtonBox(self) -- 423
	local box = self.roguelikeUi:getLedgerButtonRect() -- 424
	return box.width > 0 and box.height > 0 and box or nil -- 425
end -- 423
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 429
	local offers = p:getStoryTalentOffers() -- 430
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 431
		return {} -- 432
	end -- 432
	local uiScale = math.max( -- 434
		0.25, -- 434
		math.min(w / 1280, h / 720) -- 434
	) -- 434
	return self.hud:talentCardRects( -- 435
		w / uiScale, -- 435
		h / uiScale, -- 435
		#offers, -- 435
		touchMode, -- 435
		self.stageVp.safeUi.top -- 435
	) -- 435
end -- 429
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 439
	if not p.escortFailed then -- 440
		return nil -- 441
	end -- 441
	local uiScale = math.max( -- 443
		0.25, -- 443
		math.min(w / 1280, h / 720) -- 443
	) -- 443
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 444
end -- 439
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 448
	if not p.escortFailed then -- 449
		return "" -- 450
	end -- 450
	if input.inputMode == "gamepad" and not input.uiPressed then -- 452
		return "" -- 453
	end -- 453
	local useUiPtr = input.uiInside or input.uiPressed -- 455
	local ____useUiPtr_2 -- 456
	if useUiPtr then -- 456
		____useUiPtr_2 = input.uiInside -- 456
	else -- 456
		____useUiPtr_2 = input.inside -- 456
	end -- 456
	local inside = ____useUiPtr_2 -- 456
	if not inside then -- 457
		return "" -- 458
	end -- 458
	local uiScale = math.max( -- 460
		0.25, -- 460
		math.min(w / 1280, h / 720) -- 460
	) -- 460
	local rawX = useUiPtr and input.uiX or input.mx -- 461
	local rawY = useUiPtr and input.uiY or input.my -- 462
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 463
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 464
	if btns.retry:containsPoint(pointer) then -- 465
		self.talentDraft.deathSelected = 0 -- 466
		return "retry" -- 467
	end -- 467
	if btns.title:containsPoint(pointer) then -- 469
		self.talentDraft.deathSelected = 1 -- 470
		return "title" -- 471
	end -- 471
	return "" -- 473
end -- 448
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 476
	if kind == "hover" then -- 477
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 478
	elseif kind == "confirm" then -- 479
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 480
	elseif kind == "back" then -- 481
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 482
	elseif kind == "start" then -- 483
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 484
	elseif kind == "pauseOpen" then -- 485
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 486
	elseif kind == "pauseClose" then -- 487
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 488
	elseif kind == "toggle" then -- 489
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 490
	end -- 490
end -- 476
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 495
	self:syncRuntimeHooks() -- 496
	local safeDt = math.min( -- 497
		0.05, -- 497
		math.max(0, dt) -- 497
	) -- 497
	if self.toastTimer > 0 then -- 498
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 499
	end -- 499
	if self.screen == "title" and self.boundPlay ~= nil then -- 501
		self.audio:stopRoomTransient() -- 502
		self.boundPlay = nil -- 503
	end -- 503
	self.audio:update(safeDt) -- 505
	self.soundscape:updateMenu(self.screen, self.audio) -- 506
	self:setVisible(true) -- 507
	self:clearAll() -- 508
	local uiScale = self:resizeInterface(w, h) -- 509
	local act = self.menus:updateAndDrawScreen( -- 510
		dt, -- 511
		self.screen, -- 512
		input, -- 513
		self.stage, -- 514
		self.bgDraw, -- 515
		self.bgGlow, -- 516
		self.backdropArt, -- 517
		self.uiArt, -- 518
		self.uiDraw, -- 519
		self.uiInkDraw, -- 520
		self.uiGlow, -- 521
		self.texts, -- 522
		w, -- 523
		h, -- 524
		uiScale, -- 525
		self.stageVp.safeUi -- 526
	) -- 526
	self:drawToast(w / uiScale) -- 528
	self:finishFrame() -- 529
	return act -- 530
end -- 495
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 534
	local offers = p:getStoryTalentOffers() -- 535
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 536
		return false -- 537
	end -- 537
	if input.inputMode == "gamepad" and not input.uiPressed then -- 539
		return false -- 540
	end -- 540
	local useUiPtr = input.uiInside or input.uiPressed -- 542
	local ____useUiPtr_3 -- 543
	if useUiPtr then -- 543
		____useUiPtr_3 = input.uiInside -- 543
	else -- 543
		____useUiPtr_3 = input.inside -- 543
	end -- 543
	local inside = ____useUiPtr_3 -- 543
	if not inside then -- 544
		return false -- 545
	end -- 545
	local uiScale = math.max( -- 547
		0.25, -- 547
		math.min(w / 1280, h / 720) -- 547
	) -- 547
	local uiW = w / uiScale -- 548
	local uiH = h / uiScale -- 549
	local rawX = useUiPtr and input.uiX or input.mx -- 550
	local rawY = useUiPtr and input.uiY or input.my -- 551
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 552
	local boxes = self.hud:talentCardRects( -- 553
		uiW, -- 553
		uiH, -- 553
		#offers, -- 553
		input:isTouchMode(), -- 553
		self.stageVp.safeUi.top -- 553
	) -- 553
	local i = 0 -- 554
	do -- 554
		i = 0 -- 555
		while i < #boxes do -- 555
			if boxes[i + 1]:containsPoint(pointer) then -- 556
				self.talentDraft.selected = i -- 557
				self.hud.talentSelected = i -- 558
				return p:chooseTalent(i) -- 559
			end -- 559
			i = i + 1 -- 555
		end -- 555
	end -- 555
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 562
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 563
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 564
end -- 534
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h, trialMode, evIn) -- 569
	if trialMode == nil then -- 569
		trialMode = false -- 569
	end -- 569
	self:syncRuntimeHooks() -- 570
	self:setVisible(true) -- 571
	if self.boundPlay ~= p then -- 572
		self:bindPlay(p, w, h) -- 573
	end -- 573
	local safeDt = math.min( -- 575
		0.05, -- 575
		math.max(0.001, dt) -- 575
	) -- 575
	if self.toastTimer > 0 then -- 576
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 577
	end -- 577
	if not trialMode then -- 579
		self.audio:setPaused(p.paused) -- 580
		self.audio:setCameraRef( -- 581
			self.cam.x, -- 581
			w / math.max(0.25, self.cam.ppu) -- 581
		) -- 581
		self.audio:update(safeDt) -- 582
	end -- 582
	local ev -- 585
	local worldDt = 0 -- 586
	local uiDt = 0 -- 587
	if not p.paused then -- 589
		ev = evIn ~= nil and evIn or self.adapter:sample(p) -- 591
		self.vfx:ingest(ev, p, self.cam) -- 592
		if not trialMode then -- 593
			self.audio:ingestEvents(ev, p) -- 594
		end -- 594
		if ev.playerHit then -- 596
			input:vibrate(0.036) -- 597
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 598
			input:vibrate(0.024) -- 599
		elseif ev.coverDeflect then -- 600
			input:vibrate(0.018) -- 601
		elseif ev.knockPulse then -- 602
			input:vibrate(0.014) -- 603
		end -- 603
	else -- 603
		ev = self.adapter:emptyFrame(p) -- 607
		self.narrative.wipeT = 0 -- 608
	end -- 608
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 611
	if not p.paused then -- 612
		local clampedScale = math.max( -- 613
			0, -- 613
			math.min(2, view.timeScale) -- 613
		) -- 613
		uiDt = safeDt -- 614
		worldDt = safeDt * clampedScale -- 615
	end -- 615
	local uiScale = self:resizeInterface(w, h) -- 618
	local uiW = w / uiScale -- 619
	local uiH = h / uiScale -- 620
	local ctx = { -- 622
		p = p, -- 623
		view = view, -- 624
		events = ev, -- 625
		input = input, -- 626
		cam = self.cam, -- 627
		audio = self.audio, -- 628
		assets = self.worldArt, -- 629
		backdropArt = self.backdropArt, -- 630
		worldArt = self.worldArt, -- 631
		uiArt = self.uiArt, -- 632
		uiMask = self.uiMask, -- 633
		dioramaBg = self.dioramaBg, -- 634
		dioramaWorld = self.dioramaWorld, -- 635
		dioramaFg = self.dioramaFg, -- 636
		texts = self.texts, -- 637
		worldDt = worldDt, -- 638
		uiDt = uiDt, -- 639
		w = w, -- 640
		h = h, -- 641
		uiW = uiW, -- 642
		uiH = uiH, -- 643
		uiScale = uiScale, -- 644
		safeUi = self.stageVp.safeUi, -- 645
		paused = p.paused -- 646
	} -- 646
	local i = 0 -- 650
	do -- 650
		i = 0 -- 651
		while i < #self.plugins do -- 651
			local pl = self.plugins[i + 1] -- 652
			if pl.update ~= nil then -- 653
				pl:update(ctx) -- 654
			end -- 654
			i = i + 1 -- 651
		end -- 651
	end -- 651
	self.roguelikeUi:update(ctx) -- 657
	if not p.paused then -- 659
		self.time = self.time + worldDt -- 660
		self.cam:update(worldDt, p, w, h) -- 661
		self.escortWorld:update(worldDt, p, ev.carryStarted) -- 662
		if not trialMode then -- 663
			self.audio:setCameraRef( -- 664
				self.cam.x, -- 664
				w / math.max(0.25, self.cam.ppu) -- 664
			) -- 664
			self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 665
		end -- 665
		self.actors:update(worldDt, p) -- 667
		self.vfx:update( -- 668
			worldDt, -- 668
			themeOf(p.room.key).ambient -- 668
		) -- 668
		self.hud:update(safeDt, p) -- 669
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 670
	else -- 670
		self.cam:update(0, p, w, h) -- 672
	end -- 672
	self:clearAll() -- 675
	local backdropHandled = false -- 678
	do -- 678
		i = 0 -- 679
		while i < #self.plugins do -- 679
			local pl = self.plugins[i + 1] -- 680
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 681
				backdropHandled = true -- 682
			end -- 682
			i = i + 1 -- 679
		end -- 679
	end -- 679
	if not backdropHandled then -- 685
		self.stage:drawBackdrop( -- 686
			self.bgDraw, -- 686
			self.bgGlow, -- 686
			self.backdropArt, -- 686
			p, -- 686
			self.cam, -- 686
			self.time -- 686
		) -- 686
	end -- 686
	if view.visualMode == "pixel" then -- 688
		self.escortWorld:drawBackdropOverlay( -- 689
			self.bgDraw, -- 689
			self.bgGlow, -- 689
			self.backdropArt, -- 689
			p, -- 689
			self.cam, -- 689
			self.time, -- 689
			self.escortTowerDraw -- 689
		) -- 689
	end -- 689
	local worldHandled = false -- 693
	do -- 693
		i = 0 -- 694
		while i < #self.plugins do -- 694
			local pl = self.plugins[i + 1] -- 695
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 696
				worldHandled = true -- 697
			end -- 697
			i = i + 1 -- 694
		end -- 694
	end -- 694
	if not worldHandled then -- 700
		self.stage:drawPlayableWorld( -- 701
			self.fgDraw, -- 701
			self.fgGlow, -- 701
			self.worldArt, -- 701
			p, -- 701
			self.cam, -- 701
			self.time, -- 701
			self.occlusion, -- 701
			worldDt -- 701
		) -- 701
	end -- 701
	local propsHandled = false -- 705
	do -- 705
		i = 0 -- 706
		while i < #self.plugins do -- 706
			local pl = self.plugins[i + 1] -- 707
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 708
				propsHandled = true -- 709
			end -- 709
			i = i + 1 -- 706
		end -- 706
	end -- 706
	if not propsHandled then -- 712
		self.props:drawAll( -- 713
			self.fgDraw, -- 713
			self.fgGlow, -- 713
			self.worldArt, -- 713
			p, -- 713
			self.cam, -- 713
			self.time, -- 713
			self.occlusion, -- 713
			worldDt -- 713
		) -- 713
	end -- 713
	if view.visualMode == "pixel" then -- 715
		self.escortWorld:drawWorldSetpieces( -- 716
			self.fgDraw, -- 716
			self.fgGlow, -- 716
			self.worldArt, -- 716
			p, -- 716
			view, -- 716
			self.cam, -- 716
			self.time -- 716
		) -- 716
	end -- 716
	local suppressAllActors = view.visualMode == "museum" -- 720
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 721
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 725
	if not suppressAllActors then -- 733
		self.actors:drawAll( -- 734
			self.fgDraw, -- 734
			self.fgGlow, -- 734
			self.worldArt, -- 734
			p, -- 734
			self.cam, -- 734
			suppressPartner -- 734
		) -- 734
	end -- 734
	do -- 734
		i = 0 -- 736
		while i < #self.plugins do -- 736
			local pl = self.plugins[i + 1] -- 737
			if pl.drawActorsOverlay ~= nil then -- 738
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 739
			end -- 739
			i = i + 1 -- 736
		end -- 736
	end -- 736
	self.roguelikeUi:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 742
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 745
	if view.visualMode == "pixel" then -- 748
		self.stage:drawForegroundFraming( -- 749
			self.fgDraw, -- 749
			w, -- 749
			h, -- 749
			p, -- 749
			self.cam -- 749
		) -- 749
		self.escortWorld:drawForegroundFraming( -- 750
			self.fgDraw, -- 750
			self.fgGlow, -- 750
			self.worldArt, -- 750
			p, -- 750
			self.cam, -- 750
			self.time -- 750
		) -- 750
	end -- 750
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 752
	local action = {type = "none"} -- 755
	if p.paused then -- 756
		local isMaleRoguelike = p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() -- 757
		action = self.menus:updateAndDrawPause( -- 758
			safeDt, -- 759
			input, -- 760
			self.uiDraw, -- 761
			self.uiInkDraw, -- 762
			self.uiArt, -- 763
			self.uiGlow, -- 764
			self.texts, -- 765
			uiW, -- 766
			uiH, -- 767
			uiScale, -- 768
			view.assistHintsEnabled, -- 769
			function() -- 770
				self.contract:toggleAssistHints() -- 771
			end, -- 770
			self.stageVp.safeUi, -- 773
			isMaleRoguelike, -- 774
			view.roguelike.active, -- 775
			function() -- 776
				self.roguelikeUi:openLedger() -- 777
			end -- 776
		) -- 776
	else -- 776
		local cutsceneHandled = false -- 782
		do -- 782
			i = 0 -- 783
			while i < #self.plugins do -- 783
				local pl = self.plugins[i + 1] -- 784
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 785
					self.uiDraw, -- 786
					self.uiInkDraw, -- 786
					self.uiArt, -- 786
					self.uiGlow, -- 786
					ctx -- 786
				) then -- 786
					cutsceneHandled = true -- 787
				end -- 787
				i = i + 1 -- 783
			end -- 783
		end -- 783
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 791
		if not cutsceneHandled and not roguelikeModal then -- 792
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 793
			self.hud:draw( -- 794
				self.uiDraw, -- 795
				self.uiInkDraw, -- 796
				self.uiArt, -- 797
				self.uiGlow, -- 798
				self.texts, -- 799
				p, -- 800
				self.cam, -- 801
				self.vfx, -- 802
				self.narrative.letterbox, -- 803
				uiScale, -- 804
				view.assistHintsEnabled, -- 805
				true, -- 806
				input.inputMode, -- 807
				input.gamepadLayout, -- 808
				self.stageVp.safeUi, -- 809
				input.retryHoldProgress, -- 810
				touchOverlayVisible -- 811
			) -- 811
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 813
			local savedBannerT = self.narrative.bannerT -- 814
			if suppressBanner then -- 815
				self.narrative.bannerT = 0 -- 816
			end -- 816
			self.narrative:draw( -- 818
				self.uiDraw, -- 819
				self.uiInkDraw, -- 820
				self.uiGlow, -- 821
				self.uiArt, -- 822
				self.texts, -- 823
				p, -- 824
				uiW, -- 825
				uiH, -- 826
				view.assistHintsEnabled, -- 827
				input.inputMode, -- 828
				input.gamepadLayout, -- 829
				self.stageVp.safeUi -- 830
			) -- 830
			if suppressBanner then -- 832
				self.narrative.bannerT = savedBannerT -- 833
			end -- 833
		elseif cutsceneHandled then -- 835
			self.narrative:drawCutsceneDialogue( -- 837
				self.uiDraw, -- 838
				self.uiInkDraw, -- 839
				self.uiArt, -- 840
				self.texts, -- 841
				p, -- 842
				uiW, -- 843
				uiH, -- 844
				self.stageVp.safeUi -- 845
			) -- 845
		end -- 845
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 849
		do -- 849
			i = 0 -- 850
			while i < #self.plugins do -- 850
				do -- 850
					local pl = self.plugins[i + 1] -- 851
					if roguelikeModal and pl == self.talentDraft then -- 852
						goto __continue132 -- 853
					end -- 853
					if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 855
						self.uiDraw, -- 856
						self.uiInkDraw, -- 856
						self.uiArt, -- 856
						self.uiGlow, -- 856
						ctx -- 856
					) then -- 856
						suppressReticle = true -- 857
					end -- 857
				end -- 857
				::__continue132:: -- 857
				i = i + 1 -- 850
			end -- 850
		end -- 850
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 860
			self.uiDraw, -- 861
			self.uiInkDraw, -- 861
			self.uiArt, -- 861
			self.uiGlow, -- 861
			ctx -- 861
		) then -- 861
			suppressReticle = true -- 862
		end -- 862
		if not suppressReticle then -- 864
			self.hud:drawReticleOverlay( -- 865
				self.uiInkDraw, -- 866
				self.uiArt, -- 867
				self.uiGlow, -- 868
				p, -- 869
				self.cam, -- 870
				self.vfx, -- 871
				self.narrative.letterbox, -- 872
				uiScale, -- 873
				input:isTouchMode() -- 874
			) -- 874
		end -- 874
		if view.isRehearsal then -- 879
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 880
			drawSilkVeil( -- 881
				self.uiDraw, -- 881
				self.uiArt, -- 881
				"rehearsal_tag_veil", -- 881
				uiW * 0.5, -- 881
				uiH - 22 - self.stageVp.safeUi.top, -- 881
				168, -- 881
				26, -- 881
				PALETTE.inkWarm, -- 881
				0.74, -- 881
				8 -- 881
			) -- 881
			self.texts:put( -- 882
				"xs", -- 882
				badgeText, -- 882
				uiW * 0.5, -- 882
				uiH - 22 - self.stageVp.safeUi.top, -- 882
				toColor(PALETTE.amberCore), -- 882
				0.5, -- 882
				0.5, -- 882
				"Center", -- 882
				1.2, -- 882
				0.92, -- 882
				0.08 -- 882
			) -- 882
		end -- 882
	end -- 882
	self:drawToast(uiW) -- 886
	self:finishFrame() -- 887
	return action -- 888
end -- 569
return ____exports -- 569
