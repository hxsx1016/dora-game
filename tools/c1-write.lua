-- C1 跨进程存：隔离档案写一次（真实应用启动 A）。
local Dora = require("Dora")
local C = Dora.Content
C:addSearchPath(C.assetPath .. "/Script"); C:addSearchPath(C.assetPath .. "/Script/Lib"); C:addSearchPath(C.assetPath)
package.path = package.path .. ";" .. C.assetPath .. "/?.lua"
local save = require("Script.watch.save")
local FILE = "watch-save/c1-restart.txt"
C:remove(C.writablePath .. "/" .. FILE)
save.setSaveFile(FILE)
local r = save.loadSave()
print("WRITE start status=", r.status)
r.state.childCleared = true
r.state.soldierCleared = true
r.state.artifactOwned = true
r.state.museumPhase = "hall_walk"
r.state.museumSeen = false
print("WRITE save=", tostring(save.saveSave(r.state)))
print("WRITE reload status=", save.loadSave().status)
