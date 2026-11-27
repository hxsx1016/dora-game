-- 《向西守望》Android 掌机（KT-R1 / KT-R2）独立发行包启动引导（注入至 APK 内 assets/Script/init.lua）
--
-- 1. 启用独立发行模式并绑定 target="handheld"（仅触屏 + 手柄，锁定横屏，零键鼠与竖屏代码）；
-- 2. 锁定 APK 内资源搜索路径，加载 TSTL 编译入口 Script.main；
-- 3. 存档落于应用私有 Content.writablePath/watch-save/。

local _ENV = Dora

local App <const> = App
local Content <const> = Content
local Path <const> = Path
local require <const> = require

App.devMode = false
if App.webIDEEnabled ~= nil then
	pcall(function()
		App.webIDEEnabled = false
	end)
end

local version = "release"
local versionFile = Path(Content.assetPath, "VERSION.txt")
if Content:exist(versionFile) then
	local raw = Content:load(versionFile)
	if raw and raw ~= "" then
		local firstLine = raw:match("^([^\r\n]+)")
		if firstLine and firstLine ~= "" then
			version = firstLine
		end
	end
end

package.loaded["watch.target"] = "handheld"
package.loaded["watch.release"] = {
	isRelease = true,
	version = version,
	platform = "Android",
	target = "handheld",
	portableSave = false,
}

Content.searchPaths = {
	Path(Content.assetPath, "Script"),
	Path(Content.assetPath, "Script", "Lib"),
	Path(Content.assetPath, "Script", "Lib", "Dora", App.locale:match("^zh") and "zh-Hans" or "en"),
	Content.assetPath,
}

require("Script.main")
