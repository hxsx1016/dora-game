-- [ts]: init.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 7
local Director = ____Dora.Director -- 7
local Node = ____Dora.Node -- 7
local Size = ____Dora.Size -- 7
local Vec2 = ____Dora.Vec2 -- 7
local View = ____Dora.View -- 7
local ____app = require("Script.watch.app") -- 8
local start = ____app.start -- 8
local W = View.size.width -- 10
local H = View.size.height -- 11
local root = Node() -- 13
root.size = Size(W, H) -- 14
root.anchor = Vec2(0, 0) -- 15
root.position = Vec2(-W / 2, -H / 2) -- 16
Director.ui:addChild(root) -- 17
start(root) -- 19
return ____exports -- 19