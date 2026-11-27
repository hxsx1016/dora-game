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
____exports.WatchFrontend = __TS__Class() -- 50
local WatchFrontend = ____exports.WatchFrontend -- 50
WatchFrontend.name = "WatchFrontend" -- 50
function WatchFrontend.prototype.____constructor(self, parent) -- 89
	self.occlusion = __TS__New(DepthOcclusion) -- 51
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
	self.talentDraft = __TS__New(TalentDraftPlugin) -- 78
	self.plugins = {} -- 80
	self.screen = "title" -- 82
	self.time = 0 -- 83
	self.stageVp = computeStageViewport(1280, 720) -- 85
	self.toastText = "" -- 86
	self.toastTimer = 0 -- 87
	self.layerRoot = Node() -- 90
	self.layerRoot.order = 5 -- 91
	self.layerRoot:addTo(parent) -- 92
	self.audio:attachHost(self.layerRoot) -- 94
	self.menus.onUiSound = function(____, kind) -- 95
		self:playMenuUiSound(kind) -- 96
	end -- 95
	self.menus.onAudioSettingsChanged = function(____, inp) -- 98
		self.audio:applyUserVolumes(inp.settings) -- 99
	end -- 98
	local additive = BlendFunc("SrcAlpha", "One") -- 102
	self.bgDraw = DrawNode() -- 104
	self.bgDraw.order = 10 -- 105
	self.bgDraw:addTo(self.layerRoot) -- 106
	self.bgGlow = DrawNode() -- 108
	self.bgGlow.order = 15 -- 109
	self.bgGlow.blendFunc = additive -- 110
	self.bgGlow:addTo(self.layerRoot) -- 111
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 113
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 114
	self.fgDraw = DrawNode() -- 116
	self.fgDraw.order = 30 -- 117
	self.fgDraw:addTo(self.layerRoot) -- 118
	self.fgGlow = DrawNode() -- 120
	self.fgGlow.order = 35 -- 121
	self.fgGlow.blendFunc = additive -- 122
	self.fgGlow:addTo(self.layerRoot) -- 123
	self.uiLayer = Node() -- 125
	self.uiLayer.order = 40 -- 126
	self.uiLayer:addTo(self.layerRoot) -- 127
	self.uiDraw = DrawNode() -- 129
	self.uiDraw.order = 0 -- 130
	self.uiDraw:addTo(self.uiLayer) -- 131
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 133
	self.uiInkDraw = DrawNode() -- 135
	self.uiInkDraw.order = 4 -- 136
	self.uiInkDraw:addTo(self.uiLayer) -- 137
	self.uiGlow = DrawNode() -- 139
	self.uiGlow.order = 6 -- 140
	self.uiGlow.blendFunc = additive -- 141
	self.uiGlow:addTo(self.uiLayer) -- 142
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 144
	self:registerPlugin(__TS__New(MingArtAuditPlugin)) -- 158
	self:registerPlugin(__TS__New(GateTransitionPlugin)) -- 159
	self:registerPlugin(__TS__New(LowpolyWorldPlugin)) -- 160
	self:registerPlugin(__TS__New(AfterimageArtifactPlugin)) -- 161
	self:registerPlugin(__TS__New(CarryPosePlugin)) -- 162
	self:registerPlugin(__TS__New(PrologueIntroPlugin)) -- 163
	self:registerPlugin(__TS__New(CuffShotsPlugin)) -- 164
	self:registerPlugin(__TS__New(TowerEndingsPlugin)) -- 165
	self:registerPlugin(__TS__New(WellMuseumPlugin, self.contract)) -- 166
	self:registerPlugin(__TS__New(ReloadWheelPlugin, self.contract)) -- 167
	self:registerPlugin(__TS__New(CraftBenchPlugin, self.contract)) -- 168
	self:registerPlugin(self.talentDraft) -- 169
end -- 89
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 173
	local i = 0 -- 174
	do -- 174
		i = 0 -- 175
		while i < #self.plugins do -- 175
			if self.plugins[i + 1].id == plugin.id then -- 176
				self.plugins[i + 1] = plugin -- 177
				self:syncRuntimeHooks() -- 178
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 179
					plugin:onBindPlay( -- 180
						self.boundPlay, -- 180
						self.contract:peekSnapshot(self.boundPlay) -- 180
					) -- 180
				end -- 180
				return -- 182
			end -- 182
			i = i + 1 -- 175
		end -- 175
	end -- 175
	local ____self_plugins_0 = self.plugins -- 185
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 185
	self:syncRuntimeHooks() -- 186
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 187
		plugin:onBindPlay( -- 188
			self.boundPlay, -- 188
			self.contract:peekSnapshot(self.boundPlay) -- 188
		) -- 188
	end -- 188
