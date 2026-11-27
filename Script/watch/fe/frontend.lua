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
local ____talent_draft = require("Script.watch.fe.ui.talent_draft") -- 44
local TalentDraftPlugin = ____talent_draft.TalentDraftPlugin -- 45
local computeEscortDeathButtons = ____talent_draft.computeEscortDeathButtons -- 46
local computeTalentSlipRects = ____talent_draft.computeTalentSlipRects -- 47
local ____roguelike_ui = require("Script.watch.fe.ui.roguelike_ui") -- 49
local RoguelikeUiPlugin = ____roguelike_ui.RoguelikeUiPlugin -- 49
____exports.WatchFrontend = __TS__Class() -- 51
local WatchFrontend = ____exports.WatchFrontend -- 51
WatchFrontend.name = "WatchFrontend" -- 51
function WatchFrontend.prototype.____constructor(self, parent) -- 91
	self.occlusion = __TS__New(DepthOcclusion) -- 52
	self.cam = __TS__New(CameraDirector) -- 67
	self.adapter = __TS__New(PlayAdapter) -- 68
	self.contract = __TS__New( -- 69
		DualRouteContract, -- 69
		function(p) return self:canPickStoryTalent(p) end -- 69
	) -- 69
	self.audio = __TS__New(AudioDirector) -- 70
	self.soundscape = __TS__New(SoundscapeDirector) -- 71
	self.stage = __TS__New(StageRenderer) -- 72
	self.props = __TS__New(PropsRenderer) -- 73
	self.actors = __TS__New(ActorsRenderer) -- 74
	self.vfx = __TS__New(VfxSystem) -- 75
	self.hud = __TS__New(HudRenderer) -- 76
	self.narrative = __TS__New(NarrativeRenderer) -- 77
	self.menus = __TS__New(MenuRenderer) -- 78
	self.talentDraft = __TS__New(TalentDraftPlugin) -- 79
	self.plugins = {} -- 82
	self.screen = "title" -- 84
	self.time = 0 -- 85
	self.stageVp = computeStageViewport(1280, 720) -- 87
	self.toastText = "" -- 88
	self.toastTimer = 0 -- 89
	self.layerRoot = Node() -- 92
	self.layerRoot.order = 5 -- 93
	self.layerRoot:addTo(parent) -- 94
	self.audio:attachHost(self.layerRoot) -- 96
	self.menus.onUiSound = function(____, kind) -- 97
		self:playMenuUiSound(kind) -- 98
	end -- 97
	self.menus.onAudioSettingsChanged = function(____, inp) -- 100
		self.audio:applyUserVolumes(inp.settings) -- 101
	end -- 100
	local additive = BlendFunc("SrcAlpha", "One") -- 104
	self.bgDraw = DrawNode() -- 106
	self.bgDraw.order = 10 -- 107
	self.bgDraw:addTo(self.layerRoot) -- 108
	self.bgGlow = DrawNode() -- 110
	self.bgGlow.order = 15 -- 111
	self.bgGlow.blendFunc = additive -- 112
	self.bgGlow:addTo(self.layerRoot) -- 113
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 115
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 116
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
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 146
	self.roguelikeUi = __TS__New( -- 150
		RoguelikeUiPlugin, -- 150
		self.contract, -- 151
		function() return self.hud.talentSelected end, -- 152
		function(idx) -- 153
			self.hud.talentSelected = idx -- 154
			self.talentDraft.selected = idx -- 155
		end -- 153
	) -- 153
	self.hud.roguelikeUiHandled = true -- 158
	self.hud.talentRectProvider = function(____, w, h, count, touchMode, safeTop) -- 159
		if self.boundPlay ~= nil and self.boundPlay.talentModalActive then -- 160
			return computeTalentSlipRects( -- 161
				w, -- 161
				h, -- 161
				count, -- 161
				touchMode, -- 161
				safeTop -- 161
			) -- 161
		end -- 161
		return self.roguelikeUi:getTalentCardRects( -- 163
			w, -- 163
			h, -- 163
			count, -- 163
			touchMode, -- 163
			safeTop -- 163
		) -- 163
	end -- 159
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 178
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 179
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 180
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 181
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 182
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 183
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 184
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 185
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 186
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 187
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 188
	self:registerPlugin(self.talentDraft) -- 189
