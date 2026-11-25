-- D-B2E 默认入口：走 app.start 的真实标题开局函数，核对正式来源与结局记档。
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
local lualib = package.loaded["Script.Lib.lualib_bundle"] or require("Script.Lib.lualib_bundle")

local PASS, FAIL = 0, 0
local function say(s) print(s) end
local function check(tag, cond, detail)
	if cond then PASS = PASS + 1; say("  PASS " .. tag)
	else FAIL = FAIL + 1; say("  FAIL " .. tag .. " | " .. tostring(detail or "")) end
end

local root = Dora.Node()
root.size = Dora.Size(Dora.Vec2(Dora.View.size.width, Dora.View.size.height))
root.anchor = Dora.Vec2(0, 0)
root.position = Dora.Vec2(-Dora.View.size.width / 2, -Dora.View.size.height / 2)
Dora.Director.ui:addChild(root)
app.start(root, 1, "title")

local fe = package.loaded["watch.fe"]
check("验收钩子存在", fe ~= nil and fe.startStory ~= nil, "fe=" .. tostring(fe))
local p = fe.startStory()
check("标题开局创建剧情 Play", p ~= nil and p.room.key == "prologue", "room=" .. tostring(p and p.room.key))
check("标题开局来源 official", p.run.source == "official", "source=" .. tostring(p.run.source))
check("标题开局是新 storyRun", p.run.story.route == "" and p.run.story.settled == false,
	"route=" .. tostring(p.run.story.route) .. " settled=" .. tostring(p.run.story.settled))

-- 用同一 run 走到团圆结局；房间用夹具直达塔，切房链本身已由 replay-b2 与 walk 覆盖。
local r = p.run
r.story.route = "soldier"
r.story.settled = true
r.story.segments["escort5"] = true
local tp = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, r)
tp.storyRoute = "soldier"
tp.storySettled = true
tp.enemies = {}
local i = lualib.__TS__New(input.Input)
local function tap(k) local ks = i[k]; ks.held = true; ks.pressed = true end
local function rel(k) local ks = i[k]; ks.held = false; ks.pressed = false; ks.released = false end
tap("interact"); tp:update(play.STEP, i); i.interact.pressed = false; i.interact.held = false
for _ = 1, 240 do tp:update(play.STEP, i); i.interact.pressed = false; i.interact.held = false end
check("男主默认入口团圆", r.story.ending == "reunion" and r.finished == true,
	"ending=" .. tostring(r.story.ending))
check("正式结局记档 soldier", r.archive.soldierCleared == true and r.archive.childCleared == false,
	"soldier=" .. tostring(r.archive.soldierCleared))
check("结局不发神器", r.archive.artifactOwned == false, "artifact=" .. tostring(r.archive.artifactOwned))
check("姓名第一行小满", tp.endingLines[1] == "小满" and tp.endingLines[2] == "周戍",
	"lines=" .. tostring(tp.endingLines[1]) .. "/" .. tostring(tp.endingLines[2]))

-- 章节直达：同一钩子用 chapter 来源，能看演出但不记档。
local towerIdx = -1
for idx2, room in ipairs(rooms.ROOMS) do if room.key == "tower" then towerIdx = idx2 - 1 end end
local p2 = fe.previewChapter(towerIdx)
check("章节直达落在塔", p2 ~= nil and p2.room.key == "tower", "room=" .. tostring(p2 and p2.room.key))
local r2 = p2.run
r2.story.route = "child"
r2.story.settled = true
r2.story.countTick = 1440
local tp2 = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, r2)
tp2.storyRoute = "child"
tp2.storySettled = true
tap("interact"); tp2:update(play.STEP, i); i.interact.pressed = false; i.interact.held = false
for _ = 1, 240 do tp2:update(play.STEP, i); i.interact.pressed = false; i.interact.held = false end
check("章节直达不算正式", r2.source == "chapter", "source=" .. tostring(r2.source))
check("章节直达不记档", r2.archive.childCleared == false, "child=" .. tostring(r2.archive.childCleared))

say(string.format("D-B2E 默认入口：%d 通过 / %d 失败", PASS, FAIL))
assert(FAIL == 0, "D-B2E 失败")