end -- 173
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 193
	local w = 0 -- 194
	local i = 0 -- 195
	do -- 195
		i = 0 -- 196
		while i < #self.plugins do -- 196
			if self.plugins[i + 1].id ~= id then -- 197
				self.plugins[w + 1] = self.plugins[i + 1] -- 198
				w = w + 1 -- 199
			end -- 199
			i = i + 1 -- 196
		end -- 196
	end -- 196
	__TS__ArraySetLength(self.plugins, w) -- 202
	self:syncRuntimeHooks() -- 203
end -- 193
function WatchFrontend.prototype.getPlugin(self, id) -- 207
	local i = 0 -- 208
	do -- 208
		i = 0 -- 209
		while i < #self.plugins do -- 209
			if self.plugins[i + 1].id == id then -- 210
				return self.plugins[i + 1] -- 211
			end -- 211
			i = i + 1 -- 209
		end -- 209
	end -- 209
	return nil -- 214
end -- 207
function WatchFrontend.prototype.getPlugins(self) -- 217
	return self.plugins -- 218
end -- 217
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 226
	local g = _G -- 227
	local ____temp_1 -- 228
	if g.package ~= nil then -- 228
		____temp_1 = g.package.loaded -- 228
	else -- 228
		____temp_1 = nil -- 228
	end -- 228
	local loaded = ____temp_1 -- 228
	if loaded == nil then -- 229
		return -- 230
	end -- 230
	local rawFe = loaded["watch.fe"] -- 232
	if rawFe ~= nil and type(rawFe) == "table" then -- 233
		local watchFe = rawFe -- 234
		if watchFe.contract ~= self.contract then -- 235
			watchFe.contract = self.contract -- 236
			watchFe.audio = self.audio -- 237
			watchFe.soundscape = self.soundscape -- 238
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 239
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 240
			watchFe.getPlugin = function(id) return self:getPlugin(id) end -- 241
		end -- 241
		watchFe.mingAudit = self:getPlugin("fe03-ming-audit") -- 243
		watchFe.gateTransition = self:getPlugin("fe-01-gate-transition") -- 244
		watchFe.lowpolyWorld = self:getPlugin("fe-04-child-lowpoly") -- 245
		watchFe.afterimageArtifact = self:getPlugin("fe-06-afterimage-artifact") -- 246
		watchFe.carryPose = self:getPlugin("fe-02-carry-pose") -- 247
		watchFe.prologue = self:getPlugin("fe03-prologue-intro") -- 248
		watchFe.cuffShots = self:getPlugin("fe-01-cuff-shots") -- 249
		watchFe.towerEndings = self:getPlugin("fe-05-tower-endings") -- 250
		watchFe.wellMuseum = self:getPlugin("fe-06-well-museum") -- 251
		watchFe.reloadWheel = self:getPlugin("fe-02-reload-wheel") -- 252
		watchFe.craftBench = self:getPlugin("fe-02-craft-bench") -- 253
		watchFe.talentDraft = self:getPlugin("fe-07-talent-draft") -- 254
	end -- 254
end -- 226
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 258
	local scale = math.max( -- 259
		0.25, -- 259
		math.min(w / 1280, h / 720) -- 259
	) -- 259
	self.uiLayer.scaleX = scale -- 260
	self.uiLayer.scaleY = scale -- 261
	return scale -- 262
end -- 258
function WatchFrontend.prototype.setVisible(self, v) -- 266
	self.layerRoot.visible = v -- 267
	if not v then -- 268
		self.texts:hideAll() -- 269
	end -- 269
