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
function WatchFrontend.prototype.____constructor(self, parent) -- 55
	self.cam = __TS__New(CameraDirector) -- 41
	self.adapter = __TS__New(PlayAdapter) -- 42
	self.stage = __TS__New(StageRenderer) -- 43
	self.props = __TS__New(PropsRenderer) -- 44
	self.actors = __TS__New(ActorsRenderer) -- 45
	self.vfx = __TS__New(VfxSystem) -- 46
	self.hud = __TS__New(HudRenderer) -- 47
	self.narrative = __TS__New(NarrativeRenderer) -- 48
	self.menus = __TS__New(MenuRenderer) -- 49
	self.screen = "title" -- 51
	self.time = 0 -- 52
	self.layerRoot = Node() -- 56
	self.layerRoot.order = 5 -- 57
	self.layerRoot:addTo(parent) -- 58
	local additive = BlendFunc("SrcAlpha", "One") -- 60
	self.bgDraw = DrawNode() -- 62
	self.bgDraw.order = 10 -- 63
	self.bgDraw:addTo(self.layerRoot) -- 64
	self.bgGlow = DrawNode() -- 66
	self.bgGlow.order = 15 -- 67
	self.bgGlow.blendFunc = additive -- 68
	self.bgGlow:addTo(self.layerRoot) -- 69
	self.backdropArt = __TS__New(AssetSlotHost, self.layerRoot, 12) -- 71
	self.worldArt = __TS__New(AssetSlotHost, self.layerRoot, 32) -- 72
	self.fgDraw = DrawNode() -- 74
	self.fgDraw.order = 30 -- 75
	self.fgDraw:addTo(self.layerRoot) -- 76
	self.fgGlow = DrawNode() -- 78
	self.fgGlow.order = 35 -- 79
	self.fgGlow.blendFunc = additive -- 80
	self.fgGlow:addTo(self.layerRoot) -- 81
	self.uiLayer = Node() -- 83
	self.uiLayer.order = 40 -- 84
	self.uiLayer:addTo(self.layerRoot) -- 85
	self.uiDraw = DrawNode() -- 87
	self.uiDraw:addTo(self.uiLayer) -- 88
	self.uiArt = __TS__New(AssetSlotHost, self.uiLayer, 2) -- 90
	self.uiGlow = DrawNode() -- 92
	self.uiGlow.order = 5 -- 93
	self.uiGlow.blendFunc = additive -- 94
	self.uiGlow:addTo(self.uiLayer) -- 95
	self.texts = __TS__New(TextPool, self.uiLayer, 10) -- 97
end -- 55
function WatchFrontend.prototype.resizeInterface(self, w, h) -- 100
	local scale = math.max( -- 101
		0.25, -- 101
		math.min(w / 1280, h / 720) -- 101
	) -- 101
	self.uiLayer.scaleX = scale -- 102
	self.uiLayer.scaleY = scale -- 103
	return scale -- 104
end -- 100
function WatchFrontend.prototype.setVisible(self, v) -- 108
	self.layerRoot.visible = v -- 109
	if not v then -- 109
		self.texts:hideAll() -- 111
	end -- 111
end -- 108
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 116
	self.boundPlay = p -- 117
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 118
	self.cam:snap(p, w, h) -- 119
	self.adapter:reset(p) -- 120
	self.actors:reset(p) -- 121
	self.vfx:reset() -- 122
	self.hud:reset(p) -- 123
	self.narrative:onEnterRoom(p.room.key) -- 124
end -- 116
function WatchFrontend.prototype.clearAll(self) -- 127
	self.bgDraw:clear() -- 128
	self.bgGlow:clear() -- 129
	self.fgDraw:clear() -- 130
	self.fgGlow:clear() -- 131
	self.uiDraw:clear() -- 132
	self.uiGlow:clear() -- 133
	self.backdropArt:beginFrame() -- 134
	self.worldArt:beginFrame() -- 135
	self.uiArt:beginFrame() -- 136
	self.texts:beginFrame() -- 137
