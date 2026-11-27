-- D-B2 五段护送与北塔团圆回归：第二段取材、第三段工台双配方、四/五段山道、双结局。
local rooms = require("Script.watch.rooms")
local play = require("Script.watch.play")
local input = require("Script.watch.input")
local runmod = require("Script.watch.run")
local craft = require("Script.watch.craft")
local lualib = require("Script.Lib.lualib_bundle")

local PASS, FAIL = 0, 0
local function say(s) print(s) end
local function check(tag, cond, detail)
	if cond then
		PASS = PASS + 1
		say("PASS  " .. tag .. (detail and ("  | " .. detail) or ""))
	else
		FAIL = FAIL + 1
		say("FAIL  " .. tag .. (detail and ("  | " .. detail) or ""))
	end
end

local function newInput()
	local i = lualib.__TS__New(input.Input)
	i.moveX = 0
	i.moveY = 0
	i.mx = -1
	i.my = -1
	local keys = { "jump", "crouch", "cover", "interact", "aim", "fire", "flare", "pause", "retry", "toggleView", "tab" }
	for _, k in ipairs(keys) do
		i[k] = { held = false, pressed = false, released = false }
	end
	return i
end
local function tap(i, k) i[k].held = true; i[k].pressed = true end
local function rel(i, k) i[k].held = false; i[k].pressed = false; i[k].released = true end
local function step(p, i, n)
	n = n or 1
	for _ = 1, n do
		p:update(play.STEP, i)
		i.interact.pressed = false; i.jump.pressed = false; i.pause.pressed = false
		i.retry.pressed = false; i.fire.pressed = false
	end
end
local function sayRoom(p, tag)
	say(string.format("  %-22s room=%-8s phase=%-16s x=%.1f hp=%d/%d carry=%s route=%s",
		tag or "", p.room.key, p.phase, p.player.x, p.hp, p.maxHp,
		tostring(p.carryOn), p.storyRoute))
end

