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
p2.player.x = 820; p2.player.y = 64; p2.player.depth = -24; p2.player.onGround = true; p2.player.vy = 0
step(p2, i2)
check("棚架上拾第二枚木纹筹", p2.run.inventory.wood == 2, "wood=" .. p2.run.inventory.wood)
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

say("== 4. 试射：灯铳穿掩体、回声惊两处 ==")
local p4 = lualib.__TS__New(play.Play, rooms.ESCORT3_ROOM, nil, r3c)
p4.equippedWeapon = "guide_lantern_gun"
p4:openCraftBench()
p4.craftBench.active = false
-- 站 700 前，掩体 700–756，靶 820：普通枪被掩体挡，灯纹盘照透。
p4.player.x = 690; p4.player.y = 0
p4:aimAt(820, 60)
p4.reloadPendingEffect = "light"
local i4 = newInput()
p4:shoot(p4.player)
check("灯纹一枪穿掩体命中", p4.enemies[1].hitT > 0,
	"hitT=" .. p4.enemies[1].hitT .. " alive=" .. tostring(p4.enemies[1].alive))
check("灯纹效果已消费", p4.reloadPendingEffect == "", "pending=" .. p4.reloadPendingEffect)
-- 第二发普通：掩体挡下
step(p4, i4, 60)
p4:aimAt(820, 60)
p4:shoot(p4.player)
check("第二发普通被掩体挡", p4.enemies[1].alive == false or p4.enemies[1].hitT <= 0,
	"alive=" .. tostring(p4.enemies[1].alive))
-- 回声铳：两处声源
local p5 = lualib.__TS__New(play.Play, rooms.ESCORT4_ROOM, nil, runmod.createRun(20261125))
p5.equippedWeapon = "echo_gun"
p5.reloadPendingEffect = "echo"
p5.player.x = 620
p5:aimAt(840, 60)
p5:shoot(p5.player)
local woke = 0
for _, e in ipairs(p5.enemies) do if e.awake then woke = woke + 1 end end
check("回声铳惊起两处声源", woke >= 2, "awake=" .. woke)

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
p8.hp = 0
p8:campaignFailed()
check("失败重开仍是 soldier", p8.run.story.route == "soldier", "route=" .. p8.run.story.route)
check("失败重开回本段起点", p8.player.x <= p8.room.minX + 100, "x=" .. string.format("%.1f", p8.player.x))
check("失败清空装填盘", p8.reloadOpen == false, "open=" .. tostring(p8.reloadOpen))

say("== 7. 北塔：男主团圆 ==")
local rt = runmod.createRun(20261125)
rt.story.route = "soldier"
rt.story.settled = true
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
check("开塔门", pt.phase == "tower-given", "phase=" .. pt.phase)
step(pt, it, 180)
check("男主线结局团圆", pt.phase == "tower-end" and pt.run.story.ending == "reunion",
	"phase=" .. pt.phase .. " ending=" .. pt.run.story.ending)
check("男主线记通关", pt.run.archive.soldierCleared == true and pt.run.archive.childCleared == false,
	"soldier=" .. tostring(pt.run.archive.soldierCleared) .. " child=" .. tostring(pt.run.archive.childCleared))
check("落幕事件只一次", #pt.events >= 1 and pt.run.finished == true, "finished=" .. tostring(pt.run.finished))
local endEvents = 0
for _, ev in ipairs(pt.events) do if ev.name == "endingReached" then endEvents = endEvents + 1 end end
check("endingReached 恰一次", endEvents == 1, "count=" .. endEvents)
tap(it, "interact"); step(pt, it)
check("片尾 E 再玩回序章", pt.wantRoom == "prologue", "wantRoom=" .. pt.wantRoom)
check("再玩不改结局", pt.run.story.ending == "reunion", "ending=" .. pt.run.story.ending)

say("== 8. 北塔：女主留灯 ==")
local rc2 = runmod.createRun(20261125)
rc2.story.route = "child"
rc2.story.settled = true
rc2.story.hp, rc2.story.maxHp = 2, 3
local pc = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, rc2)
check("女主线塔里控小满", pc.childMode == true, "childMode=" .. tostring(pc.childMode))
check("女主线路线 child", pc.storyRoute == "child", "route=" .. pc.storyRoute)
pc.player.x = pc.ox + 445
tap(it, "interact"); step(pc, it)
step(pc, it, 42)
check("女主线开塔门", pc.phase == "tower-given", "phase=" .. pc.phase)
step(pc, it, 180)
check("女主线结局留灯", pc.run.story.ending == "lamp", "ending=" .. pc.run.story.ending)
check("女主线记通关", pc.run.archive.childCleared == true and pc.run.archive.soldierCleared == false,
	"child=" .. tostring(pc.run.archive.childCleared))
local lampEvents = 0
for _, ev in ipairs(pc.events) do if ev.name == "endingReached" then lampEvents = lampEvents + 1 end end
check("留灯落幕一次", lampEvents == 1, "count=" .. lampEvents)

say("== 9. 章节直达与试炼隔离 ==")
local rj = runmod.createRun(20261125)
local pj = lualib.__TS__New(play.Play, rooms.TOWER_ROOM, nil, rj)
check("章节直达默认儿童路线", pj.childMode == true and pj.storyRoute == "", "route=" .. pj.storyRoute)
pj.player.x = pj.ox + 445
tap(it, "interact"); step(pj, it)
step(pj, it, 42)
step(pj, it, 180)
check("章节直达也能落幕", pj.run.story.ending == "lamp", "ending=" .. pj.run.story.ending)
local trialRun = runmod.createTrial(67543212)
local ptrl = lualib.__TS__New(play.Play, rooms.S1_CROSSROAD, nil, trialRun)
check("试炼不走正式结局字段", ptrl.run.story.ending == "", "ending=" .. ptrl.run.story.ending)
check("试炼有种子", ptrl.run.seed == 67543212, "seed=" .. tostring(ptrl.run.seed))
check("试炼开局三选一", ptrl.run.trial ~= nil and #ptrl.run.trial.offers == 3,
	"offers=" .. tostring(ptrl.run.trial and #ptrl.run.trial.offers))

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