end -- 91
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 193
	local i = 0 -- 194
	do -- 194
		i = 0 -- 195
		while i < #self.plugins do -- 195
			if self.plugins[i + 1].id == plugin.id then -- 196
				self.plugins[i + 1] = plugin -- 197
				self:syncRuntimeHooks() -- 198
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 199
					plugin:onBindPlay( -- 200
						self.boundPlay, -- 200
						self.contract:peekSnapshot(self.boundPlay) -- 200
					) -- 200
				end -- 200
				return -- 202
			end -- 202
			i = i + 1 -- 195
		end -- 195
	end -- 195
	local ____self_plugins_0 = self.plugins -- 205
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 205
	self:syncRuntimeHooks() -- 206
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 207
		plugin:onBindPlay( -- 208
			self.boundPlay, -- 208
			self.contract:peekSnapshot(self.boundPlay) -- 208
		) -- 208
	end -- 208
end -- 193
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 213
	local w = 0 -- 214
	local i = 0 -- 215
	do -- 215
		i = 0 -- 216
		while i < #self.plugins do -- 216
			if self.plugins[i + 1].id ~= id then -- 217
				self.plugins[w + 1] = self.plugins[i + 1] -- 218
				w = w + 1 -- 219
			end -- 219
			i = i + 1 -- 216
		end -- 216
	end -- 216
	__TS__ArraySetLength(self.plugins, w) -- 222
	self:syncRuntimeHooks() -- 223
end -- 213
function WatchFrontend.prototype.getPlugin(self, id) -- 227
	if self.roguelikeUi ~= nil and id == self.roguelikeUi.id then -- 228
		return self.roguelikeUi -- 229
	end -- 229
	local i = 0 -- 231
	do -- 231
		i = 0 -- 232
		while i < #self.plugins do -- 232
			if self.plugins[i + 1].id == id then -- 233
				return self.plugins[i + 1] -- 234
			end -- 234
			i = i + 1 -- 232
		end -- 232
	end -- 232
	return nil -- 237
end -- 227
function WatchFrontend.prototype.getPlugins(self) -- 240
	return self.plugins -- 241
end -- 240
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 249
	local g = _G -- 250
	local ____temp_1 -- 251
	if g.package ~= nil then -- 251
		____temp_1 = g.package.loaded -- 251
	else -- 251
		____temp_1 = nil -- 251
	end -- 251
	local loaded = ____temp_1 -- 251
	if loaded == nil then -- 252
		return -- 253
	end -- 253
	local rawFe = loaded["watch.fe"] -- 255
	if rawFe ~= nil and type(rawFe) == "table" then -- 256
		local watchFe = rawFe -- 257
		if watchFe.contract ~= self.contract then -- 258
			watchFe.contract = self.contract -- 259
			watchFe.audio = self.audio -- 260
			watchFe.soundscape = self.soundscape -- 261
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 262
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 263
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 264
		end -- 264
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 266
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 267
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 268
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 269
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 270
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 271
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 272
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 273
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 274
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 275
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 276
		watchFe.talentDraft = self:getPlugin("fe-07-talent-draft") -- 277
		watchFe.roguelikeUi = self.roguelikeUi -- 278
	end -- 278
end -- 249
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 282
	local scale = math.max( -- 283
		0.25, -- 283
		math.min(w / 1280, h / 720) -- 283
	) -- 283
	self.uiLayer.scaleX = scale -- 284
	self.uiLayer.scaleY = scale -- 285
	return scale -- 286
