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
local ____stage = require("Script.watch.fe.renderer.stage") -- 17
local StageRenderer = ____stage.StageRenderer -- 17
local ____props = require("Script.watch.fe.renderer.props") -- 18
local PropsRenderer = ____props.PropsRenderer -- 18
local ____actors = require("Script.watch.fe.renderer.actors") -- 19
local ActorsRenderer = ____actors.ActorsRenderer -- 19
local ____vfx = require("Script.watch.fe.renderer.vfx") -- 20
local VfxSystem = ____vfx.VfxSystem -- 20
local ____textpool = require("Script.watch.fe.ui.textpool") -- 21
local TextPool = ____textpool.TextPool -- 21
local ____hud = require("Script.watch.fe.ui.hud") -- 22
local HudRenderer = ____hud.HudRenderer -- 22
local ____narrative = require("Script.watch.fe.ui.narrative") -- 23
local NarrativeRenderer = ____narrative.NarrativeRenderer -- 23
local ____menus = require("Script.watch.fe.ui.menus") -- 24
local MenuRenderer = ____menus.MenuRenderer -- 24
local ____theme = require("Script.watch.fe.theme") -- 25
local themeOf = ____theme.themeOf -- 25
____exports.WatchFrontend = __TS__Class() -- 27
local WatchFrontend = ____exports.WatchFrontend -- 27
WatchFrontend.name = "WatchFrontend" -- 27
function WatchFrontend.prototype.____constructor(self, parent) -- 56
	self.cam = __TS__New(CameraDirector) -- 42
	self.adapter = __TS__New(PlayAdapter) -- 43
	self.stage = __TS__New(StageRenderer) -- 44
	self.props = __TS__New(PropsRenderer) -- 45
	self.actors = __TS__New(ActorsRenderer) -- 46
	self.vfx = __TS__New(VfxSystem) -- 47
	self.hud = __TS__New(HudRenderer) -- 48
	self.narrative = __TS__New(NarrativeRenderer) -- 49
	self.menus = __TS__New(MenuRenderer) -- 50
	self.screen = "title" -- 52
	self.time = 0 -- 53
	self.layerRoot = Node() -- 57
	self.layerRoot.order = 5 -- 58
	self.layerRoot:addTo(parent) -- 59
	local additive = BlendFunc("SrcAlpha", "One") -- 61
	self.bgDraw = DrawNode() -- 63
	self.bgDraw.order = 10 -- 64
	self.bgDraw:addTo(self.layerRoot) -- 65
	self.bgGlow = DrawNode() -- 67
	self.bgGlow.order = 15 -- 68
	self.bgGlow.blendFunc = additive -- 69
	self.bgGlow:addTo(self.layerRoot) -- 70
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 72
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 73
	self.fgDraw = DrawNode() -- 75
	self.fgDraw.order = 30 -- 76
	self.fgDraw:addTo(self.layerRoot) -- 77
	self.fgGlow = DrawNode() -- 79
	self.fgGlow.order = 35 -- 80
	self.fgGlow.blendFunc = additive -- 81
	self.fgGlow:addTo(self.layerRoot) -- 82
	self.uiLayer = Node() -- 84
	self.uiLayer.order = 40 -- 85
	self.uiLayer:addTo(self.layerRoot) -- 86
	self.uiDraw = DrawNode() -- 88
	self.uiDraw.order = 0 -- 89
	self.uiDraw:addTo(self.uiLayer) -- 90
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 92
	self.uiInkDraw = DrawNode() -- 94
	self.uiInkDraw.order = 4 -- 95
	self.uiInkDraw:addTo(self.uiLayer) -- 96
	self.uiGlow = DrawNode() -- 98
	self.uiGlow.order = 6 -- 99
	self.uiGlow.blendFunc = additive -- 100
	self.uiGlow:addTo(self.uiLayer) -- 101
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 103
end -- 56
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 106
	local scale = math.max( -- 107
		0.25, -- 107
		math.min(w / 1280, h / 720) -- 107
	) -- 107
	self.uiLayer.scaleX = scale -- 108
	self.uiLayer.scaleY = scale -- 109
	return scale -- 110
end -- 106
function WatchFrontend.prototype.setVisible(self, v) -- 114
	self.layerRoot.visible = v -- 115
	if not v then -- 115
		self.texts:hideAll() -- 117
	end -- 117
end -- 114
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 122
	self.boundPlay = p -- 123
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 124
	self.cam:snap(p, w, h) -- 125
	self.adapter:reset(p) -- 126
	self.actors:reset(p) -- 127
	self.vfx:reset() -- 128
	self.hud:reset(p) -- 129
	self.narrative:onEnterRoom(p.room.key) -- 130
