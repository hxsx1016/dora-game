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
	self.narrative:onEnterRoom(p.room.key) -- 123
end -- 116
function WatchFrontend.prototype.clearAll(self) -- 126
	self.bgDraw:clear() -- 127
	self.bgGlow:clear() -- 128
	self.fgDraw:clear() -- 129
	self.fgGlow:clear() -- 130
	self.uiDraw:clear() -- 131
	self.uiGlow:clear() -- 132
	self.backdropArt:beginFrame() -- 133
	self.worldArt:beginFrame() -- 134
	self.uiArt:beginFrame() -- 135
	self.texts:beginFrame() -- 136
end -- 126
function WatchFrontend.prototype.finishFrame(self) -- 139
	self.backdropArt:endFrame() -- 140
	self.worldArt:endFrame() -- 141
	self.uiArt:endFrame() -- 142
	self.texts:endFrame() -- 143
end -- 139
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 147
	self:setVisible(true) -- 148
	self:clearAll() -- 149
	local uiScale = self:resizeInterface(w, h) -- 150
	local act = self.menus:updateAndDrawScreen( -- 151
		dt, -- 152
		self.screen, -- 153
		input, -- 154
		self.stage, -- 155
		self.bgDraw, -- 156
		self.bgGlow, -- 157
		self.backdropArt, -- 158
		self.uiDraw, -- 159
		self.texts, -- 160
		w, -- 161
		h, -- 162
		uiScale -- 163
	) -- 163
	self:finishFrame() -- 165
	return act -- 166
end -- 147
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 170
	self:setVisible(true) -- 171
	if self.boundPlay ~= p then -- 171
		self:bindPlay(p, w, h) -- 173
	end -- 173
	local safeDt = math.min( -- 175
		0.05, -- 175
		math.max(0.001, dt) -- 175
	) -- 175
	local ev = self.adapter:sample(p) -- 178
	self.vfx:ingest(ev, p, self.cam) -- 179
	if not p.paused then -- 179
		self.time = self.time + safeDt -- 182
		self.cam:update(safeDt, p, w, h) -- 183
		self.actors:update(safeDt, p) -- 184
		self.vfx:update( -- 185
			safeDt, -- 185
			themeOf(p.room.key).ambient -- 185
		) -- 185
		self.narrative:update(safeDt, p) -- 186
	else -- 186
		self.narrative.wipeT = 0 -- 189
		self.cam:update(0, p, w, h) -- 190
	end -- 190
	self:clearAll() -- 193
	self.stage:drawBackdrop( -- 196
		self.bgDraw, -- 196
		self.bgGlow, -- 196
		self.backdropArt, -- 196
		p, -- 196
		self.cam, -- 196
		self.time -- 196
	) -- 196
	self.stage:drawPlayableWorld( -- 199
		self.fgDraw, -- 199
		self.fgGlow, -- 199
		self.worldArt, -- 199
		p, -- 199
		self.cam, -- 199
		self.time -- 199
	) -- 199
	self.props:drawAll( -- 202
		self.fgDraw, -- 202
		self.fgGlow, -- 202
		self.worldArt, -- 202
		p, -- 202
		self.cam, -- 202
		self.time -- 202
	) -- 202
	self.actors:drawAll( -- 205
		self.fgDraw, -- 205
		self.fgGlow, -- 205
		self.worldArt, -- 205
		p, -- 205
		self.cam -- 205
	) -- 205
	self.vfx:drawWorldVfx(self.fgGlow, self.worldArt, self.cam) -- 208
	self.stage:drawForegroundFraming( -- 211
		self.fgDraw, -- 211
		w, -- 211
		h, -- 211
		p, -- 211
		self.cam -- 211
	) -- 211
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 212
	local uiScale = self:resizeInterface(w, h) -- 214
	local action = {type = "none"} -- 215
	if p.paused then -- 215
		action = self.menus:updateAndDrawPause( -- 217
			input, -- 217
			self.uiDraw, -- 217
			self.texts, -- 217
			w / uiScale, -- 217
			h / uiScale, -- 217
			uiScale -- 217
		) -- 217
	else -- 217
		self.hud:draw( -- 219
			self.uiDraw, -- 219
			self.uiGlow, -- 219
			self.texts, -- 219
			p, -- 219
			self.cam, -- 219
			self.vfx, -- 219
			self.narrative.letterbox, -- 219
			uiScale -- 219
		) -- 219
		self.narrative:draw( -- 220
			self.uiDraw, -- 220
			self.uiArt, -- 220
			self.texts, -- 220
			p, -- 220
			w / uiScale, -- 220
			h / uiScale -- 220
		) -- 220
	end -- 220
	self:finishFrame() -- 223
	return action -- 224
end -- 170
return ____exports -- 170