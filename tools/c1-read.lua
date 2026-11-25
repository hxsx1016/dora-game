-- C1 跨进程读：同一隔离档案读回（真实应用启动 B）。
local Dora = require("Dora")
local C = Dora.Content
C:addSearchPath(C.assetPath .. "/Script"); C:addSearchPath(C.assetPath .. "/Script/Lib"); C:addSearchPath(C.assetPath)
package.path = package.path .. ";" .. C.assetPath .. "/?.lua"
local save = require("Script.watch.save")
local FILE = "watch-save/c1-restart.txt"
save.setSaveFile(FILE)
local r = save.loadSave()
print("READ status=", r.status, "child=", tostring(r.state.childCleared), "soldier=", tostring(r.state.soldierCleared),
	"artifact=", tostring(r.state.artifactOwned), "museumPhase=", tostring(r.state.museumPhase))
assert(r.status == "ok" and r.state.childCleared and r.state.soldierCleared and r.state.artifactOwned and r.state.museumPhase == "hall_walk",
	"跨进程读回不一致")
print("READ OK")
