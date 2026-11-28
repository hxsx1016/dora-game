-- 《向西守望》Windows 便携发行包启动引导（位于 runtime/Script/init.lua）
--
-- 1. 启用独立发行模式：关闭 devMode 与 Web IDE，注入 watch.release 禁用开发调试跳关热键；
-- 2. 默认便携存档：将 Content.writablePath 定向至 <游戏根目录>/saves/（采用常规单机结构：
--    profile.sav / autosave.sav / slots/slot_1..3.sav / settings.ini / backups/ / logs/），
--    首次启动自动平滑迁移旧版 save/watch-save 或 %APPDATA% 存档；若游戏目录只读则自动安全降级至用户目录；
-- 3. 锁定最小资源搜索路径（Script -> Script/Lib -> runtime 根），用 xpcall 保护主入口并在启动崩溃时导出 logs/crash.log；
-- 4. 若存在仅由 CI 临时创建的 .ci-smoke-test 标记文件，则在真实拉起标题页后执行冷启动与存档/降级自检并正常退出。

local _ENV = Dora

local App <const> = App
local Content <const> = Content
local Path <const> = Path
local require <const> = require
local thread <const> = thread
local sleep <const> = sleep

App.devMode = false
pcall(function()
	App.webIDEEnabled = false
end)

local assetRoot = Content.assetPath
local gameRoot = assetRoot
if Path:getFilename(assetRoot):lower() == "runtime" then
	local parent = Path:getPath(assetRoot)
	if parent and parent ~= "" then
		gameRoot = parent
	end
end

local version = "release"
local versionFile = Path(assetRoot, "VERSION.txt")
if Content:exist(versionFile) then
	local raw = Content:load(versionFile)
	if raw and raw ~= "" then
		local firstLine = raw:match("^([^\r\n]+)")
		if firstLine and firstLine ~= "" then
			version = firstLine
		end
	end
end

local function probeWritableDir(dir)
	if not Content:exist(dir) then
		Content:mkdir(dir)
	end
	if not Content:isdir(dir) then
		return false
	end
	local probe = Path(dir, "._rw_probe.tmp")
	local wrote = Content:save(probe, "ok\n")
	local readBack = wrote and Content:load(probe) or ""
	pcall(function()
		Content:remove(probe)
	end)
	return wrote == true and readBack:find("ok", 1, true) ~= nil
end

-- 默认便携存档目录：<游戏根目录>/saves/；若目录不可写（如 Program Files / 只读介质），自动降级至系统用户目录。
local portableSavesDir = Path(gameRoot, "saves")
local portableSave = false
local saveFallbackReason = ""
local migratedFrom = ""

if probeWritableDir(portableSavesDir) then
	Content.writablePath = portableSavesDir
	portableSave = true
else
	-- 只读回退：仍采用干净的便携文件结构落在 Content.appPath/saves 下，避免双层 watch-save 嵌套
	local fallbackDir = Path(Content.appPath, "saves")
	if probeWritableDir(fallbackDir) then
		Content.writablePath = fallbackDir
	else
		Content.writablePath = Content.appPath
	end
	saveFallbackReason = "readonly"
end

local saveRoot = Content.writablePath
local backups = Path(saveRoot, "backups")
Content:mkdir(Path(saveRoot, "slots"))
Content:mkdir(backups)
Content:mkdir(Path(saveRoot, "logs"))

local legacySources = {
	{ label = "save", dir = Path(gameRoot, "save", "watch-save") },
	{ label = "appdata", dir = Path(Content.appPath, "watch-save") },
}