end -- 266
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 274
	self:syncRuntimeHooks() -- 275
	self.boundPlay = p -- 276
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 277
	p.useEscortDeathSummary = true -- 278
	p:openTalentDraft() -- 279
	self.cam:snap(p, w, h) -- 280
	self.adapter:reset(p) -- 281
	self.contract:resetForRoom(p) -- 282
	self.audio:stopRoomTransient() -- 283
	self.soundscape:resetForRoom(p) -- 284
	self.actors:reset(p) -- 285
	self.occlusion:reset() -- 286
	self.vfx:reset() -- 287
	self.hud:reset(p) -- 288
	self.narrative:onEnterRoom(p.room.key) -- 289
	if #self.plugins > 0 then -- 291
		local initView = self.contract:peekSnapshot(p) -- 292
		local i = 0 -- 293
		do -- 293
			i = 0 -- 294
			while i < #self.plugins do -- 294
				local pl = self.plugins[i + 1] -- 295
				if pl.onBindPlay ~= nil then -- 296
					pl:onBindPlay(p, initView) -- 297
				end -- 297
				i = i + 1 -- 294
			end -- 294
		end -- 294
	end -- 294
end -- 274
function WatchFrontend.prototype.clearAll(self) -- 303
	self.bgDraw:clear() -- 304
	self.bgGlow:clear() -- 305
	self.fgDraw:clear() -- 306
	self.fgGlow:clear() -- 307
	self.uiDraw:clear() -- 308
	self.uiInkDraw:clear() -- 309
	self.uiGlow:clear() -- 310
	self.backdropArt:beginFrame() -- 311
	self.worldArt:beginFrame() -- 312
	self.uiArt:beginFrame() -- 313
	self.texts:beginFrame() -- 314
end -- 303
function WatchFrontend.prototype.finishFrame(self) -- 317
	self.backdropArt:endFrame() -- 318
	self.worldArt:endFrame() -- 319
	self.uiArt:endFrame() -- 320
	self.texts:endFrame() -- 321
end -- 317
function WatchFrontend.prototype.setStagePlacement(self, vp) -- 325
	self.stageVp = vp -- 326
	self.layerRoot.position = Vec2(vp.stageX, vp.stageY) -- 327
end -- 325
function WatchFrontend.prototype.showToast(self, text, duration) -- 331
	if duration == nil then -- 331
		duration = 1.8 -- 331
	end -- 331
	self.toastText = text -- 332
	self.toastTimer = duration -- 333
end -- 331
function WatchFrontend.prototype.getToastText(self) -- 336
	return self.toastTimer > 0 and self.toastText or "" -- 337
end -- 336
function WatchFrontend.prototype.drawToast(self, uiW) -- 340
	if self.toastTimer <= 0 or self.toastText == "" then -- 341
		return -- 342
	end -- 342
	local alpha = math.min(1, self.toastTimer * 2.4) -- 344
	local cx = uiW * 0.5 -- 345
	local cy = 82 + self.stageVp.safeUi.bottom * 0.6 -- 346
	drawSilkVeil( -- 347
		self.uiDraw, -- 347
		self.uiArt, -- 347
		"fe_toast_veil", -- 347
		cx, -- 347
		cy, -- 347
		340, -- 347
		38, -- 347
		PALETTE.inkWarm, -- 347
		0.86 * alpha, -- 347
		9 -- 347
	) -- 347
	self.texts:put( -- 348
		"sm", -- 348
		self.toastText, -- 348
		cx, -- 348
		cy, -- 348
		toColor(PALETTE.amberCore), -- 348
		0.5, -- 348
		0.5, -- 348
		"Center", -- 348
		1.4, -- 348
		0.96 * alpha, -- 348
		0.08 -- 348
	) -- 348
end -- 340
function WatchFrontend.prototype.getStoryTalentBoxes(self, p, w, h, touchMode) -- 352
	local offers = p:getStoryTalentOffers() -- 353
	if #offers == 0 or p.escortFailed then -- 354
		return {} -- 355
	end -- 355
	local uiScale = math.max( -- 357
		0.25, -- 357
		math.min(w / 1280, h / 720) -- 357
	) -- 357
	return computeTalentSlipRects( -- 358
		w / uiScale, -- 358
		h / uiScale, -- 358
		#offers, -- 358
		touchMode, -- 358
		self.stageVp.safeUi.top -- 358
	) -- 358
end -- 352
function WatchFrontend.prototype.getEscortDeathBoxes(self, p, w, h) -- 362
	if not p.escortFailed then -- 363
		return nil -- 364
	end -- 364
	local uiScale = math.max( -- 366
		0.25, -- 366
		math.min(w / 1280, h / 720) -- 366
	) -- 366
	return computeEscortDeathButtons(w / uiScale, h / uiScale) -- 367
