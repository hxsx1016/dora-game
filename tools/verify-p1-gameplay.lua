-- PR 4 验收：后端 P1 玩法补齐（空村三材质声学、城外红布车 F01 回忆、密林双路差异、溪湾镜头）+ 全量 submitFeIntent 契约
local Dora = require("Dora")
local new = require("lualib_bundle").__TS__New
local rooms = require("Script.watch.rooms")
local playmod = require("Script.watch.play")
local runmod = require("Script.watch.run")
local inputmod = require("Script.watch.input")
local Frontend = require("Script.watch.fe.frontend").WatchFrontend

local pass, fail = 0, 0
local function check(tag, cond, detail)
	if cond then
		pass = pass + 1
		print(string.format("PASS p1: %-46s %s", tag, detail or ""))
	else
		fail = fail + 1
		print(string.format("FAIL p1: %-46s %s", tag, detail or ""))
	end
end

local function newInput()
	local i = new(inputmod.Input)
	i.moveX, i.moveY = 0, 0
	for _, k in ipairs({ "jump", "crouch", "cover", "interact", "aim", "fire", "flare", "pause", "retry", "toggleView", "tab" }) do
		i[k] = { held = false, pressed = false, released = false }
	end
	return i
end

local function throwTo(p, i, targetX)
	p.player.x = p.ox + 160
	p.player.y = 0
	p.hasBottle = true
	p:aimAt(p.ox + targetX, 0)
	for _ = 1, 6 do p:update(playmod.STEP, i) end
	p.hasBottle = true
	p:aimAt(p.ox + targetX, 0)
	i.aim.held = true
	for _ = 1, 10 do p:update(playmod.STEP, i) end
	i.aim.held = false
	i.aim.released = true
	p:update(playmod.STEP, i)
	i.aim.released = false
	local guard = 0
	while p.bottleFly ~= nil and guard < 120 do
		p:update(playmod.STEP, i)
		guard = guard + 1
	end
	local ev = nil
	for _, e in ipairs(p.events) do
		if e.name == "bottleLanded" then ev = e end
	end
	p:drainEvents()
	return ev
end

-- 1. 空村三材质投瓶声学：软土消音 / 砖地常规 / 铁盆余振加长驻留
do
	-- 1.1 软土 272：heard=false, surface="soft", 拾荒者保持 patrol
	local pSoft = new(playmod.Play, rooms.VILLAGE_ROOM)
	local i = newInput()
	local evSoft = throwTo(pSoft, i, 272)
	check("1.1 空村软土落点消音不惊动拾荒者",
		evSoft ~= nil and evSoft.data.surface == "soft" and evSoft.data.heard == false and pSoft.scavState == "patrol",
		evSoft and string.format("surface=%s heard=%s state=%s", tostring(evSoft.data.surface), tostring(evSoft.data.heard), pSoft.scavState) or "nil")

	-- 1.2 砖地 608：heard=true, surface="brick", stallTicks=120
	local pBrick = new(playmod.Play, rooms.VILLAGE_ROOM)
	local evBrick = throwTo(pBrick, i, 608)
	check("1.2 空村砖地落点单响常规驻留 120 拍",
		evBrick ~= nil and evBrick.data.surface == "brick" and evBrick.data.heard == true
		and evBrick.data.stallTicks == 120 and pBrick.scavState == "turn",
		evBrick and string.format("surface=%s stall=%s state=%s", tostring(evBrick.data.surface), tostring(evBrick.data.stallTicks), pBrick.scavState) or "nil")

	-- 1.3 铁盆 548：heard=true, surface="iron", resonance=true, stallTicks=210, 实际走到铁盆后驻留 > 150 拍
	local pIron = new(playmod.Play, rooms.VILLAGE_ROOM)
	local evIron = throwTo(pIron, i, 548)
	local enteredStall = false
	local stallTickAtEnter = 0
	for _ = 1, 200 do
		pIron:update(playmod.STEP, i)
		if pIron.scavState == "stall" then
			enteredStall = true
			stallTickAtEnter = pIron.scavT
			break
		end
	end
	check("1.3 空村铁盆落点余振两响并延长拾荒者驻留至 210 拍",
		evIron ~= nil and evIron.data.surface == "iron" and evIron.data.resonance == true
		and evIron.data.heard == true and enteredStall and stallTickAtEnter >= 205,
		string.format("surface=%s stall=%d entered=%s", evIron and tostring(evIron.data.surface) or "nil", stallTickAtEnter, tostring(enteredStall)))
