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
function WatchFrontend.prototype.____constructor(self, parent) -- 52
	self.cam = __TS__New(CameraDirector) -- 38
	self.adapter = __TS__New(PlayAdapter) -- 39
	self.stage = __TS__New(StageRenderer) -- 40
	self.props = __TS__New(PropsRenderer) -- 41
	self.actors = __TS__New(ActorsRenderer) -- 42
	self.vfx = __TS__New(VfxSystem) -- 43
	self.hud = __TS__New(HudRenderer) -- 44
	self.narrative = __TS__New(NarrativeRenderer) -- 45
	self.menus = __TS__New(MenuRenderer) -- 46
	self.screen = "title" -- 48
	self.time = 0 -- 49
	self.layerRoot = Node() -- 53
	self.layerRoot.order = 5 -- 54
	self.layerRoot:addTo(parent) -- 55
	local additive = BlendFunc("SrcAlpha", "One") -- 57
	self.bgDraw = DrawNode() -- 59
	self.bgDraw.order = 10 -- 60
	self.bgDraw:addTo(self.layerRoot) -- 61
	self.bgGlow = DrawNode() -- 63
	self.bgGlow.order = 15 -- 64
	self.bgGlow.blendFunc = additive -- 65
	self.bgGlow:addTo(self.layerRoot) -- 66
	self.assets = __TS__New(AssetSlotHost, self.layerRoot, 20) -- 68
	self.fgDraw = DrawNode() -- 70
	self.fgDraw.order = 30 -- 71
	self.fgDraw:addTo(self.layerRoot) -- 72
	self.fgGlow = DrawNode() -- 74
	self.fgGlow.order = 35 -- 75
	self.fgGlow.blendFunc = additive -- 76
	self.fgGlow:addTo(self.layerRoot) -- 77
	self.uiDraw = DrawNode() -- 79
	self.uiDraw.order = 40 -- 80
	self.uiDraw:addTo(self.layerRoot) -- 81
	self.uiGlow = DrawNode() -- 83
	self.uiGlow.order = 45 -- 84
	self.uiGlow.blendFunc = additive -- 85
	self.uiGlow:addTo(self.layerRoot) -- 86
	self.texts = __TS__New(TextPool, self.layerRoot, 50) -- 88
end -- 52
function WatchFrontend.prototype.setVisible(self, v) -- 92
	self.layerRoot.visible = v -- 93
	if not v then -- 93
		self.texts:hideAll() -- 95
	end -- 95
end -- 92
function WatchFrontend.prototype.bindPlay(self, p, w, h) -- 100
	self.boundPlay = p -- 101
	p.worldMapper = function(sx, sy) return self.cam:screenToWorld(sx, sy) end -- 102
	self.cam:snap(p, w, h) -- 103
	self.adapter:reset(p) -- 104
	self.actors:reset() -- 105
	self.vfx:reset() -- 106
	self.hud:reset(p) -- 107
	self.narrative:onEnterRoom(p.room.key) -- 108
end -- 100
function WatchFrontend.prototype.clearAll(self) -- 111
	self.bgDraw:clear() -- 112
	self.bgGlow:clear() -- 113
	self.fgDraw:clear() -- 114
	self.fgGlow:clear() -- 115
	self.uiDraw:clear() -- 116
	self.uiGlow:clear() -- 117
	self.assets:beginFrame() -- 118
	self.texts:beginFrame() -- 119
end -- 111
function WatchFrontend.prototype.finishFrame(self) -- 122
	self.assets:endFrame() -- 123
	self.texts:endFrame() -- 124
end -- 122
function WatchFrontend.prototype.renderMenu(self, dt, input, w, h) -- 128
	self:setVisible(true) -- 129
	self:clearAll() -- 130
	local act = self.menus:updateAndDrawScreen( -- 131
		dt, -- 132
		self.screen, -- 133
		input, -- 134
		self.stage, -- 135
		self.bgDraw, -- 136
		self.bgGlow, -- 137
		self.uiDraw, -- 138
		self.uiGlow, -- 139
		self.texts, -- 140
		w, -- 141
		h -- 142
	) -- 142
	self:finishFrame() -- 144
	return act -- 145
end -- 128
function WatchFrontend.prototype.renderPlay(self, dt, p, input, w, h) -- 149
	self:setVisible(true) -- 150
	if self.boundPlay ~= p then -- 150
		self:bindPlay(p, w, h) -- 152
	end -- 152
	local safeDt = math.min( -- 154
		0.05, -- 154
		math.max(0.001, dt) -- 154
	) -- 154
	self.time = self.time + safeDt -- 155
	local ev = self.adapter:sample(p) -- 158
	self.vfx:ingest(ev, p, self.cam) -- 159
	if not p.paused then -- 159
		self.cam:update(safeDt, p, w, h) -- 162
		self.actors:update(safeDt, p) -- 163
		self.vfx:update( -- 164
			safeDt, -- 164
			themeOf(p.room.key).ambient -- 164
		) -- 164
		self.hud:update(safeDt, p) -- 165
		self.narrative:update(safeDt, p) -- 166
	else -- 166
		self.narrative.wipeT = 0 -- 169
		self.cam:update(0, p, w, h) -- 170
	end -- 170
	self:clearAll() -- 173
	self.stage:drawBackdrop( -- 176
		self.bgDraw, -- 176
		self.bgGlow, -- 176
		self.assets, -- 176
		p, -- 176
		self.cam, -- 176
		self.time -- 176
	) -- 176
	self.stage:drawPlayableWorld( -- 179
		self.fgDraw, -- 179
		self.fgGlow, -- 179
		p, -- 179
		self.cam, -- 179
		self.time -- 179
	) -- 179
	self.props:drawAll( -- 182
		self.fgDraw, -- 182
		self.fgGlow, -- 182
		self.assets, -- 182
		p, -- 182
		self.cam, -- 182
		self.time -- 182
	) -- 182
	self.actors:drawAll( -- 185
		self.fgDraw, -- 185
		self.fgGlow, -- 185
		self.assets, -- 185
		p, -- 185
		self.cam -- 185
	) -- 185
	self.vfx:drawWorldVfx(self.fgGlow, self.cam) -- 188
	self.stage:drawForegroundFraming( -- 191
		self.fgDraw, -- 191
		w, -- 191
		h, -- 191
		p, -- 191
		self.cam -- 191
	) -- 191
	self.vfx:drawScreenVfx(self.fgGlow, w, h, p.room.key) -- 192
	self.hud:draw( -- 195
		self.uiDraw, -- 195
		self.uiGlow, -- 195
		self.texts, -- 195
		p, -- 195
		self.cam, -- 195
		self.vfx, -- 195
		self.narrative.letterbox -- 195
	) -- 195
	self.narrative:draw( -- 196
		self.uiDraw, -- 196
		self.uiGlow, -- 196
		self.texts, -- 196
		p, -- 196
		w, -- 196
		h -- 196
	) -- 196
	local action = {type = "none"} -- 199
	if p.paused then -- 199
		action = self.menus:updateAndDrawPause( -- 201
			safeDt, -- 201
			input, -- 201
			self.uiDraw, -- 201
			self.uiGlow, -- 201
			self.texts, -- 201
			w, -- 201
			h -- 201
		) -- 201
	end -- 201
	self:finishFrame() -- 204
	return action -- 205
end -- 149
return ____exports -- 149