say("== 1. 第二段粮棚：两条通路取材 ==")
local r = runmod.createRun(20261125)
r.story.route = "soldier"
r.story.carry = true
r.story.hp, r.story.maxHp = 3, 3
local p2 = lualib.__TS__New(play.Play, rooms.ESCORT2_ROOM, nil, r)
check("粮棚背起小满", p2.carryOn == true, "carry=" .. tostring(p2.carryOn))
check("粮棚继承种子", p2.run.seed == 20261125, "seed=" .. tostring(p2.run.seed))
check("粮棚继承血量", p2.hp == 3 and p2.maxHp == 3, "hp=" .. p2.hp .. "/" .. p2.maxHp)
local i2 = newInput()
p2.player.x = 380; p2.player.y = 0
step(p2, i2)
check("棚下拾木纹筹", p2.run.inventory.wood == 1, "wood=" .. p2.run.inventory.wood)
p2.player.x = 560
step(p2, i2)
check("粮袋后拾铃纹筹", p2.run.inventory.bell == 1, "bell=" .. p2.run.inventory.bell)
p2.player.x = 820; p2.player.y = 0; p2.player.depth = 0; p2.player.onGround = true; p2.player.vy = 0
step(p2, i2)
check("棚架后拾第二枚木纹筹", p2.run.inventory.wood == 2, "wood=" .. p2.run.inventory.wood)
local keysWood, keysBell = p2.run.inventory.wood, p2.run.inventory.bell
-- 回访：走回同一点，库存不再增加
p2.player.x = 380; p2.player.y = 0
step(p2, i2, 2)
check("回访同点库存只加一次", p2.run.inventory.wood == keysWood, "wood=" .. p2.run.inventory.wood)
check("回访铃筹不重复", p2.run.inventory.bell == keysBell, "bell=" .. p2.run.inventory.bell)
say(string.format("  取材读数：wood=%d bell=%d taken=%d",
	p2.run.inventory.wood, p2.run.inventory.bell, #p2.pickups))

say("== 2. 第三段工台：两张配方、缺料、二选一 ==")
local r3 = runmod.createRun(20261125)
r3.story.route = "soldier"
r3.story.carry = true
r3.story.hp, r3.story.maxHp = 3, 3
r3.inventory.wood = 2
r3.inventory.bell = 1
local p3 = lualib.__TS__New(play.Play, rooms.ESCORT3_ROOM, nil, r3)
check("工台房无敌人", #p3.enemies == 2 and p3.enemies[1].kind == "target", "enemies=" .. #p3.enemies)
local i3 = newInput()
p3.player.x = 640; p3.player.y = 0
tap(i3, "interact"); step(p3, i3)
check("工台按 E 开面板", p3.craftBench.active == true, "active=" .. tostring(p3.craftBench.active))
check("开面板放下小满", p3.carryOn == false, "carry=" .. tostring(p3.carryOn))
check("两张配方可选", #p3.craftBench.recipes == 2, "recipes=" .. #p3.craftBench.recipes)
check("引路灯铳要两木", p3.craftBench.recipes[1].cost.wood == 2, "cost=" .. tostring(p3.craftBench.recipes[1].cost.wood))
check("回声铳要一木一铃", p3.craftBench.recipes[2].cost.wood == 1 and p3.craftBench.recipes[2].cost.bell == 1,
	"cost=" .. tostring(p3.craftBench.recipes[2].cost.wood) .. "+" .. tostring(p3.craftBench.recipes[2].cost.bell))
check("制作前未装备改制武器", p3.equippedWeapon == "standard_gun", "equipped=" .. p3.equippedWeapon)
-- 取消：关面板重新背起
p3:closeCraftBench()
check("关面板重新背起", p3.carryOn == true and p3.craftBench.active == false,
	"carry=" .. tostring(p3.carryOn) .. " active=" .. tostring(p3.craftBench.active))
-- 再开面板，缺料拒绝
p3.craftBench.active = true
r3.inventory.wood = 0
local before = #p3.events
local okMiss = p3:craftAtBench("guide_lantern_gun", "req-miss")
check("缺料拒绝制作", okMiss == false, "ok=" .. tostring(okMiss))
check("缺料有拒绝事件", #p3.events > before, "events=" .. #p3.events)
r3.inventory.wood = 2
local okLight = p3:craftAtBench("guide_lantern_gun", "req-light")
check("改制引路灯铳", okLight == true, "ok=" .. tostring(okLight))
check("扣两枚木纹筹", p3.run.inventory.wood == 0, "wood=" .. p3.run.inventory.wood)
check("铃纹筹留着", p3.run.inventory.bell == 1, "bell=" .. p3.run.inventory.bell)
check("改制后自动装备", p3.equippedWeapon == "guide_lantern_gun", "equipped=" .. p3.equippedWeapon)
local okAgain = p3:craftAtBench("echo_gun", "req-echo")
check("二选一：第二件被拒", okAgain == false, "ok=" .. tostring(okAgain))
local okDup = p3:craftAtBench("guide_lantern_gun", "req-light")
check("同一 requestId 幂等", okDup == false, "ok=" .. tostring(okDup))
-- 制后检查点 960：整份快照
p3.craftBench.active = false
p3:closeCraftBench()
p3.player.x = 960
step(p3, i3, 2)
check("制后检查点记快照", p3.run.story.cp ~= nil and p3.run.story.cp.id == 960,
	"cp=" .. tostring(p3.run.story.cp and p3.run.story.cp.id))
check("快照记下装备", p3.run.story.cp.equipped == "guide_lantern_gun", "equipped=" .. p3.run.story.cp.equipped)
local r3b = runmod.createRun(20261125)
r3b.story.route = "soldier"
r3b.story.cp = p3.run.story.cp
local p3b = lualib.__TS__New(play.Play, rooms.ESCORT3_ROOM, { checkpoint = 960 }, r3b)
check("制后恢复装备灯铳", p3b.equippedWeapon == "guide_lantern_gun", "equipped=" .. p3b.equippedWeapon)
check("制后恢复木纹筹归零", p3b.run.inventory.wood == 0, "wood=" .. p3b.run.inventory.wood)

say("== 3. 同一制前检查点做另一件（回声铳） ==")
local r3c = runmod.createRun(20261125)
r3c.story.route = "soldier"
r3c.inventory.wood = 2
r3c.inventory.bell = 1
local p3c = lualib.__TS__New(play.Play, rooms.ESCORT3_ROOM, nil, r3c)
p3c.player.x = 300
step(p3c, i3, 2)
check("制前检查点 300", p3c.run.story.cp ~= nil and p3c.run.story.cp.id == 300,
	"cp=" .. tostring(p3c.run.story.cp and p3c.run.story.cp.id))
p3c:openCraftBench()
local okEcho = p3c:craftAtBench("echo_gun", "req-echo2")
check("制前做回声铳", okEcho == true, "ok=" .. tostring(okEcho))
check("回声铳扣一木一铃", p3c.run.inventory.wood == 1 and p3c.run.inventory.bell == 0,
	"wood=" .. p3c.run.inventory.wood .. " bell=" .. p3c.run.inventory.bell)
check("回声铳已装备", p3c.equippedWeapon == "echo_gun", "equipped=" .. p3c.equippedWeapon)
local r3d = runmod.createRun(20261125)
r3d.story.route = "soldier"
r3d.story.cp = p3c.run.story.cp
local p3d = lualib.__TS__New(play.Play, rooms.ESCORT3_ROOM, { checkpoint = 300 }, r3d)
check("制前恢复未改制", p3d.equippedWeapon == "standard_gun", "equipped=" .. p3d.equippedWeapon)
check("制前恢复两木一铃", p3d.run.inventory.wood == 2 and p3d.run.inventory.bell == 1,
	"wood=" .. p3d.run.inventory.wood .. " bell=" .. p3d.run.inventory.bell)

say("== 4. 试射对照：基础枪 / 改制枪 ==")
-- 掩体 700–756 高 52；靶 820、940 都是新鲜存活目标（新 Play，alive=true、fireCd=40）。
local function freshEscort3()
	return lualib.__TS__New(play.Play, rooms.ESCORT3_ROOM, nil, runmod.createRun(20261125, "official"))
end

-- A. 标准枪、无盘效果：普通弹被同一掩体挡下。
local pa = freshEscort3()
pa.equippedWeapon = "standard_gun"
pa.reloadPendingEffect = ""
pa.player.x = 690; pa.player.y = 0
pa.player.crouch = true; pa.player.h = 36
pa:aimAt(820, 30)
pa:shoot(pa.player)
check("普通弹被掩体挡下", pa.enemies[1].hitT <= 0 and pa.enemies[1].alive == true,
	"hitT=" .. pa.enemies[1].hitT .. " alive=" .. tostring(pa.enemies[1].alive))

-- B. 标准枪 + 基础灯纹（B1 已有）：照透掩体，第二人不受光晕影响。
local pb = freshEscort3()
pb.equippedWeapon = "standard_gun"
pb.reloadPendingEffect = "light"
pb.player.x = 690; pb.player.y = 0
pb.player.crouch = true; pb.player.h = 36
pb:aimAt(820, 30)
pb:shoot(pb.player)
check("基础灯纹穿掩体命中", pb.enemies[1].hitT > 0, "hitT=" .. pb.enemies[1].hitT)
check("基础灯纹不镇第二人", pb.enemies[2].fireCd == 40, "fireCd=" .. pb.enemies[2].fireCd)

-- C. 灯铳 + 灯纹：同样穿掩体，且光晕把旁边第二人的下一发推远。
local pc3 = freshEscort3()
pc3.equippedWeapon = "guide_lantern_gun"
pc3.reloadPendingEffect = "light"
pc3.player.x = 690; pc3.player.y = 0
pc3.player.crouch = true; pc3.player.h = 36
pc3:aimAt(820, 30)
pc3:shoot(pc3.player)
check("灯铳灯纹穿掩体命中", pc3.enemies[1].hitT > 0, "hitT=" .. pc3.enemies[1].hitT)
check("灯铳光晕镇第二人", pc3.enemies[2].fireCd == 150, "fireCd=" .. pc3.enemies[2].fireCd)
check("灯铳效果已消费一次", pc3.reloadPendingEffect == "", "pending=" .. pc3.reloadPendingEffect)
-- 同一目标第二发普通：仍被掩体挡（清零上一发的受击计时再验）。
pc3.enemies[1].hitT = 0
pc3.reloadPendingEffect = ""
pc3.player.crouch = true; pc3.player.h = 36
pc3:aimAt(820, 30)
pc3:shoot(pc3.player)
check("灯铳第二发普通被掩体挡", pc3.enemies[1].hitT == 0, "hitT=" .. pc3.enemies[1].hitT)

-- D. 回声：同一目标、三名敌兵；标准枪惊一人、回声铳惊两人。
local function freshEscort2()
	return lualib.__TS__New(play.Play, rooms.ESCORT2_ROOM, nil, runmod.createRun(20261125, "official"))
end
local pd = freshEscort2()
pd.equippedWeapon = "standard_gun"
pd.reloadPendingEffect = "echo"
pd.player.x = 600
pd:aimAt(700, 60)
pd:shoot(pd.player)
check("基础回声命中声源目标", pd.enemies[1].hitT > 0, "hitT=" .. pd.enemies[1].hitT)
local wokeBase = 0
for _, e in ipairs(pd.enemies) do if e.awake then wokeBase = wokeBase + 1 end end
check("基础回声只惊一人", wokeBase == 1, "awake=" .. wokeBase)

local pe = freshEscort2()
pe.equippedWeapon = "echo_gun"
pe.reloadPendingEffect = "echo"
pe.player.x = 600
pe:aimAt(700, 60)
pe:shoot(pe.player)
check("回声铳命中声源目标", pe.enemies[1].hitT > 0, "hitT=" .. pe.enemies[1].hitT)
local wokeEcho = 0
for _, e in ipairs(pe.enemies) do if e.awake then wokeEcho = wokeEcho + 1 end end
check("回声铳惊起两处声源", wokeEcho >= 2, "awake=" .. wokeEcho)

say("== 5. 四段、五段：换弹盘、脱身、塔门 ==")
local r6 = runmod.createRun(20261125)
r6.story.route = "soldier"
r6.story.carry = true
local p6 = lualib.__TS__New(play.Play, rooms.ESCORT4_ROOM, nil, r6)
check("第四段背着小满", p6.carryOn == true, "carry=" .. tostring(p6.carryOn))
p6.player.x = 200
p6.reloadT = 0
p6:beginReload()
check("第四段开换弹盘", p6.reloadOpen == true, "open=" .. tostring(p6.reloadOpen))
p6.player.rollT = 0
local i6 = newInput()
p6:closeReloadPuzzle()
tap(i6, "jump"); i6.moveX = 1; step(p6, i6, 1)
check("快速脱身进入滚身", p6.player.rollT > 0,
	"rollT=" .. string.format("%.2f", p6.player.rollT) .. " x=" .. string.format("%.1f", p6.player.x))
step(p6, i6, 8)
check("滚身拉开距离", p6.player.x > 220, "x=" .. string.format("%.1f", p6.player.x))
p6.run.story.carry = true
local p7 = lualib.__TS__New(play.Play, rooms.ESCORT5_ROOM, nil, r6)
check("第五段背着小满", p7.carryOn == true, "carry=" .. tostring(p7.carryOn))
check("第五段带武器", p7.equippedWeapon == r6.story.craftedWeapon or p7.equippedWeapon == "standard_gun",
	"equipped=" .. p7.equippedWeapon)
p7.player.x = 1320 + 4
p7.partner.x = p7.player.x - 200
step(p7, i6, 2)
check("第五段出口切塔门", p7.wantRoom == "tower", "wantRoom=" .. p7.wantRoom)
check("第五段记段完成", p7.run.story.segments["escort5"] == true, "segments=" .. tostring(p7.run.story.segments["escort5"]))
check("五段走完 escortDone", p7.escortDone == true, "escortDone=" .. tostring(p7.escortDone))
-- 背负转向：面向左时小满在右
p7.carryOn = true
p7.player.facing = -1
p7:carryPose()
check("背负转向贴背侧", math.abs(p7.partner.x - (p7.player.x + 12)) < 0.01 and p7.partner.y == p7.player.y + 26,
	"partner=" .. string.format("%.1f/%.1f", p7.partner.x, p7.partner.y))
-- 暂停冻结背负位置
local i7 = newInput()
tap(i7, "pause"); step(p7, i7)
local bx, by = p7.player.x, p7.player.y
step(p7, i7, 20)
check("暂停冻结背负", p7.player.x == bx and p7.player.y == by,
	"x=" .. string.format("%.1f", p7.player.x))
check("暂停冻结同伴", math.abs(p7.partner.x - (bx + 12)) < 0.01, "partner=" .. string.format("%.1f", p7.partner.x))
tap(i7, "pause"); step(p7, i7)

say("== 6. 受击与失败重开仍 soldier ==")
local p8 = lualib.__TS__New(play.Play, rooms.ESCORT2_ROOM, nil, r6)
p8.storyRoute = "soldier"
p8.storySettled = true
local i8 = newInput()
p8.player.x = 500; p8.player.y = 0; p8.enemies[1].warnT = 1
p8.enemies[1].fireCd = 0
p8.hp = 3
p8.invulnT = 0
step(p8, i8, 3)
check("背负时受击掉血", p8.hp < 3, "hp=" .. p8.hp)
-- 预置一些局内进度，确认死亡重开会清掉。
p8.run.inventory.wood = 2
p8.run.inventory.bell = 1
p8.run.story.craftedWeapon = "guide_lantern_gun"
p8.equippedWeapon = "guide_lantern_gun"
p8.run.story.segments["escort1"] = true
p8.run.story.segments["escort2"] = true
p8.propBroken = true
local p8enemies = #p8.enemies
p8.hp = 0
p8:campaignFailed()
check("失败重开仍是 soldier", p8.run.story.route == "soldier", "route=" .. p8.run.story.route)
check("失败重开回男主入口", p8.wantRoom == "escort1", "want=" .. tostring(p8.wantRoom))
check("失败回入口时清材料", p8.run.inventory.wood == 0 and p8.run.inventory.bell == 0,
	"wood=" .. tostring(p8.run.inventory.wood) .. " bell=" .. tostring(p8.run.inventory.bell))
check("失败回入口清改制武器", p8.run.story.craftedWeapon == "" and p8.equippedWeapon == "standard_gun",
	"weapon=" .. tostring(p8.run.story.craftedWeapon) .. " equipped=" .. p8.equippedWeapon)
check("失败回入口清分段", next(p8.run.story.segments) == nil, "segments 未清")
check("失败回入口清背负", p8.carryOn == false and p8.run.story.carry == false,
	"carry=" .. tostring(p8.carryOn))
check("失败回入口保留通关档案", p8.run.archive.soldierCleared == false, "soldier=" .. tostring(p8.run.archive.soldierCleared))

-- 第四段死亡同样回男主入口，而不是回第四段起点。
local r9 = runmod.createRun(20261125, "official")
r9.story.route = "soldier"
r9.story.settled = true
r9.story.segments["escort1"] = true
r9.story.segments["escort2"] = true
r9.story.segments["escort3"] = true
r9.inventory.wood = 1
r9.story.craftedWeapon = "echo_gun"
local p9 = lualib.__TS__New(play.Play, rooms.ESCORT4_ROOM, nil, r9)
p9.storyRoute = "soldier"
p9.storySettled = true
p9.equippedWeapon = "echo_gun"
p9.carryOn = true
p9.hp = 0
p9:campaignFailed()
check("四段死亡也回男主入口", p9.wantRoom == "escort1", "want=" .. tostring(p9.wantRoom) .. " room=" .. p9.room.key)
check("四段死亡清分段到四之前", p9.run.story.segments["escort4"] == nil and p9.run.story.segments["escort5"] == nil,
	"seg4=" .. tostring(p9.run.story.segments["escort4"]))
check("四段死亡清材料与改制", p9.run.inventory.wood == 0 and p9.run.story.craftedWeapon == "",
	"wood=" .. tostring(p9.run.inventory.wood))

say("== 7. 北塔：男主团圆 ==")
local rt = runmod.createRun(20261125, "official")
rt.story.route = "soldier"
rt.story.settled = true
rt.story.segments["escort5"] = true
rt.story.hp, rt.story.maxHp = 3, 3
local pt = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, rt)
check("塔里控周戍", pt.childMode == false, "childMode=" .. tostring(pt.childMode))
check("塔里路线 soldier", pt.storyRoute == "soldier", "route=" .. pt.storyRoute)
check("塔里放下背负", pt.carryOn == false, "carry=" .. tostring(pt.carryOn))
local it = newInput()
pt.player.x = pt.ox + 445
tap(it, "interact"); step(pt, it)
check("敲门第一下", pt.knocks == 1, "knocks=" .. pt.knocks)
step(pt, it, 12)
check("敲门第二下", pt.knocks == 2, "knocks=" .. pt.knocks)
step(pt, it, 30)
check("开塔门", pt.phase == "tower-enter" and pt.towerDoorOpen, "phase=" .. pt.phase)
pt.player.x = pt.ox + 605; pt.player.y = 0
it.interact.held = true
step(pt, it, 40)
it.interact.held = false
check("桌前长按交物", pt.phase == "tower-given" and pt.towerHanded, "phase=" .. pt.phase)
step(pt, it, 180)
check("男主线结局团圆", pt.phase == "tower-end" and pt.run.story.ending == "reunion",
	"phase=" .. pt.phase .. " ending=" .. pt.run.story.ending)
check("男主线正式记通关", pt.run.archive.soldierCleared == true and pt.run.archive.childCleared == false,
	"soldier=" .. tostring(pt.run.archive.soldierCleared) .. " child=" .. tostring(pt.run.archive.childCleared))
check("男主线单通不发神器", pt.run.archive.artifactOwned == false, "artifact=" .. tostring(pt.run.archive.artifactOwned))
check("男主线登记簿两行", pt.endingLines[1] == "小满" and pt.endingLines[2] == "周戍",
	"lines=" .. tostring(pt.endingLines[1]) .. "/" .. tostring(pt.endingLines[2]))
check("落幕事件只一次", #pt.events >= 1 and pt.run.finished == true, "finished=" .. tostring(pt.run.finished))
local endEvents = 0
for _, ev in ipairs(pt.events) do if ev.name == "endingReached" then endEvents = endEvents + 1 end end
check("endingReached 恰一次", endEvents == 1, "count=" .. endEvents)
tap(it, "interact"); step(pt, it); rel(it, "interact")
check("片尾 8 秒阅读期内提前按 E 不中断落幕", pt.wantRoom == "", "wantRoom=" .. pt.wantRoom)
step(pt, it, 305)
tap(it, "interact"); step(pt, it); rel(it, "interact")
check("片尾满 8 秒后 E 再玩回序章", pt.wantRoom == "prologue", "wantRoom=" .. pt.wantRoom)
check("再玩不改结局", pt.run.story.ending == "reunion", "ending=" .. pt.run.story.ending)

say("== 8. 北塔：女主留灯 ==")
local rc2 = runmod.createRun(20261125, "official")
rc2.story.route = "child"
rc2.story.settled = true
rc2.story.countTick = 1440
rc2.story.hp, rc2.story.maxHp = 2, 3
local pc = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, rc2)
check("女主线塔里控小满", pc.childMode == true, "childMode=" .. tostring(pc.childMode))
check("女主线路线 child", pc.storyRoute == "child", "route=" .. pc.storyRoute)
pc.player.x = pc.ox + 445
tap(it, "interact"); step(pc, it)
step(pc, it, 42)
check("女主线开塔门", pc.phase == "tower-enter" and pc.towerDoorOpen, "phase=" .. pc.phase)
pc.player.x = pc.ox + 605; pc.player.y = 0
it.interact.held = true
step(pc, it, 40)
it.interact.held = false
check("女主线桌前交物", pc.phase == "tower-given" and pc.towerHanded, "phase=" .. pc.phase)
step(pc, it, 180)
check("女主线结局留灯", pc.run.story.ending == "lamp", "ending=" .. pc.run.story.ending)
check("女主线正式记通关", pc.run.archive.childCleared == true and pc.run.archive.soldierCleared == false,
	"child=" .. tostring(pc.run.archive.childCleared))
check("女主线单通不发神器", pc.run.archive.artifactOwned == false, "artifact=" .. tostring(pc.run.archive.artifactOwned))
check("女主线第二行留白", pc.endingLines[1] == "小满" and pc.endingLines[2] == "",
	"lines=" .. tostring(pc.endingLines[1]) .. "/" .. tostring(pc.endingLines[2]))
local lampEvents = 0
for _, ev in ipairs(pc.events) do if ev.name == "endingReached" then lampEvents = lampEvents + 1 end end
check("留灯落幕一次", lampEvents == 1, "count=" .. lampEvents)

say("== 9. 章节直达与试炼隔离 ==")
local rj = runmod.createRun(20261125, "chapter")
local pj = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, rj)
check("章节直达默认儿童路线", pj.childMode == true and pj.storyRoute == "", "route=" .. pj.storyRoute)
pj.player.x = pj.ox + 445
tap(it, "interact"); step(pj, it)
step(pj, it, 42)
pj.player.x = pj.ox + 605; pj.player.y = 0
it.interact.held = true
step(pj, it, 40)
it.interact.held = false
step(pj, it, 180)
check("章节直达也能预览落幕", pj.run.story.ending == "lamp", "ending=" .. pj.run.story.ending)
check("章节直达不记正式通关", pj.run.archive.childCleared == false and pj.run.archive.soldierCleared == false,
	"child=" .. tostring(pj.run.archive.childCleared))
local pjEvents = 0
local pjOfficial = true
for _, ev in ipairs(pj.events) do
	if ev.name == "endingReached" then
		pjEvents = pjEvents + 1
		pjOfficial = ev.data.official == true
	end
end
check("章节直达落幕事件标非正式", pjEvents == 1 and pjOfficial == false, "count=" .. pjEvents .. " official=" .. tostring(pjOfficial))
local escRun = runmod.createRun(67543212, "official")
escRun.story.route = "soldier"
escRun.story.settled = true
local pEsc = lualib.__TS__New(play.Play, rooms.ESCORT1_ROOM, nil, escRun)
check("男主肉鸽未到北塔不写结局", pEsc.run.story.ending == "", "ending=" .. pEsc.run.story.ending)
check("男主肉鸽保留局种子", pEsc.run.seed == 67543212, "seed=" .. tostring(pEsc.run.seed))
check("男主肉鸽进段三选一", #pEsc:getStoryTalentOffers() == 3,
	"offers=" .. tostring(#pEsc:getStoryTalentOffers()))

local ra = runmod.createRun(20261125, "official")
ra.story.route = "soldier"
ra.story.settled = true
ra.story.segments["escort5"] = true
ra.archive.artifactOwned = true
local pa = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, ra)
pa.player.x = pa.ox + 445
tap(it, "interact"); step(pa, it)
step(pa, it, 42)
pa.player.x = pa.ox + 605; pa.player.y = 0
it.interact.held = true
step(pa, it, 40)
it.interact.held = false
step(pa, it, 180)
check("已有真实神器保持 true", pa.run.archive.artifactOwned == true, "artifact=" .. tostring(pa.run.archive.artifactOwned))
check("已有档案仍记通关", pa.run.archive.soldierCleared == true, "soldier=" .. tostring(pa.run.archive.soldierCleared))

say("== 10. 同种子同输入复现 ==")
local function runSame(seed)
	local rr = runmod.createRun(seed)
	local pp = lualib.__TS__New(play.Play, rooms.ESCORT4_ROOM, nil, rr)
	local ii = newInput()
	pp.player.x = 200
	ii.moveX = 1
	step(pp, ii, 120)
	return pp
end
local a1 = runSame(20261125)
local a2 = runSame(20261125)
check("同种子同输入位置一致", math.abs(a1.player.x - a2.player.x) < 0.01,
	string.format("%.1f vs %.1f", a1.player.x, a2.player.x))
check("同种子同输入血量一致", a1.hp == a2.hp, a1.hp .. " vs " .. a2.hp)

say("== 11. 女主线 outside 与城外对照 ==")
local ro = runmod.createRun(20261125)
ro.story.route = "child"
ro.story.settled = true
ro.story.hp, ro.story.maxHp = 2, 3
local po = lualib.__TS__New(play.Play, rooms.OUTSIDE_ROOM, nil, ro)
check("女主线城外控小满", po.childMode == true, "childMode=" .. tostring(po.childMode))
check("女主线不背人", po.carryOn == false, "carry=" .. tostring(po.carryOn))
check("女主线继承血量", po.hp == 2 and po.maxHp == 3, "hp=" .. po.hp .. "/" .. po.maxHp)

say(string.format("D-B2 五段护送与北塔团圆：%d 通过 / %d 失败", PASS, FAIL))
assert(FAIL == 0, "D-B2 回归失败")