end -- 122
function WatchFrontend.prototype.clearAll(self) -- 133
	self.bgDraw:clear() -- 134
	self.bgGlow:clear() -- 135
	self.fgDraw:clear() -- 136
	self.fgGlow:clear() -- 137
	self.uiDraw:clear() -- 138
	self.uiInkDraw:clear() -- 139
	self.uiGlow:clear() -- 140
	self.backdropArt:beginFrame() -- 141
	self.worldArt:beginFrame() -- 142
	self.uiArt:beginFrame() -- 143
	self.texts:beginFrame() -- 144
end -- 133
function WatchFrontend.prototype.finishFrame(self) -- 147
	self.backdropArt:endFrame() -- 148
	self.worldArt:endFrame() -- 149
	self.uiArt:endFrame() -- 150
	self.texts:endFrame() -- 151
end -- 147
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 155
	self:setVisible(true) -- 156
	self:clearAll() -- 157
	local uiScale = self:resizeInterface(w, h) -- 158
	local act = self.menus:updateAndDrawScreen( -- 159
		dt, -- 160
		self.screen, -- 161
		input, -- 162
		self.stage, -- 163
		self.bgDraw, -- 164
		self.bgGlow, -- 165
		self.backdropArt, -- 166
		self.uiArt, -- 167
		self.uiDraw, -- 168
		self.uiInkDraw, -- 169
		self.uiGlow, -- 170
		self.texts, -- 171
		w, -- 172
		h, -- 173
		uiScale -- 174
	) -- 174
	self:finishFrame() -- 176
	return act -- 177
end -- 155
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 181
	self:setVisible(true) -- 182
	if self.boundPlay ~= p then -- 182
		self:bindPlay(p, w, h) -- 184
	end -- 184
	local safeDt = math.min( -- 186
		0.05, -- 186
		math.max(0.001, dt) -- 186
	) -- 186
	local ev = self.adapter:sample(p) -- 189
	self.vfx:ingest(ev, p, self.cam) -- 190
	if not p.paused then -- 190
		self.time = self.time + safeDt -- 193
		self.cam:update(safeDt, p, w, h) -- 194
		self.actors:update(safeDt, p) -- 195
		self.vfx:update( -- 196
			safeDt, -- 196
			themeOf(p.room.key).ambient -- 196
		) -- 196
		self.hud:update(safeDt, p) -- 197
		self.narrative:update(safeDt, p) -- 198
	else -- 198
		self.narrative.wipeT = 0 -- 201
		self.cam:update(0, p, w, h) -- 202
	end -- 202
	self:clearAll() -- 205
	self.stage:drawBackdrop( -- 208
		self.bgDraw, -- 208
		self.bgGlow, -- 208
		self.backdropArt, -- 208
		p, -- 208
		self.cam, -- 208
		self.time -- 208
	) -- 208
	self.stage:drawPlayableWorld( -- 211
		self.fgDraw, -- 211
		self.fgGlow, -- 211
		self.worldArt, -- 211
		p, -- 211
		self.cam, -- 211
		self.time -- 211
	) -- 211
	self.props:drawAll( -- 214
		self.fgDraw, -- 214
		self.fgGlow, -- 214
		self.worldArt, -- 214
		p, -- 214
		self.cam, -- 214
		self.time -- 214
	) -- 214
	self.actors:drawAll( -- 217
		self.fgDraw, -- 217
		self.fgGlow, -- 217
		self.worldArt, -- 217
		p, -- 217
		self.cam -- 217
	) -- 217
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 220
	self.stage:drawForegroundFraming( -- 223
		self.fgDraw, -- 223
		w, -- 223
		h, -- 223
		p, -- 223
		self.cam -- 223
	) -- 223
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 224
	local uiScale = self:resizeInterface(w, h) -- 227
	local action = {type = "none"} -- 228
	if p.paused then -- 228
		action = self.menus:updateAndDrawPause( -- 230
			safeDt, -- 231
			input, -- 232
			self.uiDraw, -- 233
			self.uiInkDraw, -- 234
			self.uiArt, -- 235
			self.uiGlow, -- 236
			self.texts, -- 237
			w / uiScale, -- 238
			h / uiScale, -- 239
			uiScale -- 240
		) -- 240
	else -- 240
		self.hud:draw( -- 243
			self.uiDraw, -- 243
			self.uiInkDraw, -- 243
			self.uiArt, -- 243
			self.uiGlow, -- 243
			self.texts, -- 243
			p, -- 243
			self.cam, -- 243
			self.vfx, -- 243
			self.narrative.letterbox, -- 243
			uiScale -- 243
		) -- 243
		self.narrative:draw( -- 244
			self.uiDraw, -- 244
			self.uiInkDraw, -- 244
			self.uiGlow, -- 244
			self.uiArt, -- 244
			self.texts, -- 244
			p, -- 244
			w / uiScale, -- 244
			h / uiScale -- 244
		) -- 244
	end -- 244
	self:finishFrame() -- 247
	return action -- 248
end -- 181
return ____exports -- 181