end -- 282
function WatchFrontend.prototype.setVisible(self, v) -- 290
	self.layerRoot.visible = v -- 291
	if not v then -- 292
		self.texts:hideAll() -- 293
	end -- 293
end -- 290
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 298
	self:syncRuntimeHooks() -- 299
	self.boundPlay = p -- 300
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 301
	p.useEscortDeathSummary = true -- 302
	p:openTalentDraft() -- 303
	self.cam:snap(p, w, h) -- 304
	self.adapter:reset(p) -- 305
	self.contract:resetForRoom(p) -- 306
	self.audio:stopRoomTransient() -- 307
	self.soundscape:resetForRoom(p) -- 308
	self.actors:reset(p) -- 309
	self.occlusion:reset() -- 310
	self.vfx:reset() -- 311
	self.hud:reset(p) -- 312
	self.narrative:onEnterRoom(p.room.key) -- 313
	local initView = self.contract:peekSnapshot(p) -- 315
	if #self.plugins > 0 then -- 316
		local i = 0 -- 317
		do -- 317
			i = 0 -- 318
			while i < #self.plugins do -- 318
				local pl = self.plugins[i + 1] -- 319
				if pl.onBindPlay ~= nil then -- 320
					pl:onBindPlay(p, initView) -- 321
				end -- 321
				i = i + 1 -- 318
			end -- 318
		end -- 318
	end -- 318
	self.roguelikeUi:onBindPlay(p, initView) -- 325
end -- 298
function WatchFrontend.prototype.clearAll(self) -- 328
	self.bgDraw:clear() -- 329
	self.bgGlow:clear() -- 330
	self.fgDraw:clear() -- 331
	self.fgGlow:clear() -- 332
	self.uiDraw:clear() -- 333
	self.uiInkDraw:clear() -- 334
	self.uiGlow:clear() -- 335
	self.backdropArt:beginFrame() -- 336
	self.worldArt:beginFrame() -- 337
	self.uiArt:beginFrame() -- 338
	self.texts:beginFrame() -- 339
end -- 328
function WatchFrontend.prototype.finishFrame(self) -- 342
	self.backdropArt:endFrame() -- 343
	self.worldArt:endFrame() -- 344
	self.uiArt:endFrame() -- 345
	self.texts:endFrame() -- 346
end -- 342
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 350
	self.stageVp = vp -- 351
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 352
end -- 350
function WatchFrontend.prototype.showToast(self, text, duration) -- 356
	if duration == nil then -- 356
		duration = 1.8 -- 356
	end -- 356
	self.toastText = text -- 357
	self.toastTimer = duration -- 358
end -- 356
function WatchFrontend.prototype.getToastText(self) -- 361
	return self.toastTimer > 0 and self.toastText or "" -- 362
end -- 361
function WatchFrontend.prototype.drawToast(self, uiW) -- 365
	if self.toastTimer <= 0 or self.toastText == "" then -- 366
		return -- 367
	end -- 367
	local alpha = math.min(1, self.toastTimer * 2.4) -- 369
	local cx = uiW * 0.5 -- 370
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 371
	drawSilkVeil( -- 372
		self.uiDraw, -- 372
		self.uiArt, -- 372
		"fe_toast_veil", -- 372
		cx, -- 372
		cy, -- 372
		340, -- 372
		38, -- 372
		PALETTE.inkWarm, -- 372
		0.86 * alpha, -- 372
		9 -- 372
	) -- 372
	self.texts:put( -- 373
		"sm", -- 373
		self.toastText, -- 373
		cx, -- 373
		cy, -- 373
		toColor(PALETTE.amberCore), -- 373
		0.5, -- 373
		0.5, -- 373
		"Center", -- 373
		1.4, -- 373
		0.96 * alpha, -- 373
		0.08 -- 373
	) -- 373
