-- PR 3 验收（1/2）：时间穿梭器后端装备、跨房持久化、工台入口、残影真实激活与北塔男主同行/演出让权
local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local playmod = require("Script.watch.play")
local runmod = require("Script.watch.run")
local craftmod = require("Script.watch.craft")
local inputmod = require("Script.watch.input")
local Frontend = require("Script.watch.fe.frontend").WatchFrontend

local pass, fail = 0, 0
local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS artifact: %-44s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL artifact: %-44s %s", tag, detail or ""))
	end
end

local root = Dora.Node()
local fe = new(Frontend, root)
fe.screen = "play"
local inp = new(inputmod.Input)

-- 1. 未取得神器时拒绝装备 time_shuttler，且工台仍只显示 2 份配方
do
	local r = runmod.createRun(20261124, "official", runmod.createArchive())
	r.story.route = "soldier"; r.story.settled = true
	local p = new(playmod.Play, rooms.ESCORT3_ROOM, nil, r)
	check("1.1 未持神器时拒绝装备 time_shuttler", p:equipWeapon(craftmod.ARTIFACT_WEAPON_ID) == false)
	check("1.2 未持神器时工台保持 2 份原始配方", #p.craftBench.recipes == 2, "count=" .. tostring(#p.craftBench.recipes))
end

-- 2. 双通关且持神器：可装备 time_shuttler，工台展示穿梭器，跨房保留，且驱动真实轨迹残影
do
	local arch = {
		childCleared = true,
		soldierCleared = true,
		artifactOwned = true,
		museumPhase = "done",
		museumSeen = true,
	}
	local r = runmod.createRun(20261124, "official", arch)
	r.story.route = "soldier"; r.story.settled = true; r.story.carry = true
	local p1 = new(playmod.Play, rooms.ESCORT1_ROOM, nil, r)
	p1.enemies = {}
	check("2.1 持神器时工台视图包含时间穿梭器", #p1.craftBench.recipes == 3, "count=" .. tostring(#p1.craftBench.recipes))
	check("2.2 持神器时 equipWeapon(time_shuttler) 成功",
		p1:equipWeapon(craftmod.ARTIFACT_WEAPON_ID) == true
		and p1.equippedWeapon == craftmod.ARTIFACT_WEAPON_ID
		and r.story.equippedWeapon == craftmod.ARTIFACT_WEAPON_ID)

	fe:bindPlay(p1, 1280, 720)
	if #p1:getStoryTalentOffers() > 0 then p1:chooseTalent(0) end
	local aft = fe:getPlugin("fe-06-afterimage-artifact")
	inp.moveX = 1
	for _ = 1, 24 do
		p1:update(playmod.STEP, inp)
		fe:renderPlay(playmod.STEP, p1, inp, 1280, 720)
	end
	inp.moveX = 0
	local st = aft:getDebugState()
	check("2.3 正式男主线装备穿梭器后真实产生轨迹残影（无 override）",
		st.active == true and st.equipped == true and st.equippedWeapon == "time_shuttler" and st.totalSpawned >= 2,
		string.format("active=%s eq=%s spawned=%d", tostring(st.active), tostring(st.equipped), st.totalSpawned))

	-- 跨房保留装备
	local p2 = new(playmod.Play, rooms.ESCORT2_ROOM, nil, r)
	check("2.4 跨房 escort1->escort2 自动保留穿梭器装备", p2.equippedWeapon == craftmod.ARTIFACT_WEAPON_ID)

	-- 快捷切换关闭穿梭器回到标准铳
	check("2.5 toggleArtifactWeapon 切回标准铳",
		p2:toggleArtifactWeapon() == true and p2.equippedWeapon == "standard_gun")
	check("2.6 toggleArtifactWeapon 再次切回穿梭器",
		p2:toggleArtifactWeapon() == true and p2.equippedWeapon == craftmod.ARTIFACT_WEAPON_ID)
end

-- 3. 北塔团圆线周戍随行 + tower-enter/tower-desk 过场不遮挡 + storyBeat 音效消费
do
	local r = runmod.createRun(20261124, "official", runmod.createArchive())
	r.story.route = "soldier"; r.story.settled = true; r.story.segments["escort5"] = true
	local pt = new(playmod.Play, rooms.TOWER_ROOM, nil, r)
	fe:bindPlay(pt, 1280, 720)
	local towerPlugin = fe:getPlugin("fe-05-tower-endings")
	check("3.1 男主线进北塔周戍控场且小满并肩同伴（无双周戍）",
		pt.childMode == false and pt.player.w > 28 and pt.partner.alive == true and pt.partner.w <= 28,
		string.format("childMode=%s playerW=%.0f partnerAlive=%s partnerW=%.0f",
			tostring(pt.childMode), pt.player.w, tostring(pt.partner.alive), pt.partner.w))

	-- 敲门 -> 门开进 tower-enter：周戍随后跟进，全屏过场让权（active == false）
	pt.player.x = pt.ox + 445
	inp.interact.pressed = true; inp.interact.held = true
	pt:update(playmod.STEP, inp)
	fe:renderPlay(playmod.STEP, pt, inp, 1280, 720)
	inp.interact.pressed = false; inp.interact.held = false
	for _ = 1, 38 do
		pt:update(playmod.STEP, inp)
		fe:renderPlay(playmod.STEP, pt, inp, 1280, 720)
	end
	local stEnter = towerPlugin:getDebugState()
	check("3.2 tower-enter 阶段过场让出画面，玩家可自由跨门槛",
		pt.phase == "tower-enter" and stEnter.doorOpened == true and stEnter.active == false,
		string.format("phase=%s open=%s active=%s", pt.phase, tostring(stEnter.doorOpened), tostring(stEnter.active)))

	-- 跨门槛走到桌前：周戍随行进入值夜室
	inp.moveX = 1
	for _ = 1, 90 do
		pt:update(playmod.STEP, inp)
		fe:renderPlay(playmod.STEP, pt, inp, 1280, 720)
		if pt.player.x >= pt.ox + 545 then break end
	end
	inp.moveX = 0
	for _ = 1, 30 do
		pt:update(playmod.STEP, inp)
		fe:renderPlay(playmod.STEP, pt, inp, 1280, 720)
	end
	check("3.3 男主线跨门槛进值夜室后周戍站在小满身侧",
		pt.phase == "tower-desk" and pt.partner.x > pt.ox + 490,
		string.format("phase=%s px=%.0f partnerX=%.0f", pt.phase, pt.player.x - pt.ox, pt.partner.x - pt.ox))

	-- 长按 E 交物进入 tower-given：过场重新接管并播放 story:tower_handover 音效
	inp.interact.held = true
	for _ = 1, 38 do
		pt:update(playmod.STEP, inp)
		fe:renderPlay(playmod.STEP, pt, inp, 1280, 720)
	end
	inp.interact.held = false
	local stGiven = towerPlugin:getDebugState()
	local hasHandoverAudio = false
	for _, entry in ipairs(fe.audio:getPlayLog()) do
		if entry.cueId == "story:tower_handover" then hasHandoverAudio = true end
	end
	check("3.4 桌前交物后过场接管且触发 storyBeat 音效",
		pt.phase == "tower-given" and stGiven.active == true and hasHandoverAudio,
		string.format("phase=%s active=%s audio=%s", pt.phase, tostring(stGiven.active), tostring(hasHandoverAudio)))
end

root:cleanup()
print(string.format("ARTIFACT & TOWER VERIFY PASS %d / FAIL %d", pass, fail))
assert(fail == 0, "artifact & tower verification failed")
