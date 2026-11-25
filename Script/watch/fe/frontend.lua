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
local ____adapter = require("Script.watch.fe.adapter") -- 15
local PlayAdapter = ____adapter.PlayAdapter -- 15
local ____assets = require("Script.watch.fe.assets") -- 16
local AssetSlotHost = ____assets.AssetSlotHost -- 16
local ____audio = require("Script.watch.fe.audio") -- 17
local AudioDirector = ____audio.AudioDirector -- 17
local ____camera = require("Script.watch.fe.camera") -- 18
local CameraDirector = ____camera.CameraDirector -- 18
local ____contract = require("Script.watch.fe.contract") -- 19
local DualRouteContract = ____contract.DualRouteContract -- 19
local ____occlusion = require("Script.watch.fe.occlusion") -- 20
local DepthOcclusion = ____occlusion.DepthOcclusion -- 20
local ____stage = require("Script.watch.fe.renderer.stage") -- 22
local StageRenderer = ____stage.StageRenderer -- 22
local ____props = require("Script.watch.fe.renderer.props") -- 23
local PropsRenderer = ____props.PropsRenderer -- 23
local ____actors = require("Script.watch.fe.renderer.actors") -- 24
local ActorsRenderer = ____actors.ActorsRenderer -- 24
local ____vfx = require("Script.watch.fe.renderer.vfx") -- 25
local VfxSystem = ____vfx.VfxSystem -- 25
local ____textpool = require("Script.watch.fe.ui.textpool") -- 26
local TextPool = ____textpool.TextPool -- 26
local ____hud = require("Script.watch.fe.ui.hud") -- 27
local HudRenderer = ____hud.HudRenderer -- 27
local ____narrative = require("Script.watch.fe.ui.narrative") -- 28
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 28
local ____menus = require("Script.watch.fe.ui.menus") -- 29
local MenuRenderer = ____menus.MenuRenderer -- 29
local ____theme = require("Script.watch.fe.theme") -- 30
local PALETTE = ____theme.PALETTE -- 30
local drawSilkVeil = ____theme.drawSilkVeil -- 30
local themeOf = ____theme.themeOf -- 30
local toColor = ____theme.toColor -- 30
____exports.WatchFrontend = __TS__Class() -- 32
local WatchFrontend = ____exports.WatchFrontend -- 32
WatchFrontend.name = "WatchFrontend" -- 32
function WatchFrontend.prototype.____constructor(self, parent) -- 66
	self.occlusion = __TS__New(DepthOcclusion) -- 33
	self.cam = __TS__New(CameraDirector) -- 48
	self.adapter = __TS__New(PlayAdapter) -- 49
	self.contract = __TS__New(DualRouteContract) -- 50
	self.audio = __TS__New(AudioDirector) -- 51
	self.stage = __TS__New(StageRenderer) -- 52
	self.props = __TS__New(PropsRenderer) -- 53
	self.actors = __TS__New(ActorsRenderer) -- 54
	self.vfx = __TS__New(VfxSystem) -- 55
	self.hud = __TS__New(HudRenderer) -- 56
	self.narrative = __TS__New(NarrativeRenderer) -- 57
	self.menus = __TS__New(MenuRenderer) -- 58
	self.plugins = {} -- 60
	self.screen = "title" -- 62
	self.time = 0 -- 63
	self.layerRoot = Node() -- 67
	self.layerRoot.order = 5 -- 68
	self.layerRoot:addTo(parent) -- 69
	self.audio:attachHost(self.layerRoot) -- 71
	local additive = BlendFunc("SrcAlpha", "One") -- 73
	self.bgDraw = DrawNode() -- 75
	self.bgDraw.order = 10 -- 76
	self.bgDraw:addTo(self.layerRoot) -- 77
	self.bgGlow = DrawNode() -- 79
	self.bgGlow.order = 15 -- 80
	self.bgGlow.blendFunc = additive -- 81
	self.bgGlow:addTo(self.layerRoot) -- 82
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 84
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 85
	self.fgDraw = DrawNode() -- 87
	self.fgDraw.order = 30 -- 88
	self.fgDraw:addTo(self.layerRoot) -- 89
	self.fgGlow = DrawNode() -- 91
	self.fgGlow.order = 35 -- 92
	self.fgGlow.blendFunc = additive -- 93
	self.fgGlow:addTo(self.layerRoot) -- 94
	self.uiLayer = Node() -- 96
	self.uiLayer.order = 40 -- 97
	self.uiLayer:addTo(self.layerRoot) -- 98
	self.uiDraw = DrawNode() -- 100
	self.uiDraw.order = 0 -- 101
	self.uiDraw:addTo(self.uiLayer) -- 102
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 104
	self.uiInkDraw = DrawNode() -- 106
	self.uiInkDraw.order = 4 -- 107
	self.uiInkDraw:addTo(self.uiLayer) -- 108
	self.uiGlow = DrawNode() -- 110
	self.uiGlow.order = 6 -- 111
	self.uiGlow.blendFunc = additive -- 112
	self.uiGlow:addTo(self.uiLayer) -- 113
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 115
end -- 66
function WatchFrontend.prototype.registerPlugin(self, plugin) -- 119
	local i = 0 -- 120
	do -- 120
		i = 0 -- 121
		while i < #self.plugins do -- 121
			if self.plugins[i + 1].id == plugin.id then -- 121
				self.plugins[i + 1] = plugin -- 123
				if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 123
					plugin:onBindPlay( -- 125
						self.boundPlay, -- 125
						self.contract:peekSnapshot(self.boundPlay) -- 125
					) -- 125
				end -- 125
				return -- 127
			end -- 127
			i = i + 1 -- 121
		end -- 121
	end -- 121
	local ____self_plugins_0 = self.plugins -- 121
	____self_plugins_0[#____self_plugins_0 + 1] = plugin -- 130
	if self.boundPlay ~= nil and plugin.onBindPlay ~= nil then -- 130
		plugin:onBindPlay( -- 132
			self.boundPlay, -- 132
			self.contract:peekSnapshot(self.boundPlay) -- 132
		) -- 132
	end -- 132
end -- 119
function WatchFrontend.prototype.unregisterPlugin(self, id) -- 137
	local w = 0 -- 138
	local i = 0 -- 139
	do -- 139
		i = 0 -- 140
		while i < #self.plugins do -- 140
			if self.plugins[i + 1].id ~= id then -- 140
				self.plugins[w + 1] = self.plugins[i + 1] -- 142
				w = w + 1 -- 143
			end -- 143
			i = i + 1 -- 140
		end -- 140
	end -- 140
	__TS__ArraySetLength(self.plugins, w) -- 140
end -- 137
function WatchFrontend.prototype.getPlugins(self) -- 149
	return self.plugins -- 150
end -- 149
function WatchFrontend.prototype.syncRuntimeHooks(self) -- 158
	local g = _G -- 159
	local ____temp_1 -- 160
	if g.package ~= nil then -- 160
		____temp_1 = g.package.loaded -- 160
	else -- 160
		____temp_1 = nil -- 160
	end -- 160
	local loaded = ____temp_1 -- 160
	if loaded == nil then -- 160
		return -- 162
	end -- 162
	local rawFe = loaded["watch.fe"] -- 164
	if rawFe ~= nil and type(rawFe) == "table" then -- 164
		local watchFe = rawFe -- 166
		if watchFe.contract ~= self.contract then -- 166
			watchFe.contract = self.contract -- 168
			watchFe.audio = self.audio -- 169
			watchFe.registerPlugin = function(plugin) return self:registerPlugin(plugin) end -- 170
			watchFe.unregisterPlugin = function(id) return self:unregisterPlugin(id) end -- 171
		end -- 171
	end -- 171
end -- 158
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 176
	local scale = math.max( -- 177
		0.25, -- 177
		math.min(w / 1280, h / 720) -- 177
	) -- 177
	self.uiLayer.scaleX = scale -- 178
	self.uiLayer.scaleY = scale -- 179
	return scale -- 180
end -- 176
function WatchFrontend.prototype.setVisible(self, v) -- 184
	self.layerRoot.visible = v -- 185
	if not v then -- 185
		self.texts:hideAll() -- 187
	end -- 187
end -- 184
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 192
	self:syncRuntimeHooks() -- 193
	self.boundPlay = p -- 194
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 195
	self.cam:snap(p, w, h) -- 196
	self.adapter:reset(p) -- 197
	self.contract:resetForRoom(p) -- 198
	self.audio:stopRoomTransient() -- 199
	self.actors:reset(p) -- 200
	self.occlusion:reset() -- 201
	self.vfx:reset() -- 202
	self.hud:reset(p) -- 203
	self.narrative:onEnterRoom(p.room.key) -- 204
	if #self.plugins > 0 then -- 204
		local initView = self.contract:peekSnapshot(p) -- 207
		local i = 0 -- 208
		do -- 208
			i = 0 -- 209
			while i < #self.plugins do -- 209
				local pl = self.plugins[i + 1] -- 210
				if pl.onBindPlay ~= nil then -- 210
					pl:onBindPlay(p, initView) -- 212
				end -- 212
				i = i + 1 -- 209
			end -- 209
		end -- 209
	end -- 209
end -- 192
function WatchFrontend.prototype.clearAll(self) -- 218
	self.bgDraw:clear() -- 219
	self.bgGlow:clear() -- 220
	self.fgDraw:clear() -- 221
	self.fgGlow:clear() -- 222
	self.uiDraw:clear() -- 223
	self.uiInkDraw:clear() -- 224
	self.uiGlow:clear() -- 225
	self.backdropArt:beginFrame() -- 226
	self.worldArt:beginFrame() -- 227
	self.uiArt:beginFrame() -- 228
	self.texts:beginFrame() -- 229
end -- 218
function WatchFrontend.prototype.finishFrame(self) -- 232
	self.backdropArt:endFrame() -- 233
	self.worldArt:endFrame() -- 234
	self.uiArt:endFrame() -- 235
	self.texts:endFrame() -- 236
end -- 232
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 240
	self:syncRuntimeHooks() -- 241
	self:setVisible(true) -- 242
	self:clearAll() -- 243
	local uiScale = self:resizeInterface(w, h) -- 244
	local act = self.menus:updateAndDrawScreen( -- 245
		dt, -- 246
		self.screen, -- 247
		input, -- 248
		self.stage, -- 249
		self.bgDraw, -- 250
		self.bgGlow, -- 251
		self.backdropArt, -- 252
		self.uiArt, -- 253
		self.uiDraw, -- 254
		self.uiInkDraw, -- 255
		self.uiGlow, -- 256
		self.texts, -- 257
		w, -- 258
		h, -- 259
		uiScale -- 260
	) -- 260
	self:finishFrame() -- 262
	return act -- 263
end -- 240
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 267
	self:syncRuntimeHooks() -- 268
	self:setVisible(true) -- 269
	if self.boundPlay ~= p then -- 269
		self:bindPlay(p, w, h) -- 271
	end -- 271
	local safeDt = math.min( -- 273
		0.05, -- 273
		math.max(0.001, dt) -- 273
	) -- 273
	self.audio:setPaused(p.paused) -- 274
	local ev -- 276
	local worldDt = 0 -- 277
	local uiDt = 0 -- 278
	if not p.paused then -- 278
		ev = self.adapter:sample(p) -- 282
		self.vfx:ingest(ev, p, self.cam) -- 283
		self.audio:ingestEvents(ev, p) -- 284
	else -- 284
		ev = self.adapter:emptyFrame(p) -- 287
		self.narrative.wipeT = 0 -- 288
	end -- 288
	local view = self.contract:sample(p, p.paused and 0 or safeDt, input, ev) -- 291
	if not p.paused then -- 291
		local clampedScale = math.max( -- 293
			0, -- 293
			math.min(2, view.timeScale) -- 293
		) -- 293
		uiDt = safeDt -- 294
		worldDt = safeDt * clampedScale -- 295
	end -- 295
	local uiScale = self:resizeInterface(w, h) -- 298
	local uiW = w / uiScale -- 299
	local uiH = h / uiScale -- 300
	local ctx = { -- 302
		p = p, -- 303
		view = view, -- 304
		events = ev, -- 305
		input = input, -- 306
		cam = self.cam, -- 307
		audio = self.audio, -- 308
		assets = self.worldArt, -- 309
		backdropArt = self.backdropArt, -- 310
		worldArt = self.worldArt, -- 311
		uiArt = self.uiArt, -- 312
		texts = self.texts, -- 313
		worldDt = worldDt, -- 314
		uiDt = uiDt, -- 315
		w = w, -- 316
		h = h, -- 317
		uiW = uiW, -- 318
		uiH = uiH, -- 319
		uiScale = uiScale, -- 320
		paused = p.paused -- 321
	} -- 321
	local i = 0 -- 325
	do -- 325
		i = 0 -- 326
		while i < #self.plugins do -- 326
			local pl = self.plugins[i + 1] -- 327
			if pl.update ~= nil then -- 327
				pl:update(ctx) -- 329
			end -- 329
			i = i + 1 -- 326
		end -- 326
	end -- 326
	if not p.paused then -- 326
		self.time = self.time + worldDt -- 334
		self.cam:update(worldDt, p, w, h) -- 335
		self.actors:update(worldDt, p) -- 336
		self.vfx:update( -- 337
			worldDt, -- 337
			themeOf(p.room.key).ambient -- 337
		) -- 337
		self.hud:update(worldDt, p) -- 338
		self.narrative:update(worldDt, p) -- 339
	else -- 339
		self.cam:update(0, p, w, h) -- 341
	end -- 341
	self:clearAll() -- 344
	local backdropHandled = false -- 347
	do -- 347
		i = 0 -- 348
		while i < #self.plugins do -- 348
			local pl = self.plugins[i + 1] -- 349
			if pl.drawBackdrop ~= nil and pl:drawBackdrop(self.bgDraw, self.bgGlow, self.backdropArt, ctx) then -- 349
				backdropHandled = true -- 351
			end -- 351
			i = i + 1 -- 348
		end -- 348
	end -- 348
	if not backdropHandled then -- 348
		self.stage:drawBackdrop( -- 355
			self.bgDraw, -- 355
			self.bgGlow, -- 355
			self.backdropArt, -- 355
			p, -- 355
			self.cam, -- 355
			self.time -- 355
		) -- 355
	end -- 355
	local worldHandled = false -- 359
	do -- 359
		i = 0 -- 360
		while i < #self.plugins do -- 360
			local pl = self.plugins[i + 1] -- 361
			if pl.drawWorld ~= nil and pl:drawWorld(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 361
				worldHandled = true -- 363
			end -- 363
			i = i + 1 -- 360
		end -- 360
	end -- 360
	if not worldHandled then -- 360
		self.stage:drawPlayableWorld( -- 367
			self.fgDraw, -- 367
			self.fgGlow, -- 367
			self.worldArt, -- 367
			p, -- 367
			self.cam, -- 367
			self.time, -- 367
			self.occlusion, -- 367
			worldDt -- 367
		) -- 367
	end -- 367
	local propsHandled = false -- 371
	do -- 371
		i = 0 -- 372
		while i < #self.plugins do -- 372
			local pl = self.plugins[i + 1] -- 373
			if pl.drawPropsOverlay ~= nil and pl:drawPropsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) then -- 373
				propsHandled = true -- 375
			end -- 375
			i = i + 1 -- 372
		end -- 372
	end -- 372
	if not propsHandled then -- 372
		self.props:drawAll( -- 379
			self.fgDraw, -- 379
			self.fgGlow, -- 379
			self.worldArt, -- 379
			p, -- 379
			self.cam, -- 379
			self.time, -- 379
			self.occlusion, -- 379
			worldDt -- 379
		) -- 379
	end -- 379
	self.actors:drawAll( -- 383
		self.fgDraw, -- 383
		self.fgGlow, -- 383
		self.worldArt, -- 383
		p, -- 383
		self.cam -- 383
	) -- 383
	do -- 383
		i = 0 -- 384
		while i < #self.plugins do -- 384
			local pl = self.plugins[i + 1] -- 385
			if pl.drawActorsOverlay ~= nil then -- 385
				pl:drawActorsOverlay(self.fgDraw, self.fgGlow, self.worldArt, ctx) -- 387
			end -- 387
			i = i + 1 -- 384
		end -- 384
	end -- 384
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 392
	self.stage:drawForegroundFraming( -- 395
		self.fgDraw, -- 395
		w, -- 395
		h, -- 395
		p, -- 395
		self.cam -- 395
	) -- 395
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 396
	local action = {type = "none"} -- 399
	if p.paused then -- 399
		action = self.menus:updateAndDrawPause( -- 401
			safeDt, -- 402
			input, -- 403
			self.uiDraw, -- 404
			self.uiInkDraw, -- 405
			self.uiArt, -- 406
			self.uiGlow, -- 407
			self.texts, -- 408
			uiW, -- 409
			uiH, -- 410
			uiScale, -- 411
			view.assistHintsEnabled, -- 412
			function() -- 413
				self.contract:toggleAssistHints() -- 414
			end -- 413
		) -- 413
	else -- 413
		self.hud:draw( -- 419
			self.uiDraw, -- 420
			self.uiInkDraw, -- 421
			self.uiArt, -- 422
			self.uiGlow, -- 423
			self.texts, -- 424
			p, -- 425
			self.cam, -- 426
			self.vfx, -- 427
			self.narrative.letterbox, -- 428
			uiScale, -- 429
			view.assistHintsEnabled, -- 430
			true -- 431
		) -- 431
		local cutsceneHandled = false -- 434
		do -- 434
			i = 0 -- 435
			while i < #self.plugins do -- 435
				local pl = self.plugins[i + 1] -- 436
				if pl.drawCutsceneOverlay ~= nil and pl:drawCutsceneOverlay( -- 436
					self.uiDraw, -- 438
					self.uiInkDraw, -- 438
					self.uiArt, -- 438
					self.uiGlow, -- 438
					ctx -- 438
				) then -- 438
					cutsceneHandled = true -- 439
				end -- 439
				i = i + 1 -- 435
			end -- 435
		end -- 435
		if not cutsceneHandled then -- 435
			self.narrative:draw( -- 443
				self.uiDraw, -- 444
				self.uiInkDraw, -- 445
				self.uiGlow, -- 446
				self.uiArt, -- 447
				self.texts, -- 448
				p, -- 449
				uiW, -- 450
				uiH, -- 451
				view.assistHintsEnabled -- 452
			) -- 452
		end -- 452
		local suppressReticle = view.reloadSession.active or view.craftBench.active -- 456
		do -- 456
			i = 0 -- 457
			while i < #self.plugins do -- 457
				local pl = self.plugins[i + 1] -- 458
				if pl.drawFullSpeedUi ~= nil and pl:drawFullSpeedUi( -- 458
					self.uiDraw, -- 460
					self.uiInkDraw, -- 460
					self.uiArt, -- 460
					self.uiGlow, -- 460
					ctx -- 460
				) then -- 460
					suppressReticle = true -- 461
				end -- 461
				i = i + 1 -- 457
			end -- 457
		end -- 457
		if not suppressReticle then -- 457
			self.hud:drawReticleOverlay( -- 465
				self.uiInkDraw, -- 466
				self.uiArt, -- 467
				self.uiGlow, -- 468
				p, -- 469
				self.cam, -- 470
				self.vfx, -- 471
				self.narrative.letterbox, -- 472
				uiScale -- 473
			) -- 473
		end -- 473
		if view.isRehearsal then -- 473
			local badgeText = view.rehearsalTag ~= "" and "排演 · " .. view.rehearsalTag or "排演模式" -- 479
			drawSilkVeil( -- 480
				self.uiDraw, -- 480
				self.uiArt, -- 480
				"rehearsal_tag_veil", -- 480
				uiW * 0.5, -- 480
				uiH - 22, -- 480
				168, -- 480
				26, -- 480
				PALETTE.inkWarm, -- 480
				0.74, -- 480
				8 -- 480
			) -- 480
			self.texts:put( -- 481
				"xs", -- 481
				badgeText, -- 481
				uiW * 0.5, -- 481
				uiH - 22, -- 481
				toColor(PALETTE.amberCore), -- 481
				0.5, -- 481
				0.5, -- 481
				"Center", -- 481
				1.2, -- 481
				0.92, -- 481
				0.08 -- 481
			) -- 481
		end -- 481
	end -- 481
	self:finishFrame() -- 485
	return action -- 486
end -- 267
return ____exports -- 267