-- 同一档案的主件和恢复件只从一个旧目录取。每组成功后单独记账，避免删档后再次导入。
local function migrateLegacyFile(oldName, newName, hasRecovery)
	local marker = Path(backups, newName .. ".legacy-imported")
	if Content:exist(marker) and Content:load(marker) == "done" then return end
	local primary = Path(saveRoot, newName)
	local tmp = primary .. ".tmp"
	local prev = Path(backups, newName .. ".prev")
	-- 新版中断写入后只剩恢复件时，保留它的读取优先级。
	local pendingRecovery = hasRecovery and not Content:exist(primary)
		and (Content:exist(tmp) or Content:exist(prev))
	local files = { { suffix = "", dst = primary, skip = pendingRecovery } }
	if hasRecovery then
		files[#files + 1] = { suffix = ".tmp", dst = tmp, skip = pendingRecovery }
		files[#files + 1] = { suffix = ".prev", dst = prev }
	end
	for _, source in ipairs(legacySources) do
		local found = false
		for _, file in ipairs(files) do
			local src = Path(source.dir, oldName .. file.suffix)
			if Content:exist(src) and not Content:isdir(src) then
				found = true
				if not file.skip and not Content:exist(file.dst) then
					local staging = file.dst .. ".importing"
					if not Content:copy(src, staging) or Content:load(src) ~= Content:load(staging)
						or not Content:move(staging, file.dst) then
						Content:remove(staging)
						return
					end
					migratedFrom = source.label
				end
			end
		end
		if found then
			Content:save(marker, "done")
			return
		end
	end
end

migrateLegacyFile("archive.txt", "profile.sav", true)
migrateLegacyFile("session.txt", "autosave.sav", true)
migrateLegacyFile("controls.txt", "settings.ini", false)

package.loaded["watch.target"] = "windows"
package.loaded["watch.release"] = {
	isRelease = true,
	version = version,
	target = "windows",
	portableSave = portableSave,
	saveLayout = "portable",
	saveFallbackReason = saveFallbackReason,
	migratedFrom = migratedFrom,
	gameRoot = gameRoot,
}

Content.searchPaths = {
	Path(assetRoot, "Script"),
	Path(assetRoot, "Script", "Lib"),
	assetRoot,
}

local bootOk, bootErr = xpcall(function()
	require("Script.main")
end, debug.traceback)

if not bootOk then
	local logsDir = Path(Content.writablePath, "logs")
	Content:mkdir(logsDir)
	local crashPath = Path(logsDir, "crash.log")
	pcall(function()
		App:saveLog(Path(logsDir, "engine.log"))
	end)
	pcall(function()
		Content:save(crashPath, "WestwardWatch boot error (" .. tostring(version) .. "):\n" .. tostring(bootErr) .. "\n")
	end)
	error(bootErr, 0)
end

-- CI 自动化冷启动冒烟钩子（正式发行包中不包含 .ci-smoke-test 文件，对玩家零影响）
local smokeFlag = Path(gameRoot, ".ci-smoke-test")
if not Content:exist(smokeFlag) then
	smokeFlag = Path(assetRoot, ".ci-smoke-test")
end
if Content:exist(smokeFlag) then
	thread(function()
		sleep(1.5)
		local hook = package.loaded["watch.fe"]
		local saveMod = require("Script.watch.save")
		local ctrlMod = require("Script.watch.controls_config")
		local ok = true
		local lines = {
			"version=" .. tostring(version),
			"platform=" .. tostring(App.platform),
			"target=" .. tostring(hook ~= nil and hook.getTargetId() or "unknown"),
			"portableSave=" .. tostring(portableSave),
			"saveFallbackReason=" .. tostring(saveFallbackReason),
			"migratedFrom=" .. tostring(migratedFrom),
			"writablePath=" .. tostring(Content.writablePath),
			"gameRoot=" .. tostring(gameRoot),
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
		assertCheck("target locked to windows", hook ~= nil and hook.getTargetId() == "windows")
		assertCheck("no touch/gamepad overlay in windows pack", hook ~= nil and hook.getTouchController() == nil and hook.getTouchRouter() == nil and hook.getGamepad() == nil)
		assertCheck("stripped touch_core.lua", not Content:exist("Script/watch/input/touch_core.lua"))
		assertCheck("stripped gamepad_core.lua", not Content:exist("Script/watch/input/gamepad_core.lua"))
		assertCheck("stripped aim_assist.lua", not Content:exist("Script/watch/input/aim_assist.lua"))
		assertCheck("stripped gamecontrollerdb.txt", not Content:exist("gamecontrollerdb.txt"))
		assertCheck("stripped Dora Agent lib", not Content:exist(Path(assetRoot, "Script", "Lib", "Agent")))
		assertCheck("stripped Dora sarasa font", not Content:exist(Path(assetRoot, "Font", "sarasa-mono-sc-regular.ttf")))
		assertCheck("stripped Dora default logo", not Content:exist(Path(assetRoot, "Image", "logo.png")))
		assertCheck("root LICENSE exists", Content:exist(Path(gameRoot, "LICENSE")))
		assertCheck("root cmd script removed", not Content:exist(Path(gameRoot, "启动-向西守望.cmd")))
		assertCheck("dialogues module loads", pcall(require, "Script.watch.dialogues") == true)
		assertCheck("title backdrop exists", Content:exist("assets/art/title.png"))
		assertCheck("brand game logo exists", Content:exist("assets/art/brand/game_logo_h.png"))
		assertCheck("brand team logo exists", Content:exist("assets/art/brand/team_logo_dark.png"))
		assertCheck("brand app icon exists", Content:exist("assets/art/brand/app_icon.png"))
		assertCheck("sprites clip exists", Content:exist("assets/art/sprites.clip"))
		assertCheck("font zhisong exists", Content:exist("assets/font/lxgw-neo-zhisong.ttf"))
		assertCheck("combat shot wav exists", Content:exist("assets/audio/combat/shot.wav"))
		assertCheck("prologue wav exists", Content:exist("assets/audio/prologue/night_distant_fire.wav"))
		assertCheck("sfx knock wav exists", Content:exist("assets/audio/sfx/knock.wav"))

		-- 便携存档体系真写盘回读自检（profile.sav / slots / settings.ini / backups）
		local testProfile = saveMod.emptySave()
		testProfile.childCleared = true
		local savedProfile = saveMod.saveSave(testProfile)
		local loadedProfile = saveMod.loadSave()
		assertCheck("portable profile.sav write/readback", savedProfile == true and Content:exist(Path(Content.writablePath, "profile.sav")) and loadedProfile.status == "ok" and loadedProfile.state.childCleared == true)
		assertCheck("no legacy watch-save nesting", not Content:exist(Path(Content.writablePath, "watch-save")))

		local s = ctrlMod.defaultControlSettings()
		s.masterVol = 0.8
		s.assistHints = true
		ctrlMod.saveControlSettings(s)
		local sBack = ctrlMod.loadControlSettings()
		assertCheck("portable settings.ini write/readback", Content:exist(Path(Content.writablePath, "settings.ini")) and sBack.assistHints == true)

		local slots = saveMod.listSaveSlots()
		assertCheck("multi-slot API returns 4 slots", slots ~= nil and #slots == 4)

		-- 清理冒烟自检生成的测试档案，避免污染后续轮次
		pcall(function() Content:remove(Path(Content.writablePath, "profile.sav")) end)
		pcall(function() Content:remove(Path(Content.writablePath, "settings.ini")) end)

		lines[#lines + 1] = ok and "SMOKE_OK" or "SMOKE_FAIL"
		local resultText = table.concat(lines, "\n") .. "\n"
		local resultPath = Path(gameRoot, ".ci-smoke-result.txt")
		if not Content:save(resultPath, resultText) then
			Content:save(Path(Content.writablePath, ".ci-smoke-result.txt"), resultText)
		end
		sleep(0.2)
		App:shutdown()
	end)
end
