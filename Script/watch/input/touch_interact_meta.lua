-- [ts]: touch_interact_meta.ts
local ____exports = {} -- 1
local ____depth = require("Script.watch.depth") -- 7
local inReachDepth = ____depth.inReachDepth -- 7
function ____exports.deriveInteractActionMeta(p, prompt, cartNearby, cartLatched) -- 12
	if cartNearby then -- 18
		if cartLatched or p.gripping then -- 19
			return { -- 20
				label = "松手", -- 20
				subLabel = "推车中", -- 20
				urgent = false, -- 20
				progress = 0, -- 20
				available = true -- 20
			} -- 20
		end -- 20
		return { -- 22
			label = p.room.key == "outside" and "拉车" or "推车", -- 23
			subLabel = "点按锁定", -- 24
			urgent = true, -- 25
			progress = 0, -- 26
			available = true -- 27
		} -- 27
	end -- 27
	if p.phase == "gate-wait" then -- 31
		local prog = math.max( -- 32
			0, -- 32
			math.min( -- 32
				1, -- 32
				p.handTicks / math.max(1, p.handNeedTicks) -- 32
			) -- 32
		) -- 32
		return { -- 33
			label = "牵手", -- 33
			subLabel = "长按", -- 33
			urgent = true, -- 33
			progress = prog, -- 33
			available = true -- 33
		} -- 33
	end -- 33
	if p.phase == "tower-desk" then -- 35
		local prog = math.max( -- 36
			0, -- 36
			math.min(1, p.deskHold / 36) -- 36
		) -- 36
		return { -- 37
			label = "交物", -- 37
			subLabel = "长按", -- 37
			urgent = true, -- 37
			progress = prog, -- 37
			available = true -- 37
		} -- 37
	end -- 37
	if p.craftT > 0 then -- 39
		return { -- 40
			label = "削楔", -- 40
			subLabel = "长按", -- 40
			urgent = true, -- 40
			progress = math.min(1, p.craftT / 30), -- 40
			available = true -- 40
		} -- 40
	end -- 40
	if prompt ~= nil then -- 43
		local kt = prompt.keyTag -- 44
		if (string.find(kt, "E", nil, true) or 0) - 1 >= 0 then -- 45
			local short = "交互" -- 46
			if (string.find(prompt.label, "指南针", nil, true) or 0) - 1 >= 0 or (string.find(prompt.label, "针套", nil, true) or 0) - 1 >= 0 then -- 47
				short = "递物" -- 47
			elseif (string.find(prompt.label, "安抚", nil, true) or 0) - 1 >= 0 then -- 48
				short = "安抚" -- 48
			elseif (string.find(prompt.label, "守门", nil, true) or 0) - 1 >= 0 then -- 49
				short = "守门" -- 49
			elseif (string.find(prompt.label, "送小满", nil, true) or 0) - 1 >= 0 then -- 50
				short = "送别" -- 50
			elseif (string.find(prompt.label, "工台", nil, true) or 0) - 1 >= 0 then -- 51
				short = "工台" -- 51
			elseif (string.find(prompt.label, "窗板", nil, true) or 0) - 1 >= 0 then -- 52
				short = "窗板" -- 52
			elseif (string.find(prompt.label, "木帘", nil, true) or 0) - 1 >= 0 then -- 53
				short = "木帘" -- 53
			elseif (string.find(prompt.label, "门锁", nil, true) or 0) - 1 >= 0 then -- 54
				short = "抬锁" -- 54
			elseif (string.find(prompt.label, "瓶", nil, true) or 0) - 1 >= 0 then -- 55
				short = "拾瓶" -- 55
			elseif (string.find(prompt.label, "收枪", nil, true) or 0) - 1 >= 0 then -- 56
				short = "收枪" -- 56
			elseif (string.find(prompt.label, "灯", nil, true) or 0) - 1 >= 0 then -- 57
				short = "转灯" -- 57
			elseif (string.find(prompt.label, "敲", nil, true) or 0) - 1 >= 0 then -- 58
				short = "轻敲" -- 58
			end -- 58
			return { -- 59
				label = short, -- 60
				subLabel = (string.find(kt, "按住", nil, true) or 0) - 1 >= 0 and "长按" or nil, -- 61
				urgent = prompt.urgent, -- 62
				progress = prompt.progress or 0, -- 63
				available = true -- 64
			} -- 64
		end -- 64
	end -- 64
	local nearWell = math.abs(p.player.x - (p.ox + p.wellX)) <= 44 and p.player.y < 20 and inReachDepth(p.player.depth, 0) -- 69
	if p.room.key == "prologue" and p.phase == "prologue-wait" and nearWell and (p.wellOpen or p.archive.artifactOwned and not p.archive.museumSeen) then -- 71
		return {label = p.wellOpen and "取器" or "入馆", urgent = true, progress = 0, available = true} -- 73
	end -- 73
	if not p.childMode and p.run.inventory.scrap > 0 and p.run.inventory.wedge < 3 and prompt == nil then -- 81
		return { -- 82
			label = "削楔", -- 82
			subLabel = "长按", -- 82
			urgent = false, -- 82
			progress = 0, -- 82
			available = true -- 82
		} -- 82
	end -- 82
	return {label = "交互", urgent = false, progress = 0, available = false} -- 85
end -- 12
return ____exports -- 12
