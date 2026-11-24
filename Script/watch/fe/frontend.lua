-- [ts]: frontend.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__New = ____lualib.__TS__New -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 11
local BlendFunc = ____Dora.BlendFunc -- 11
local DrawNode = ____Dora.DrawNode -- 11
local Node = ____Dora.Node -- 11
local ____adapter = require("Script.watch.fe.adapter") -- 14
local PlayAdapter = ____adapter.PlayAdapter -- 14
local ____assets = require("Script.watch.fe.assets") -- 15
local AssetSlotHost = ____assets.AssetSlotHost -- 15
local ____camera = require("Script.watch.fe.camera") -- 16
local CameraDirector = ____camera.CameraDirector -- 16
local ____occlusion = require("Script.watch.fe.occlusion") -- 17
local DepthOcclusion = ____occlusion.DepthOcclusion -- 17
local ____stage = require("Script.watch.fe.renderer.stage") -- 18
local StageRenderer = ____stage.StageRenderer -- 18
local ____props = require("Script.watch.fe.renderer.props") -- 19
local PropsRenderer = ____props.PropsRenderer -- 19
local ____actors = require("Script.watch.fe.renderer.actors") -- 20
local ActorsRenderer = ____actors.ActorsRenderer -- 20
local ____vfx = require("Script.watch.fe.renderer.vfx") -- 21
local VfxSystem = ____vfx.VfxSystem -- 21
local ____textpool = require("Script.watch.fe.ui.textpool") -- 22
local TextPool = ____textpool.TextPool -- 22
local ____hud = require("Script.watch.fe.ui.hud") -- 23
local HudRenderer = ____hud.HudRenderer -- 23
local ____narrative = require("Script.watch.fe.ui.narrative") -- 24
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 24
local ____menus = require("Script.watch.fe.ui.menus") -- 25
local MenuRenderer = ____menus.MenuRenderer -- 25
local ____theme = require("Script.watch.fe.theme") -- 26
local themeOf = ____theme.themeOf -- 26
____exports.WatchFrontend = __TS__Class() -- 28
local WatchFrontend = ____exports.WatchFrontend -- 28
WatchFrontend.name = "WatchFrontend" -- 28
function WatchFrontend.prototype.____constructor(self, parent) -- 58
	self.occlusion = __TS__New(DepthOcclusion) -- 29
	self.cam = __TS__New(CameraDirector) -- 44
	self.adapter = __TS__New(PlayAdapter) -- 45
	self.stage = __TS__New(StageRenderer) -- 46
	self.props = __TS__New(PropsRenderer) -- 47
	self.actors = __TS__New(ActorsRenderer) -- 48
	self.vfx = __TS__New(VfxSystem) -- 49
	self.hud = __TS__New(HudRenderer) -- 50
	self.narrative = __TS__New(NarrativeRenderer) -- 51
	self.menus = __TS__New(MenuRenderer) -- 52
	self.screen = "title" -- 54
	self.time = 0 -- 55
	self.layerRoot = Node() -- 59
	self.layerRoot.order = 5 -- 60
	self.layerRoot:addTo(parent) -- 61
	local additive = BlendFunc("SrcAlpha", "One") -- 63
	self.bgDraw = DrawNode() -- 65
	self.bgDraw.order = 10 -- 66
	self.bgDraw:addTo(self.layerRoot) -- 67
	self.bgGlow = DrawNode() -- 69
	self.bgGlow.order = 15 -- 70
	self.bgGlow.blendFunc = additive -- 71
	self.bgGlow:addTo(self.layerRoot) -- 72
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 74
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 75
	self.fgDraw = DrawNode() -- 77
	self.fgDraw.order = 30 -- 78
	self.fgDraw:addTo(self.layerRoot) -- 79
	self.fgGlow = DrawNode() -- 81
	self.fgGlow.order = 35 -- 82
	self.fgGlow.blendFunc = additive -- 83
	self.fgGlow:addTo(self.layerRoot) -- 84
	self.uiLayer = Node() -- 86
	self.uiLayer.order = 40 -- 87
	self.uiLayer:addTo(self.layerRoot) -- 88
	self.uiDraw = DrawNode() -- 90
	self.uiDraw.order = 0 -- 91
	self.uiDraw:addTo(self.uiLayer) -- 92
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 94
	self.uiInkDraw = DrawNode() -- 96
	self.uiInkDraw.order = 4 -- 97
	self.uiInkDraw:addTo(self.uiLayer) -- 98
	self.uiGlow = DrawNode() -- 100
	self.uiGlow.order = 6 -- 101
	self.uiGlow.blendFunc = additive -- 102
	self.uiGlow:addTo(self.uiLayer) -- 103
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 105
end -- 58
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 108
	local scale = math.max( -- 109
		0.25, -- 109
		math.min(w / 1280, h / 720) -- 109
	) -- 109
	self.uiLayer.scaleX = scale -- 110
	self.uiLayer.scaleY = scale -- 111
	return scale -- 112
end -- 108
function WatchFrontend.prototype.setVisible(self, v) -- 116
	self.layerRoot.visible = v -- 117
	if not v then -- 117
		self.texts:hideAll() -- 119
	end -- 119
end -- 116
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 124
	self.boundPlay = p -- 125
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 126
	self.cam:snap(p, w, h) -- 127
	self.adapter:reset(p) -- 128
	self.actors:reset(p) -- 129
	self.occlusion:reset() -- 130
	self.vfx:reset() -- 131
	self.hud:reset(p) -- 132
	self.narrative:onEnterRoom(p.room.key) -- 133