end -- 362
function WatchFrontend.prototype.tryPickEscortDeathAtPointer(self, p, input, w, h) -- 371
	if not p.escortFailed then -- 372
		return "" -- 373
	end -- 373
	if input.inputMode == "gamepad" and not input.uiPressed then -- 375
		return "" -- 376
	end -- 376
	local useUiPtr = input.uiInside or input.uiPressed -- 378
	local ____useUiPtr_2 -- 379
	if useUiPtr then -- 379
		____useUiPtr_2 = input.uiInside -- 379
	else -- 379
		____useUiPtr_2 = input.inside -- 379
	end -- 379
	local inside = ____useUiPtr_2 -- 379
	if not inside then -- 380
		return "" -- 381
	end -- 381
	local uiScale = math.max( -- 383
		0.25, -- 383
		math.min(w / 1280, h / 720) -- 383
	) -- 383
	local rawX = useUiPtr and input.uiX or input.mx -- 384
	local rawY = useUiPtr and input.uiY or input.my -- 385
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 386
	local btns = computeEscortDeathButtons(w / uiScale, h / uiScale) -- 387
	if btns.retry:containsPoint(pointer) then -- 388
		self.talentDraft.deathSelected = 0 -- 389
		return "retry" -- 390
	end -- 390
	if btns.title:containsPoint(pointer) then -- 392
		self.talentDraft.deathSelected = 1 -- 393
		return "title" -- 394
	end -- 394
	return "" -- 396
end -- 371
function WatchFrontend.prototype.playMenuUiSound(self, kind) -- 399
	if kind == "hover" then -- 400
		self.audio:playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.5, 0.045) -- 401
	elseif kind == "confirm" then -- 402
		self.audio:playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05) -- 403
	elseif kind == "back" then -- 404
		self.audio:playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05) -- 405
	elseif kind == "start" then -- 406
		self.audio:playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08) -- 407
	elseif kind == "pauseOpen" then -- 408
		self.audio:playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08) -- 409
	elseif kind == "pauseClose" then -- 410
		self.audio:playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08) -- 411
	elseif kind == "toggle" then -- 412
		self.audio:playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04) -- 413
	end -- 413
end -- 399
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 418
	self:syncRuntimeHooks() -- 419
	local safeDt = math.min( -- 420
		0.05, -- 420
		math.max(0, dt) -- 420
	) -- 420
	if self.toastTimer > 0 then -- 421
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 422
	end -- 422
	if self.screen == "title" and self.boundPlay ~= nil then -- 424
		self.audio:stopRoomTransient() -- 425
		self.boundPlay = nil -- 426
	end -- 426
	self.audio:update(safeDt) -- 428
	self.soundscape:updateMenu(self.screen, self.audio) -- 429
	self:setVisible(true) -- 430
	self:clearAll() -- 431
	local uiScale = self:resizeInterface(w, h) -- 432
	local act = self.menus:updateAndDrawScreen( -- 433
		dt, -- 434
		self.screen, -- 435
		input, -- 436
		self.stage, -- 437
		self.bgDraw, -- 438
		self.bgGlow, -- 439
		self.backdropArt, -- 440
		self.uiArt, -- 441
		self.uiDraw, -- 442
		self.uiInkDraw, -- 443
		self.uiGlow, -- 444
		self.texts, -- 445
		w, -- 446
		h, -- 447
		uiScale, -- 448
		self.stageVp.safeUi -- 449
	) -- 449
	self:drawToast(w / uiScale) -- 451
	self:finishFrame() -- 452
	return act -- 453
