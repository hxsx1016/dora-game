-- 《向西守望》Android 独立发行包启动引导（注入至 APK 内 assets/Script/init.lua）
--
-- 1. 启用独立发行模式：关闭 devMode（禁止弹出 Dora Web IDE 侧栏，退出动作真实关闭进程），
--    注入 watch.release（含 platform="Android"，开启独立 APK 退出菜单与禁用调试跳关热键）；
-- 2. 锁定 APK 内资源搜索路径（Script -> Script/Lib -> 语言包 -> assets 根），再加载 TSTL 编译入口 Script.main；
-- 3. 存档自动落于应用私有 Content.writablePath/watch-save/，卸载干净无残留，无需危险外部存储权限。

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

package.loaded["watch.release"] = {
	isRelease = true,
	version = version,
	platform = "Android",
	portableSave = false,
}

Content.searchPaths = {
	Path(Content.assetPath, "Script"),
	Path(Content.assetPath, "Script", "Lib"),
	Path(Content.assetPath, "Script", "Lib", "Dora", App.locale:match("^zh") and "zh-Hans" or "en"),
	Content.assetPath,
}

require("Script.main")