end

-- 2. 城外红布车 F01 家庭回忆节拍与跨房快照
do
	local r = runmod.createRun(20261124, "official", runmod.createArchive())
	r.story.route = "child"; r.story.settled = true
	local p = new(playmod.Play, rooms.OUTSIDE_ROOM, nil, r)
	local i = newInput()
	p.player.x = 148; p.player.y = 96
	i.interact.pressed = true; i.interact.held = true
	p:update(playmod.STEP, i)
	i.interact.pressed = false; i.interact.held = false
	local hasMemBeat = false
	for _, e in ipairs(p.events) do
		if e.name == "storyBeat" and e.data.beat == "red_cart_memory" then hasMemBeat = true end
	end
	check("2.1 城外拉开红布车触发 F01 半秒家庭回忆节拍",
		hasMemBeat and p.redCartMemoryT == 30 and r.story.segments["outside_memory"] == true,
		string.format("beat=%s memT=%d", tostring(hasMemBeat), p.redCartMemoryT))
end

-- 3. 密林双路实质差异（窄洞隐蔽庇护 vs 旧渠提速高警戒）+ 溪湾水光镜头联动
do
	-- 3.1 树根窄洞蹲伏打断犬只警戒/追击
	local pf1 = new(playmod.Play, rooms.FOREST_ROOM)
	local i = newInput()
	pf1.player.x = pf1.ox + 340
	pf1.dogX = pf1.ox + 390
	pf1.dogState = "chase"
	i.crouch.held = true
	pf1:update(playmod.STEP, i)
	check("3.1 树根窄洞蹲伏提供隐蔽庇护立即摆脱猎犬追击",
		pf1.dogState == "sniff" and pf1.forestPath == "burrow",
		string.format("dogState=%s path=%s", pf1.dogState, pf1.forestPath))

	-- 3.2 旧渠站跑提速 22%（160 -> ~195 px/s）且犬只转耳加速至 12 拍
	local pf2 = new(playmod.Play, rooms.FOREST_ROOM)
	local i2 = newInput()
	pf2.player.x = pf2.ox + 740
	pf2.dogX = pf2.ox + 900
	i2.moveX = 1
	pf2:update(playmod.STEP, i2)
	pf2:update(playmod.STEP, i2)
	local ditchSpeed = math.abs(pf2.player.vx)
	check("3.2 旧渠站跑提速 22% 且触发高警戒 12 拍转耳",
		pf2.forestPath == "ditch" and ditchSpeed > 185 and pf2.dogState == "ear" and pf2.dogT <= 12,
		string.format("path=%s vx=%.1f dogState=%s dogT=%d", pf2.forestPath, ditchSpeed, pf2.dogState, pf2.dogT))

	-- 3.3 溪湾水光镜头聚焦（1160..1280 zoom 趋近 1.12）
	local root = Dora.Node()
	local fe = new(Frontend, root)
	fe.screen = "play"
	fe:bindPlay(pf2, 1280, 720)
	pf2.player.x = pf2.ox + 1220
	for _ = 1, 25 do
		fe:renderPlay(playmod.STEP, pf2, i2, 1280, 720)
	end
	check("3.3 溪湾初见水面灯镜头平滑推近聚焦", fe.cam.zoom > 1.07, string.format("zoom=%.3f", fe.cam.zoom))
	root:cleanup()