end -- 418
function WatchFrontend.prototype.tryPickTalentAtPointer(self, p, input, w, h) -- 457
	local offers = p:getStoryTalentOffers() -- 458
	if #offers == 0 then -- 459
		return false -- 460
	end -- 460
	if input.inputMode == "gamepad" and not input.uiPressed then -- 462
		return false -- 463
	end -- 463
	local useUiPtr = input.uiInside or input.uiPressed -- 465
	local ____useUiPtr_3 -- 466
	if useUiPtr then -- 466
		____useUiPtr_3 = input.uiInside -- 466
	else -- 466
		____useUiPtr_3 = input.inside -- 466
	end -- 466
	local inside = ____useUiPtr_3 -- 466
	if not inside then -- 467
		return false -- 468
	end -- 468
	local uiScale = math.max( -- 470
		0.25, -- 470
		math.min(w / 1280, h / 720) -- 470
	) -- 470
	local uiW = w / uiScale -- 471
	local uiH = h / uiScale -- 472
	local rawX = useUiPtr and input.uiX or input.mx -- 473
	local rawY = useUiPtr and input.uiY or input.my -- 474
	local pointer = Vec2(rawX / uiScale, rawY / uiScale) -- 475
	local boxes = computeTalentSlipRects( -- 476
		uiW, -- 476
		uiH, -- 476
		#offers, -- 476
		input:isTouchMode(), -- 476
		self.stageVp.safeUi.top -- 476
	) -- 476
	local i = 0 -- 477
	do -- 477
		i = 0 -- 478
		while i < #boxes do -- 478
			if boxes[i + 1]:containsPoint(pointer) then -- 479
				self.talentDraft.selected = i -- 480
				self.hud.talentSelected = i -- 481
				return p:chooseTalent(i) -- 482
			end -- 482
			i = i + 1 -- 478
		end -- 478
	end -- 478
	return false -- 485
