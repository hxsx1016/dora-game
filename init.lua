-- [ts]: init.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 8
local Content = ____Dora.Content -- 8
local Director = ____Dora.Director -- 8
local Node = ____Dora.Node -- 8
local Size = ____Dora.Size -- 8
local Vec2 = ____Dora.Vec2 -- 8
local View = ____Dora.View -- 8
local ____app = require("Script.watch.app") -- 9
local start = ____app.start -- 9
local function ensureSearchPath(path) -- 11
	local i = 0 -- 12
	do -- 12
		i = 0 -- 13
		while i < #Content.searchPaths do -- 13
			if Content.searchPaths[i + 1] == path then -- 13
				return -- 15
			end -- 15
			i = i + 1 -- 13
		end -- 13
	end -- 13
	Content:addSearchPath(path) -- 18
end -- 11
ensureSearchPath(Content.assetPath .. "/Script") -- 21
ensureSearchPath(Content.assetPath .. "/Script/Lib") -- 22
ensureSearchPath(Content.assetPath) -- 23
local W = View.size.width -- 25
local H = View.size.height -- 26
local root = Node() -- 28
root.size = Size(W, H) -- 29
root.anchor = Vec2(0, 0) -- 30
root.position = Vec2(-W / 2, -H / 2) -- 31
Director.ui:addChild(root) -- 32
start(root, 1, "splash") -- 34
return ____exports -- 34