-- 守望 · Windows 便携包引导
--
-- TSTL 生成的入口在文件顶部就会 require 游戏模块，那时搜索路径还没设好，
-- 独立 exe 又不像 Web IDE 那样自带“项目目录/Script”这两条路径，
-- 所以先在这里把路径定死，再交给 main.lua。
--
-- 搜索顺序与引擎默认一致：Script → Script/Lib → 语言包 → 资源根。

local _ENV = Dora

local Content <const> = Content
local Path <const> = Path
local App <const> = App
local require <const> = require

Content.searchPaths = {
	Path(Content.assetPath, "Script"),
	Path(Content.assetPath, "Script", "Lib"),
	Path(Content.assetPath, "Script", "Lib", "Dora", App.locale:match("^zh") and "zh-Hans" or "en"),
	Content.assetPath,
}

require("Script.main")