end -- 365
function WatchFrontend.prototype.canPickStoryTalent(self, p) -- 376
	if p.paused or p.craftBench.active or p.reloadOpen or p.escortFailed then -- 377
		return false -- 378
	end -- 378
	if self.roguelikeUi:isLedgerOpen() then -- 380
		return false -- 381
	end -- 381
	if p.talentModalActive then -- 383
		return #p:getStoryTalentOffers() > 0 -- 384
	end -- 384
	return self.roguelikeUi:canPickTalent() -- 386
end -- 376
function WatchFrontend.prototype.isLedgerOpen(self) -- 389
	return self.roguelikeUi:isLedgerOpen() -- 390
end -- 389
function WatchFrontend.prototype.getLedgerButtonBox(self) -- 393
	local box = self.roguelikeUi:getLedgerButtonRect() -- 394
	return box.width > 0 and box.height > 0 and box or nil -- 395
end -- 393
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 399
	local offers = p:getStoryTalentOffers() -- 400
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 401
		return {} -- 402
	end -- 402
	local uiScale = math.max( -- 404
		0.25, -- 404
		math.min(w / 1280, h / 720) -- 404
	) -- 404
	return self.hud:talentCardRects( -- 405
		w / uiScale, -- 405
		h / uiScale, -- 405
		#offers, -- 405
		touchMode, -- 405
		self.stageVp.safeUi.top -- 405
	) -- 405
end -- 399
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 409
	if not p.escortFailed then -- 410
		return nil -- 411
	end -- 411
	local uiScale = math.max( -- 413
		0.25, -- 413
		math.min(w / 1280, h / 720) -- 413
	) -- 413
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 414
end -- 409
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 418
	if not p.escortFailed then -- 419
		return "" -- 420
	end -- 420
	if input.inputMode == "gamepad" and not input.uiPressed then -- 422
		return "" -- 423
	end -- 423
	local useUiPtr = input.uiInside or input.uiPressed -- 425
	local ____useUiPtr_2 -- 426
	if useUiPtr then -- 426
		____useUiPtr_2 = input.uiInside -- 426
	else -- 426
		____useUiPtr_2 = input.inside -- 426
	end -- 426
	local inside = ____useUiPtr_2 -- 426
	if not inside then -- 427
		return "" -- 428
	end -- 428
	local uiScale = math.max( -- 430
		0.25, -- 430
		math.min(w / 1280, h / 720) -- 430
	) -- 430
	local rawX = useUiPtr and input.uiX or input.mx -- 431
	local rawY = useUiPtr and input.uiY or input.my -- 432
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 433
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 434
	if btns.retry:containsPoint(pointer) then -- 435
		self.talentDraft.deathSelected = 0 -- 436
		return "retry" -- 437
	end -- 437
	if btns.title:containsPoint(pointer) then -- 439
		self.talentDraft.deathSelected = 1 -- 440
		return "title" -- 441
	end -- 441
	return "" -- 443
end -- 418
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 446
	if kind == "hover" then -- 447
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 448
	elseif kind == "confirm" then -- 449
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 450
	elseif kind == "back" then -- 451
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 452
	elseif kind == "start" then -- 453
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 454
	elseif kind == "pauseOpen" then -- 455
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 456
	elseif kind == "pauseClose" then -- 457
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 458
	elseif kind == "toggle" then -- 459
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 460
	end -- 460
end -- 446
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 465
	self:syncRuntimeHooks() -- 466
	local safeDt = math.min( -- 467
		0.05, -- 467
		math.max(0, dt) -- 467
	) -- 467
	if self.toastTimer > 0 then -- 468
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 469
	end -- 469
	if self.screen == "title" and self.boundPlay ~= nil then -- 471
		self.audio:stopRoomTransient() -- 472
		self.boundPlay = nil -- 473
	end -- 473
	self.audio:update(safeDt) -- 475
	self.soundscape:updateMenu(self.screen, self.audio) -- 476
	self:setVisible(true) -- 477
	self:clearAll() -- 478
	local uiScale = self:resizeInterface(w, h) -- 479
	local act = self.menus:updateAndDrawScreen( -- 480
		dt, -- 481
		self.screen, -- 482
		input, -- 483
		self.stage, -- 484
		self.bgDraw, -- 485
		self.bgGlow, -- 486
		self.backdropArt, -- 487
		self.uiArt, -- 488
		self.uiDraw, -- 489
		self.uiInkDraw, -- 490
		self.uiGlow, -- 491
		self.texts, -- 492
		w, -- 493
		h, -- 494
		uiScale, -- 495
		self.stageVp.safeUi -- 496
	) -- 496
	self:drawToast(w / uiScale) -- 498
	self:finishFrame() -- 499
	return act -- 500