end -- 457
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 489
	self:syncRuntimeHooks() -- 490
	self:setVisible(true) -- 491
	if self.boundPlay ~= p then -- 492
		self:bindPlay(p, w, h) -- 493
	end -- 493
	local safeDt = math.min( -- 495
		0.05, -- 495
		math.max(0.001, dt) -- 495
	) -- 495
	if self.toastTimer > 0 then -- 496
		self.toastTimer = math.max(0, self.toastTimer - safeDt) -- 497
	end -- 497
	self.audio:setPaused(p.paused) -- 499
	self.audio:setCameraRef( -- 500
		self.cam.x, -- 500
		w / math.max(0.25, self.cam.ppu) -- 500
	) -- 500
	self.audio:update(safeDt) -- 501
	local ev -- 503
	local worldDt = 0 -- 504
	local uiDt = 0 -- 505
	if not p.paused then -- 507
		ev = self.adapter:sample(p) -- 509
		self.vfx:ingest(ev, p, self.cam) -- 510
		self.audio:ingestEvents(ev, p) -- 511
		local touch = input:getTouch() -- 512
		if touch ~= nil then -- 513
			if ev.playerHit then -- 514
				touch:vibrate(0.036) -- 515
			elseif ev.reloadSolved or ev.benchCrafted or ev.handJustTied or ev.cartJustDocked then -- 516
				touch:vibrate(0.024) -- 517
			elseif ev.coverDeflect then -- 518
				touch:vibrate(0.018) -- 519
			elseif ev.knockPulse then -- 520
				touch:vibrate(0.014) -- 521
			end -- 521
		end -- 521
	else -- 521
		ev = self.adapter:emptyFrame(p) -- 526
		self.narrative.wipeT = 0 -- 527
	end -- 527
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 530
	if not p.paused then -- 531
		local clampedScale = math.max( -- 532
			0, -- 532
			math.min(2, view.timeScale) -- 532
		) -- 532
		uiDt = safeDt -- 533
		worldDt = safeDt * clampedScale -- 534
	end -- 534
	local uiScale = self:resizeInterface(w, h) -- 537
	local uiW = w / uiScale -- 538
	local uiH = h / uiScale -- 539
	local ctx = { -- 541
		p = p, -- 542
		view = view, -- 543
		events = ev, -- 544
		input = input, -- 545
		cam = self.cam, -- 546
		audio = self.audio, -- 547
		assets = self.worldArt, -- 548
		backdropArt = self.backdropArt, -- 549
		worldArt = self.worldArt, -- 550
		uiArt = self.uiArt, -- 551
		texts = self.texts, -- 552
		worldDt = worldDt, -- 553
		uiDt = uiDt, -- 554
		w = w, -- 555
		h = h, -- 556
		uiW = uiW, -- 557
		uiH = uiH, -- 558
		uiScale = uiScale, -- 559
		safeUi = self.stageVp.safeUi, -- 560
		paused = p.paused -- 561
	} -- 561
	local i = 0 -- 565
	do -- 565
		i = 0 -- 566
		while i < #self.plugins do -- 566
			local pl = self.plugins[i + 1] -- 567
			if pl.update ~= nil then -- 568
				pl:update(ctx) -- 569
			end -- 569
			i = i + 1 -- 566
		end -- 566
	end -- 566
	if not p.paused then -- 573
		self.time = self.time + worldDt -- 574
		self.cam:update(worldDt, p, w, h) -- 575
		self.audio:setCameraRef( -- 576
			self.cam.x, -- 576
			w / math.max(0.25, self.cam.ppu) -- 576
		) -- 576
		self.soundscape:updatePlay(worldDt, p, view, self.audio) -- 577
		self.actors:update(worldDt, p) -- 578
		self.vfx:update( -- 579
			worldDt, -- 579
			themeOf(p.room.key).ambient -- 579
		) -- 579
		self.hud:update(safeDt, p) -- 580
		self.narrative:update(safeDt, p, ev, input.frameInteractPressed) -- 581
	else -- 581
		self.cam:update(0, p, w, h) -- 583
	end -- 583
	self:clearAll() -- 586
	local backdropHandled = false -- 589
	do -- 589
		i = 0 -- 590
		while i < #self.plugins do -- 590
			local pl = self.plugins[i + 1] -- 591
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 592
				backdropHandled = true -- 593
			end -- 593
			i = i + 1 -- 590
		end -- 590
	end -- 590
	if not backdropHandled then -- 596
		self.stage:drawBackdrop( -- 597
			self.bgDraw, -- 597
			self.bgGlow, -- 597
			self.backdropArt, -- 597
			p, -- 597
			self.cam, -- 597
			self.time -- 597
		) -- 597
	end -- 597
	local worldHandled = false -- 601
	do -- 601
		i = 0 -- 602
		while i < #self.plugins do -- 602
			local pl = self.plugins[i + 1] -- 603
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 604
				worldHandled = true -- 605
			end -- 605
			i = i + 1 -- 602
		end -- 602
	end -- 602
	if not worldHandled then -- 608
		self.stage:drawPlayableWorld( -- 609
			self.fgDraw, -- 609
			self.fgGlow, -- 609
			self.worldArt, -- 609
			p, -- 609
			self.cam, -- 609
			self.time, -- 609
			self.occlusion, -- 609
			worldDt -- 609
		) -- 609
	end -- 609
	local propsHandled = false -- 613
	do -- 613
		i = 0 -- 614
		while i < #self.plugins do -- 614
			local pl = self.plugins[i + 1] -- 615
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 616
				propsHandled = true -- 617
			end -- 617
			i = i + 1 -- 614
		end -- 614
	end -- 614
	if not propsHandled then -- 620
		self.props:drawAll( -- 621
			self.fgDraw, -- 621
			self.fgGlow, -- 621
			self.worldArt, -- 621
			p, -- 621
			self.cam, -- 621
			self.time, -- 621
			self.occlusion, -- 621
			worldDt -- 621
		) -- 621
	end -- 621
	local suppressAllActors = view.visualMode == "museum" -- 625
	local partnerFarInHand = view.backCarry.handInHand and (not p.partner.alive or math.abs(p.partner.x - p.player.x) > 56 or math.abs(p.partner.y - p.player.y) > 24) -- 626
	local suppressPartner = view.visualMode == "pixel" and not p.childMode and p.player.alive and (view.backCarry.active or view.backCarry.mounting or view.backCarry.atBench or view.craftBench.active or partnerFarInHand) -- 630
	if not suppressAllActors then -- 638
		self.actors:drawAll( -- 639
			self.fgDraw, -- 639
			self.fgGlow, -- 639
			self.worldArt, -- 639
			p, -- 639
			self.cam, -- 639
			suppressPartner -- 639
		) -- 639
	end -- 639
	do -- 639
		i = 0 -- 641
		while i < #self.plugins do -- 641
			local pl = self.plugins[i + 1] -- 642
			if pl.drawActorsOverlay ~= nil then -- 643
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 644
			end -- 644
			i = i + 1 -- 641
		end -- 641
	end -- 641
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 649
	if view.visualMode == "pixel" then -- 652
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
	if p.paused then -- 659
		local isMaleRoguelike = p.run.source == "official" and p.storyRoute == "soldier" and p:isEscortRoom() -- 660
		action = self.menus:updateAndDrawPause( -- 661
			safeDt, -- 662
			input, -- 663
			self.uiDraw, -- 664
			self.uiInkDraw, -- 665
			self.uiArt, -- 666
			self.uiGlow, -- 667
			self.texts, -- 668
			uiW, -- 669
			uiH, -- 670
			uiScale, -- 671
			view.assistHintsEnabled, -- 672
			function() -- 673
				self.contract:toggleAssistHints() -- 674
			end, -- 673
			self.stageVp.safeUi, -- 676
			isMaleRoguelike -- 677
		) -- 677
	else -- 677
		local cutsceneHandled = false -- 681
		do -- 681
			i = 0 -- 682
			while i < #self.plugins do -- 682
				local pl = self.plugins[i + 1] -- 683
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 684
					self.uiDraw, -- 685
					self.uiInkDraw, -- 685
					self.uiArt, -- 685
					self.uiGlow, -- 685
					ctx -- 685
				) then -- 685
					cutsceneHandled = true -- 686
				end -- 686
				i = i + 1 -- 682
			end -- 682
		end -- 682
		if not cutsceneHandled then -- 690
			local touchOverlayVisible = input:shouldShowTouchControls() and not self.stageVp.isPortrait -- 691
			self.hud:draw( -- 692
				self.uiDraw, -- 693
				self.uiInkDraw, -- 694
				self.uiArt, -- 695
				self.uiGlow, -- 696
				self.texts, -- 697
				p, -- 698
				self.cam, -- 699
				self.vfx, -- 700
				self.narrative.letterbox, -- 701
				uiScale, -- 702
				view.assistHintsEnabled, -- 703
				true, -- 704
				input.inputMode, -- 705
				input.gamepadLayout, -- 706
				self.stageVp.safeUi, -- 707
				input.retryHoldProgress, -- 708
				touchOverlayVisible -- 709
			) -- 709
			self.narrative:draw( -- 711
				self.uiDraw, -- 712
				self.uiInkDraw, -- 713
				self.uiGlow, -- 714
				self.uiArt, -- 715
				self.texts, -- 716
				p, -- 717
				uiW, -- 718
				uiH, -- 719
				view.assistHintsEnabled, -- 720
				input.inputMode, -- 721
				input.gamepadLayout, -- 722
				self.stageVp.safeUi -- 723
			) -- 723
		end -- 723
		local suppressReticle = cutsceneHandled or view.reloadSession.active or view.craftBench.active -- 727
		do -- 727
			i = 0 -- 728
			while i < #self.plugins do -- 728
				local pl = self.plugins[i + 1] -- 729
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 730
					self.uiDraw, -- 731
					self.uiInkDraw, -- 731
					self.uiArt, -- 731
					self.uiGlow, -- 731
					ctx -- 731
				) then -- 731
					suppressReticle = true -- 732
				end -- 732
				i = i + 1 -- 728
			end -- 728
		end -- 728
		if not suppressReticle then -- 735
			self.hud:drawReticleOverlay( -- 736
				self.uiInkDraw, -- 737
				self.uiArt, -- 738
				self.uiGlow, -- 739
				p, -- 740
				self.cam, -- 741
				self.vfx, -- 742
				self.narrative.letterbox, -- 743
				uiScale, -- 744
				input:isTouchMode() -- 745
			) -- 745
		end -- 745
		if view.isRehearsal then -- 750
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 751
			drawSilkVeil( -- 752
				self.uiDraw, -- 752
				self.uiArt, -- 752
				"rehearsal_tag_veil", -- 752
				uiW * 0.5, -- 752
				uiH - 22 - self.stageVp.safeUi.top, -- 752
				168, -- 752
				26, -- 752
				PALETTE.inkWarm, -- 752
				0.74, -- 752
				8 -- 752
			) -- 752
			self.texts:put( -- 753
				"xs", -- 753
				badgeText, -- 753
				uiW * 0.5, -- 753
				uiH - 22 - self.stageVp.safeUi.top, -- 753
				toColor(PALETTE.amberCore), -- 753
				0.5, -- 753
				0.5, -- 753
				"Center", -- 753
				1.2, -- 753
				0.92, -- 753
				0.08 -- 753
			) -- 753
		end -- 753
	end -- 753
	self:drawToast(uiW) -- 757
	self:finishFrame() -- 758
	return action -- 759
end -- 489
return ____exports -- 489
