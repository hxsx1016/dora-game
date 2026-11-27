-- 《向西守望》Windows 便携发行包启动引导
--
-- 1. 启用独立发行模式：关闭 devMode（确保退出游戏真实关闭进程），注入 watch.release 禁用开发调试跳关热键；
-- 2. 存档策略：默认使用 dora-game-id 提供的隔离用户目录；若包根存在 save/ 目录则切为纯绿色便携存档；
-- 3. 锁定资源搜索路径（Script -> Script/Lib -> 语言包 -> 资源根），再加载 TSTL 编译入口 Script.main；
-- 4. 若存在仅由 CI 临时创建的 .ci-smoke-test 标记文件，则在真实拉起标题页后执行冷启动自检并正常退出。

local _ENV = Dora

local App <const> = App
local Content <const> = Content
local Path <const> = Path
local require <const> = require
local thread <const> = thread
local sleep <const> = sleep

App.devMode = false

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

-- 可选纯绿色便携存档：在可执行文件同目录建立 save/ 文件夹即把存档写入该目录。
local portableSave = false
local portableDir = Path(Content.assetPath, "save")
if Content:exist(portableDir) and Content:isdir(portableDir) then
	Content.writablePath = portableDir
	portableSave = true
end

package.loaded["watch.release"] = {
	isRelease = true,
	version = version,
	portableSave = portableSave,
}

Content.searchPaths = {
	Path(Content.assetPath, "Script"),
	Path(Content.assetPath, "Script", "Lib"),
	Path(Content.assetPath, "Script", "Lib", "Dora", App.locale:match("^zh") and "zh-Hans" or "en"),
	Content.assetPath,
}

require("Script.main")

-- CI 自动化冷启动冒烟钩子（正式发行包中不包含 .ci-smoke-test 文件，对玩家零影响）
local smokeFlag = Path(Content.assetPath, ".ci-smoke-test")
if Content:exist(smokeFlag) then
	thread(function()
		sleep(1.5)
		local hook = package.loaded["watch.fe"]
		local ok = true
		local lines = {
			"version=" .. tostring(version),
			"platform=" .. tostring(App.platform),
			"portableSave=" .. tostring(portableSave),
		}
		local function assertCheck(name, cond)
			if cond then
				lines[#lines + 1] = "PASS " .. name
			else
				ok = false
				lines[#lines + 1] = "FAIL " .. name
			end
		end
		assertCheck("watch.fe hook loaded", hook ~= nil)
		assertCheck("isRelease enabled", hook ~= nil and hook.isRelease() == true)
		assertCheck("title backdrop exists", Content:exist("assets/art/title.png"))
		assertCheck("sprites clip exists", Content:exist("assets/art/sprites.clip"))
		assertCheck("font zhisong exists", Content:exist("assets/font/lxgw-neo-zhisong.ttf"))
		assertCheck("combat shot wav exists", Content:exist("assets/audio/combat/shot.wav"))
		assertCheck("prologue wav exists", Content:exist("assets/audio/prologue/night_distant_fire.wav"))
		assertCheck("sfx knock wav exists", Content:exist("assets/audio/sfx/knock.wav"))
		lines[#lines + 1] = ok and "SMOKE_OK" or "SMOKE_FAIL"
		Content:save(Path(Content.assetPath, ".ci-smoke-result.txt"), table.concat(lines, "\n") .. "\n")
		sleep(0.2)
		App:shutdown()
	end)
end