end -- 465
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 504
	local offers = p:getStoryTalentOffers() -- 505
	if not self:canPickStoryTalent(p) or #offers == 0 then -- 506
		return false -- 507
	end -- 507
	if input.inputMode == "gamepad" and not input.uiPressed then -- 509
		return false -- 510
	end -- 510
	local useUiPtr = input.uiInside or input.uiPressed -- 512
	local ____useUiPtr_3 -- 513
	if useUiPtr then -- 513
		____useUiPtr_3 = input.uiInside -- 513
	else -- 513
		____useUiPtr_3 = input.inside -- 513
	end -- 513
	local inside = ____useUiPtr_3 -- 513
	if not inside then -- 514
		return false -- 515
	end -- 515
	local uiScale = math.max( -- 517
		0.25, -- 517
		math.min(w / 1280, h / 720) -- 517
	) -- 517
	local uiW = w / uiScale -- 518
	local uiH = h / uiScale -- 519
	local rawX = useUiPtr and input.uiX or input.mx -- 520
	local rawY = useUiPtr and input.uiY or input.my -- 521
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 522
	local boxes = self.hud:talentCardRects( -- 523
		uiW, -- 523
		uiH, -- 523
		#offers, -- 523
		input:isTouchMode(), -- 523
		self.stageVp.safeUi.top -- 523
	) -- 523
	local i = 0 -- 524
	do -- 524
		i = 0 -- 525
		while i < #boxes do -- 525
			if boxes[i + 1]:containsPoint(pointer) then -- 526
				self.talentDraft.selected = i -- 527
				self.hud.talentSelected = i -- 528
				return p:chooseTalent(i) -- 529
			end -- 529
			i = i + 1 -- 525
		end -- 525
	end -- 525
	local ledger = self.roguelikeUi:getLedgerButtonRect() -- 532
	local toggle = self.roguelikeUi:getExpandToggleRect() -- 533
	return ledger.width > 0 and ledger:containsPoint(pointer) or toggle.width > 0 and toggle:containsPoint(pointer) -- 534