end -- 127
function WatchFrontend.prototype.finishFrame(self) -- 140
	self.backdropArt:endFrame() -- 141
	self.worldArt:endFrame() -- 142
	self.uiArt:endFrame() -- 143
	self.texts:endFrame() -- 144
end -- 140
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 148
	self:setVisible(true) -- 149
	self:clearAll() -- 150
	local uiScale = self:resizeInterface(w, h) -- 151
	local act = self.menus:updateAndDrawScreen( -- 152
		dt, -- 153
		self.screen, -- 154
		input, -- 155
		self.stage, -- 156
		self.bgDraw, -- 157
		self.bgGlow, -- 158
		self.backdropArt, -- 159
		self.uiArt, -- 160
		self.uiDraw, -- 161
		self.uiGlow, -- 162
		self.texts, -- 163
		w, -- 164
		h, -- 165
		uiScale -- 166
	) -- 166
	self:finishFrame() -- 168
	return act -- 169
end -- 148
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 173
	self:setVisible(true) -- 174
	if self.boundPlay ~= p then -- 174
		self:bindPlay(p, w, h) -- 176
	end -- 176
	local safeDt = math.min( -- 178
		0.05, -- 178
		math.max(0.001, dt) -- 178
	) -- 178
	local ev = self.adapter:sample(p) -- 181
	self.vfx:ingest(ev, p, self.cam) -- 182
	if not p.paused then -- 182
		self.time = self.time + safeDt -- 185
		self.cam:update(safeDt, p, w, h) -- 186
		self.actors:update(safeDt, p) -- 187
		self.vfx:update( -- 188
			safeDt, -- 188
			themeOf(p.room.key).ambient -- 188
		) -- 188
		self.hud:update(safeDt, p) -- 189
		self.narrative:update(safeDt, p) -- 190
	else -- 190
		self.narrative.wipeT = 0 -- 193
		self.cam:update(0, p, w, h) -- 194
	end -- 194
	self:clearAll() -- 197
	self.stage:drawBackdrop( -- 200
		self.bgDraw, -- 200
		self.bgGlow, -- 200
		self.backdropArt, -- 200
		p, -- 200
		self.cam, -- 200
		self.time -- 200
	) -- 200
	self.stage:drawPlayableWorld( -- 203
		self.fgDraw, -- 203
		self.fgGlow, -- 203
		self.worldArt, -- 203
		p, -- 203
		self.cam, -- 203
		self.time -- 203
	) -- 203
	self.props:drawAll( -- 206
		self.fgDraw, -- 206
		self.fgGlow, -- 206
		self.worldArt, -- 206
		p, -- 206
		self.cam, -- 206
		self.time -- 206
	) -- 206
	self.actors:drawAll( -- 209
		self.fgDraw, -- 209
		self.fgGlow, -- 209
		self.worldArt, -- 209
		p, -- 209
		self.cam -- 209
	) -- 209
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 212
	self.stage:drawForegroundFraming( -- 215
		self.fgDraw, -- 215
		w, -- 215
		h, -- 215
		p, -- 215
		self.cam -- 215
	) -- 215
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 216
	local uiScale = self:resizeInterface(w, h) -- 219
	self.hud:draw( -- 220
		self.uiDraw, -- 220
		self.uiGlow, -- 220
		self.texts, -- 220
		p, -- 220
		self.cam, -- 220
		self.vfx, -- 220
		self.narrative.letterbox, -- 220
		uiScale -- 220
	) -- 220
	self.narrative:draw( -- 221
		self.uiDraw, -- 221
		self.uiGlow, -- 221
		self.uiArt, -- 221
		self.texts, -- 221
		p, -- 221
		w / uiScale, -- 221
		h / uiScale -- 221
	) -- 221
	local action = {type = "none"} -- 224
	if p.paused then -- 224
		action = self.menus:updateAndDrawPause( -- 226
			safeDt, -- 226
			input, -- 226
			self.uiDraw, -- 226
			self.uiGlow, -- 226
			self.texts, -- 226
			w / uiScale, -- 226
			h / uiScale, -- 226
			uiScale -- 226
		) -- 226
	end -- 226
	self:finishFrame() -- 229
	return action -- 230
end -- 173
return ____exports -- 173