end -- 124
function WatchFrontend.prototype.clearAll(self) -- 136
	self.bgDraw:clear() -- 137
	self.bgGlow:clear() -- 138
	self.fgDraw:clear() -- 139
	self.fgGlow:clear() -- 140
	self.uiDraw:clear() -- 141
	self.uiInkDraw:clear() -- 142
	self.uiGlow:clear() -- 143
	self.backdropArt:beginFrame() -- 144
	self.worldArt:beginFrame() -- 145
	self.uiArt:beginFrame() -- 146
	self.texts:beginFrame() -- 147
end -- 136
function WatchFrontend.prototype.finishFrame(self) -- 150
	self.backdropArt:endFrame() -- 151
	self.worldArt:endFrame() -- 152
	self.uiArt:endFrame() -- 153
	self.texts:endFrame() -- 154
end -- 150
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 158
	self:setVisible(true) -- 159
	self:clearAll() -- 160
	local uiScale = self:resizeInterface(w, h) -- 161
	local act = self.menus:updateAndDrawScreen( -- 162
		dt, -- 163
		self.screen, -- 164
		input, -- 165
		self.stage, -- 166
		self.bgDraw, -- 167
		self.bgGlow, -- 168
		self.backdropArt, -- 169
		self.uiArt, -- 170
		self.uiDraw, -- 171
		self.uiInkDraw, -- 172
		self.uiGlow, -- 173
		self.texts, -- 174
		w, -- 175
		h, -- 176
		uiScale -- 177
	) -- 177
	self:finishFrame() -- 179
	return act -- 180
end -- 158
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 184
	self:setVisible(true) -- 185
	if self.boundPlay ~= p then -- 185
		self:bindPlay(p, w, h) -- 187
	end -- 187
	local safeDt = math.min( -- 189
		0.05, -- 189
		math.max(0.001, dt) -- 189
	) -- 189
	local ev = self.adapter:sample(p) -- 192
	self.vfx:ingest(ev, p, self.cam) -- 193
	if not p.paused then -- 193
		self.time = self.time + safeDt -- 196
		self.cam:update(safeDt, p, w, h) -- 197
		self.actors:update(safeDt, p) -- 198
		self.vfx:update( -- 199
			safeDt, -- 199
			themeOf(p.room.key).ambient -- 199
		) -- 199
		self.hud:update(safeDt, p) -- 200
		self.narrative:update(safeDt, p) -- 201
	else -- 201
		self.narrative.wipeT = 0 -- 204
		self.cam:update(0, p, w, h) -- 205
	end -- 205
	self:clearAll() -- 208
	self.stage:drawBackdrop( -- 211
		self.bgDraw, -- 211
		self.bgGlow, -- 211
		self.backdropArt, -- 211
		p, -- 211
		self.cam, -- 211
		self.time -- 211
	) -- 211
	local fadeDt = p.paused and 0 or safeDt -- 214
	self.stage:drawPlayableWorld( -- 215
		self.fgDraw, -- 215
		self.fgGlow, -- 215
		self.worldArt, -- 215
		p, -- 215
		self.cam, -- 215
		self.time, -- 215
		self.occlusion, -- 215
		fadeDt -- 215
	) -- 215
	self.props:drawAll( -- 218
		self.fgDraw, -- 218
		self.fgGlow, -- 218
		self.worldArt, -- 218
		p, -- 218
		self.cam, -- 218
		self.time, -- 218
		self.occlusion, -- 218
		fadeDt -- 218
	) -- 218
	self.actors:drawAll( -- 221
		self.fgDraw, -- 221
		self.fgGlow, -- 221
		self.worldArt, -- 221
		p, -- 221
		self.cam -- 221
	) -- 221
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 224
	self.stage:drawForegroundFraming( -- 227
		self.fgDraw, -- 227
		w, -- 227
		h, -- 227
		p, -- 227
		self.cam -- 227
	) -- 227
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 228
	local uiScale = self:resizeInterface(w, h) -- 231
	local action = {type = "none"} -- 232
	if p.paused then -- 232
		action = self.menus:updateAndDrawPause( -- 234
			safeDt, -- 235
			input, -- 236
			self.uiDraw, -- 237
			self.uiInkDraw, -- 238
			self.uiArt, -- 239
			self.uiGlow, -- 240
			self.texts, -- 241
			w / uiScale, -- 242
			h / uiScale, -- 243
			uiScale -- 244
		) -- 244
	else -- 244
		self.hud:draw( -- 247
			self.uiDraw, -- 247
			self.uiInkDraw, -- 247
			self.uiArt, -- 247
			self.uiGlow, -- 247
			self.texts, -- 247
			p, -- 247
			self.cam, -- 247
			self.vfx, -- 247
			self.narrative.letterbox, -- 247
			uiScale -- 247
		) -- 247
		self.narrative:draw( -- 248
			self.uiDraw, -- 248
			self.uiInkDraw, -- 248
			self.uiGlow, -- 248
			self.uiArt, -- 248
			self.texts, -- 248
			p, -- 248
			w / uiScale, -- 248
			h / uiScale -- 248
		) -- 248
	end -- 248
	self:finishFrame() -- 251
	return action -- 252
end -- 184
return ____exports -- 184