end -- 504
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h, trialMode, evIn) -- 539
	if trialMode == nil then -- 539
		trialMode = false -- 539
	end -- 539
	self:syncRuntimeHooks() -- 540
	self:setVisible(true) -- 541
	if self.boundPlay ~= p then -- 542
		self:bindPlay(p, w, h) -- 543
	end -- 543
	local safeDt = math.min( -- 545
		0.05, -- 545
		math.max(0.001, dt) -- 545
	) -- 545
	if self.toastTimer > 0 then -- 546
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 547
	end -- 547
	if not trialMode then -- 549
		self.audio:setPaused(p.paused) -- 550
		self.audio:setCameraRef( -- 551
			self.cam.x, -- 551
			w / math.max(0.25, self.cam.ppu) -- 551
		) -- 551
		self.audio:update(safeDt) -- 552
	end -- 552
	local ev -- 555
	local worldDt = 0 -- 556
	local uiDt = 0 -- 557
	if not p.paused then -- 559
		ev = evIn ~= nil and evIn or self.adapter:sample(p) -- 561
		self.vfx:ingest(ev, p, self.cam) -- 562
		if not trialMode then -- 563
			self.audio:ingestEvents(ev, p) -- 564
		end -- 564
		if ev.playerHit then -- 566
			input:vibrate(0.036) -- 567
		elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 568
			input:vibrate(0.024) -- 569
		elseif ev.coverDeflect then -- 570
			input:vibrate(0.018) -- 571
		elseif ev.knockPulse then -- 572
			input:vibrate(0.014) -- 573
		end -- 573
	else -- 573
		ev = self.adapter:emptyFrame(p) -- 577
		self.narrative.wipeT = 0 -- 578
	end -- 578
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 581
	if not p.paused then -- 582
		local clampedScale = math.max( -- 583
			0, -- 583
			math.min(2, view.timeScale) -- 583
		) -- 583
		uiDt = safeDt -- 584
		worldDt = safeDt * clampedScale -- 585
	end -- 585
	local uiScale = self:resizeInterface(w, h) -- 588
	local uiW = w / uiScale -- 589
	local uiH = h / uiScale -- 590
	local ctx = { -- 592
		p = p, -- 593
		view = view, -- 594
		events = ev, -- 595
		input = input, -- 596
		cam = self.cam, -- 597
		audio = self.audio, -- 598
		assets = self.worldArt, -- 599
		backdropArt = self.backdropArt, -- 600
		worldArt = self.worldArt, -- 601
		uiArt = self.uiArt, -- 602
		texts = self.texts, -- 603
		worldDt = worldDt, -- 604
		uiDt = uiDt, -- 605
		w = w, -- 606
		h = h, -- 607
		uiW = uiW, -- 608
		uiH = uiH, -- 609
		uiScale = uiScale, -- 610
		safeUi = self.stageVp.safeUi, -- 611
		paused = p.paused -- 612
	} -- 612
	local i = 0 -- 616
	do -- 616
		i = 0 -- 617
		while i < #self.plugins do -- 617
			local pl = self.plugins[i + 1] -- 618
			if pl.update ~= nil then -- 619
				pl:update(ctx) -- 620
			end -- 620
			i = i + 1 -- 617
		end -- 617
	end -- 617
	self.roguelikeUi:update(ctx) -- 623
	if not p.paused then -- 625
		self.time = self.time + worldDt -- 626
		self.cam:update(worldDt, p, w, h) -- 627
		if not trialMode then -- 628
			self.audio:setCameraRef( -- 629
				self.cam.x, -- 629
				w / math.max(0.25, self.cam.ppu) -- 629
			) -- 629
			self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 630
		end -- 630
		self.actors:update(worldDt, p) -- 632
		self.vfx:update( -- 633
			worldDt, -- 633
			themeOf(p.room.key).ambient -- 633
		) -- 633
		self.hud:update(safeDt, p) -- 634
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 635
	else -- 635
		self.cam:update(0, p, w, h) -- 637
	end -- 637
	self:clearAll() -- 640
	local backdropHandled = false -- 643
	do -- 643
		i = 0 -- 644
		while i < #self.plugins do -- 644
			local pl = self.plugins[i + 1] -- 645
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 646
				backdropHandled = true -- 647
			end -- 647
			i = i + 1 -- 644
		end -- 644
	end -- 644
	if not backdropHandled then -- 650
		self.stage:drawBackdrop( -- 651
			self.bgDraw, -- 651
			self.bgGlow, -- 651
			self.backdropArt, -- 651
			p, -- 651
			self.cam, -- 651
			self.time -- 651
		) -- 651
	end -- 651
	local worldHandled = false -- 655
	do -- 655
		i = 0 -- 656
		while i < #self.plugins do -- 656
			local pl = self.plugins[i + 1] -- 657
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 658
				worldHandled = true -- 659
			end -- 659
			i = i + 1 -- 656
		end -- 656
	end -- 656
	if not worldHandled then -- 662
		self.stage:drawPlayableWorld( -- 663
			self.fgDraw, -- 663
			self.fgGlow, -- 663
			self.worldArt, -- 663
			p, -- 663
			self.cam, -- 663
			self.time, -- 663
			self.occlusion, -- 663
			worldDt -- 663
		) -- 663
	end -- 663
	local propsHandled = false -- 667
	do -- 667
		i = 0 -- 668
		while i < #self.plugins do -- 668
			local pl = self.plugins[i + 1] -- 669
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 670
				propsHandled = true -- 671
			end -- 671
			i = i + 1 -- 668
		end -- 668
	end -- 668
	if not propsHandled then -- 674
		self.props:drawAll( -- 675
			self.fgDraw, -- 675
			self.fgGlow, -- 675
			self.worldArt, -- 675
			p, -- 675
			self.cam, -- 675
			self.time, -- 675
			self.occlusion, -- 675
			worldDt -- 675
		) -- 675
	end -- 675
	local suppressAllActors = view.visualMode == "museum" -- 679
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 680
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 684
	if not suppressAllActors then -- 692
		self.actors:drawAll( -- 693
			self.fgDraw, -- 693
			self.fgGlow, -- 693
			self.worldArt, -- 693
			p, -- 693
			self.cam, -- 693
			suppressPartner -- 693
		) -- 693
	end -- 693
	do -- 693
		i = 0 -- 695
		while i < #self.plugins do -- 695
			local pl = self.plugins[i + 1] -- 696
			if pl.drawActorsOverlay ~= nil then -- 697
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 698
			end -- 698
			i = i + 1 -- 695
		end -- 695
	end -- 695
	self.roguelikeUi:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 701
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 704
	if view.visualMode == "pixel" then -- 707
		self.stage:drawForegroundFraming( -- 708
			self.fgDraw, -- 708
			w, -- 708
			h, -- 708
			p, -- 708
			self.cam -- 708
		) -- 708
	end -- 708
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 710
	local action = {type = "none"} -- 713
	if p.paused then -- 714
		local isMaleRoguelike = p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() -- 715
		action = self.menus:updateAndDrawPause( -- 716
			safeDt, -- 717
			input, -- 718
			self.uiDraw, -- 719
			self.uiInkDraw, -- 720
			self.uiArt, -- 721
			self.uiGlow, -- 722
			self.texts, -- 723
			uiW, -- 724
			uiH, -- 725
			uiScale, -- 726
			view.assistHintsEnabled, -- 727
			function() -- 728
				self.contract:toggleAssistHints() -- 729
			end, -- 728
			self.stageVp.safeUi, -- 731
			isMaleRoguelike, -- 732
			view.roguelike.active, -- 733
			function() -- 734
				self.roguelikeUi:openLedger() -- 735
			end -- 734
		) -- 734
	else -- 734
		local cutsceneHandled = false -- 740
		do -- 740
			i = 0 -- 741
			while i < #self.plugins do -- 741
				local pl = self.plugins[i + 1] -- 742
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 743
					self.uiDraw, -- 744
					self.uiInkDraw, -- 744
					self.uiArt, -- 744
					self.uiGlow, -- 744
					ctx -- 744
				) then -- 744
					cutsceneHandled = true -- 745
				end -- 745
				i = i + 1 -- 741
			end -- 741
		end -- 741
		local roguelikeModal = not cutsceneHandled and self.roguelikeUi:isModalOverlayActive() -- 749
		if not cutsceneHandled and not roguelikeModal then -- 750
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 751
			self.hud:draw( -- 752
				self.uiDraw, -- 753
				self.uiInkDraw, -- 754
				self.uiArt, -- 755
				self.uiGlow, -- 756
				self.texts, -- 757
				p, -- 758
				self.cam, -- 759
				self.vfx, -- 760
				self.narrative.letterbox, -- 761
				uiScale, -- 762
				view.assistHintsEnabled, -- 763
				true, -- 764
				input.inputMode, -- 765
				input.gamepadLayout, -- 766
				self.stageVp.safeUi, -- 767
				input.retryHoldProgress, -- 768
				touchOverlayVisible -- 769
			) -- 769
			local suppressBanner = self.roguelikeUi:isSuppressingRoomBanner() -- 771
			local savedBannerT = self.narrative.bannerT -- 772
			if suppressBanner then -- 773
				self.narrative.bannerT = 0 -- 774
			end -- 774
			self.narrative:draw( -- 776
				self.uiDraw, -- 777
				self.uiInkDraw, -- 778
				self.uiGlow, -- 779
				self.uiArt, -- 780
				self.texts, -- 781
				p, -- 782
				uiW, -- 783
				uiH, -- 784
				view.assistHintsEnabled, -- 785
				input.inputMode, -- 786
				input.gamepadLayout, -- 787
				self.stageVp.safeUi -- 788
			) -- 788
			if suppressBanner then -- 790
				self.narrative.bannerT = savedBannerT -- 791
			end -- 791
		elseif cutsceneHandled then -- 793
			self.narrative:drawCutsceneDialogue( -- 795
				self.uiDraw, -- 796
				self.uiInkDraw, -- 797
				self.uiArt, -- 798
				self.texts, -- 799
				p, -- 800
				uiW, -- 801
				uiH, -- 802
				self.stageVp.safeUi -- 803
			) -- 803
		end -- 803
		local suppressReticle = cutsceneHandled or roguelikeModal or view.reloadSession.active or view.craftBench.active -- 807
		do -- 807
			i = 0 -- 808
			while i < #self.plugins do -- 808
				do -- 808
					local pl = self.plugins[i + 1] -- 809
					if roguelikeModal and pl == self.talentDraft then -- 810
						goto __continue130 -- 811
					end -- 811
					if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 813
						self.uiDraw, -- 814
						self.uiInkDraw, -- 814
						self.uiArt, -- 814
						self.uiGlow, -- 814
						ctx -- 814
					) then -- 814
						suppressReticle = true -- 815
					end -- 815
				end -- 815
				::__continue130:: -- 815
				i = i + 1 -- 808
			end -- 808
		end -- 808
		if not cutsceneHandled and self.roguelikeUi:drawFullSpeedUi( -- 818
			self.uiDraw, -- 819
			self.uiInkDraw, -- 819
			self.uiArt, -- 819
			self.uiGlow, -- 819
			ctx -- 819
		) then -- 819
			suppressReticle = true -- 820
		end -- 820
		if not suppressReticle then -- 822
			self.hud:drawReticleOverlay( -- 823
				self.uiInkDraw, -- 824
				self.uiArt, -- 825
				self.uiGlow, -- 826
				p, -- 827
				self.cam, -- 828
				self.vfx, -- 829
				self.narrative.letterbox, -- 830
				uiScale, -- 831
				input:isTouchMode() -- 832
			) -- 832
		end -- 832
		if view.isRehearsal then -- 837
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 838
			drawSilkVeil( -- 839
				self.uiDraw, -- 839
				self.uiArt, -- 839
				"rehearsal_tag_veil", -- 839
				uiW * 0.5, -- 839
				uiH - 22 - self.stageVp.safeUi.top, -- 839
				168, -- 839
				26, -- 839
				PALETTE.inkWarm, -- 839
				0.74, -- 839
				8 -- 839
			) -- 839
			self.texts:put( -- 840
				"xs", -- 840
				badgeText, -- 840
				uiW * 0.5, -- 840
				uiH - 22 - self.stageVp.safeUi.top, -- 840
				toColor(PALETTE.amberCore), -- 840
				0.5, -- 840
				0.5, -- 840
				"Center", -- 840
				1.2, -- 840
				0.92, -- 840
				0.08 -- 840
			) -- 840
		end -- 840
	end -- 840
	self:drawToast(uiW) -- 844
	self:finishFrame() -- 845
	return action -- 846
end -- 539
return ____exports -- 539