end

-- 4. 全量 submitFeIntent 契约：gateReunionHold / reloadOpen / reloadPathPreview / museumInteract
do
	local i = newInput()
	-- 4.1 gateReunionHold 驱动风台 36 拍牵手
	local rG = runmod.createRun(20261124, "official", runmod.createArchive())
	rG.story.route = "soldier"; rG.story.settled = true; rG.story.hp = 3; rG.story.maxHp = 3
	rG.story.hpAtGate = 3; rG.story.maxHpAtGate = 3; rG.story.phase = "gate-wait"; rG.story.countTick = 1440
	local pG = new(playmod.Play, rooms.GATE_ROOM, nil, rG)
	pG:update(playmod.STEP, i) -- arm handArmed
	check("4.1a submitFeIntent(gateReunionHold:true) 被接受", pG:submitFeIntent({ kind = "gateReunionHold", holding = true }) == true)
	for _ = 1, 36 do pG:update(playmod.STEP, i) end
	check("4.1b gateReunionHold 满 36 拍触发牵手进入 gate-hand",
		pG.phase == "gate-hand" and pG.handDone == true and pG.tied == true,
		string.format("phase=%s handTicks=%d", pG.phase, pG.handTicks))

	-- 4.2 reloadOpen & reloadPathPreview
	local rR = runmod.createRun(20261124, "official", runmod.createArchive())
	rR.story.route = "soldier"; rR.story.settled = true
	local pR = new(playmod.Play, rooms.ESCORT1_ROOM, nil, rR)
	check("4.2 submitFeIntent(reloadOpen + reloadPathPreview) 闭环生效",
		pR:submitFeIntent({ kind = "reloadOpen" }) == true
		and pR.reloadOpen == true
		and pR:submitFeIntent({ kind = "reloadPathPreview", path = { 0, 1, 2, 5, 8 } }) == true)

	-- 4.3 museumInteract 全步骤（cabinet -> hall -> lamp -> return_cabinet -> prologue）
	local arch = { childCleared = true, soldierCleared = true, artifactOwned = true, museumPhase = "well_reflect", museumSeen = false }
	local rM = runmod.createRun(20261124, "official", arch)
	local pM = new(playmod.Play, rooms.MUSEUM_ROOM, nil, rM)
	pM.player.x = pM.ox + 200
	local ok1 = pM:submitFeIntent({ kind = "museumInteract", target = "cabinet" })
	pM:update(playmod.STEP, i)
	pM.player.x = pM.ox + 920
	local ok2 = pM:submitFeIntent({ kind = "museumInteract", target = "hall" })
	pM:update(playmod.STEP, i)
	pM.player.x = pM.ox + 1260
	local ok3 = pM:submitFeIntent({ kind = "museumInteract", target = "lamp" })
	pM:update(playmod.STEP, i)
	pM.player.x = pM.ox + 200
	local ok4 = pM:submitFeIntent({ kind = "museumInteract", target = "return_cabinet" })
	for _ = 1, 40 do pM:update(playmod.STEP, i) end
	local ok5 = pM:submitFeIntent({ kind = "museumInteract", target = "return_cabinet" })
	pM:update(playmod.STEP, i)
	check("4.3 submitFeIntent(museumInteract) 跑通博物馆全 5 步并回序章",
		ok1 and ok2 and ok3 and ok4 and ok5 and pM.wantRoom == "prologue" and arch.museumSeen == true,
		string.format("oks=%s/%s/%s/%s/%s want=%s seen=%s", tostring(ok1), tostring(ok2), tostring(ok3), tostring(ok4), tostring(ok5), pM.wantRoom, tostring(arch.museumSeen)))
end

print(string.format("P1 GAMEPLAY & INTENTS VERIFY PASS %d / FAIL %d", pass, fail))
assert(fail == 0, "P1 gameplay & intents verification failed")
