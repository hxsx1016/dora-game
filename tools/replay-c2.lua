-- C2 端到端回放：正式入口起局 → 井口拾取 → 初次使用进馆 → 四步 → 回柜边。
-- 跑法（仓库根临时入口）：
--   ~/Applications/Dora.app/Contents/MacOS/Dora cli run -p . --entry tmp-replay-c2.lua
--   ~/Applications/Dora.app/Contents/MacOS/Dora cli log -n 60
local Dora = require("Dora")
local Content = Dora.Content
Content:addSearchPath(Content.assetPath .. "/Script")
Content:addSearchPath(Content.assetPath .. "/Script/Lib")
Content:addSearchPath(Content.assetPath)
package.path = package.path .. ";" .. Content.assetPath .. "/?.lua"

local app = require("Script.watch.app")
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local runmod = require("Script.watch.run")
local save = require("Script.watch.save")
local lualib = package.loaded["Script.Lib.lualib_bundle"] or require("Script.Lib.lualib_bundle")

local root = Dora.Node()
root.size = Dora.Size(Dora.Vec2(Dora.View.size.width, Dora.View.size.height))
root.anchor = Dora.Vec2(0, 0)
root.position = Dora.Vec2(-Dora.View.size.width / 2, -Dora.View.size.height / 2)
Dora.Director.ui:addChild(root)
app.start(root, 1, "title")

local fe = package.loaded["watch.fe"]
local FILE = "watch-save/replay-c2.txt"
save.setSaveFile(FILE)
local st = save.emptySave()
st.childCleared = true
st.soldierCleared = true
st.artifactOwned = false
st.museumPhase = "locked"
st.museumSeen = false
save.saveSave(st)
fe.useTestSave(FILE)
print("[正式入口] profile=" .. tostring(fe.getProfileStatus()))
local p0 = fe.startStory()
print(string.format("[正式入口] room=%s source=%s artifact=%s museumPhase=%s",
	p0.room.key, p0.run.source, tostring(p0.run.archive.artifactOwned), p0.run.archive.museumPhase))

local function newInput() return lualib.__TS__New(input.Input) end
local function tap(i, k) local ks = i[k]; ks.held = true; ks.pressed = true end
local function rel(i, k) local ks = i[k]; ks.held = false; ks.pressed = false; ks.released = false end
local function step(p, i, n)
	for _ = 1, n or 1 do
		p:update(play.STEP, i)
		i.interact.pressed = false; i.interact.held = false
		i.jump.pressed = false; i.jump.held = false
		i.pause.pressed = false; i.pause.held = false
	end
end
local function drain(p, tag)
	for _, e in ipairs(p:drainEvents()) do
		if e.name ~= "shotResolved" and e.name ~= "fearChanged" then
			print(string.format("[%s t%d] %s %s", tag, e.tick, e.name, tostring(e.data and e.data.step or "")))
		end
	end
end

print("== 井口 ==")
local i = newInput()
local p = p0
p.player.x = 430
step(p, i, 1)
print(string.format("t%d wellOpen=%s nearWell=%s x=%.1f", p.ticks, tostring(p.wellOpen), tostring(p:nearWell()), p.player.x))
tap(i, "interact"); step(p, i, 1); rel(i, "interact")
print(string.format("t%d phase=%s", p.ticks, p.phase))
step(p, i, 30)
drain(p, "井")
print(string.format("t%d artifact=%s wellTaken=%s phase=%s", p.ticks,
	tostring(p.run.archive.artifactOwned), tostring(p.wellTaken), p.phase))

print("== 初次使用进馆 ==")
p.player.x = 430
tap(i, "interact"); step(p, i, 1); rel(i, "interact")
print(string.format("t%d want=%s museumPhase=%s", p.ticks, p.wantRoom, p.run.archive.museumPhase))
drain(p, "进馆")

print("== 馆内四步 ==")
local mu = lualib.__TS__New(play.Play, rooms.MUSEUM_ROOM, nil, p.run)
print(string.format("t%d room=%s phase=%s", mu.ticks, mu.room.key, mu.phase))
tap(i, "interact"); step(mu, i, 1); rel(i, "interact")
print(string.format("[柜前] t%d phase=%s museumPhase=%s", mu.ticks, mu.phase, mu.run.archive.museumPhase))
drain(mu, "柜")
mu.player.x = 900
tap(i, "interact"); step(mu, i, 1); rel(i, "interact")
print(string.format("[走廊] t%d phase=%s museumPhase=%s", mu.ticks, mu.phase, mu.run.archive.museumPhase))
drain(mu, "廊")
mu.player.x = 1250
tap(i, "interact"); step(mu, i, 1); rel(i, "interact")
print(string.format("[末厅] t%d phase=%s museumPhase=%s", mu.ticks, mu.phase, mu.run.archive.museumPhase))
drain(mu, "灯")
mu.player.x = 240
tap(i, "interact"); step(mu, i, 1); rel(i, "interact")
print(string.format("[叩一] t%d phase=%s", mu.ticks, mu.phase))
step(mu, i, 7); drain(mu, "叩")
step(mu, i, 29)
print(string.format("[回柜] t%d phase=%s museumSeen=%s museumPhase=%s",
	mu.ticks, mu.phase, tostring(mu.run.archive.museumSeen), mu.run.archive.museumPhase))
drain(mu, "完")

print("== 回柜边 ==")
tap(i, "interact"); step(mu, i, 1); rel(i, "interact")
print(string.format("t%d want=%s", mu.ticks, mu.wantRoom))
local pro = lualib.__TS__New(play.Play, rooms.PROLOGUE_ROOM, nil, mu.run)
step(pro, i, 1)
print(string.format("[序章] t%d phase=%s x=%.1f museumReturn=%s", pro.ticks, pro.phase, pro.player.x,
	tostring(pro.run.story.museumReturn)))
drain(pro, "回")
print("[档案] artifact=" .. tostring(pro.run.archive.artifactOwned)
	.. " museumPhase=" .. pro.run.archive.museumPhase
	.. " museumSeen=" .. tostring(pro.run.archive.museumSeen))
print("C2 回放结束")
