-- [ts]: reload.ts
local ____exports = {} -- 1
--- 3×3 盘：左下为起点 0，右下为枪机复位点 8；中心 4 是铃纹，右上 2 是灯纹。
____exports.RELOAD_NODES = { -- 21
	{id = 0, x = 0, y = 0, kind = "plain"}, -- 22
	{id = 1, x = 1, y = 0, kind = "plain"}, -- 23
	{id = 2, x = 2, y = 0, kind = "lamp"}, -- 24
	{id = 3, x = 0, y = 1, kind = "plain"}, -- 25
	{id = 4, x = 1, y = 1, kind = "bell"}, -- 26
	{id = 5, x = 2, y = 1, kind = "plain"}, -- 27
	{id = 6, x = 0, y = 2, kind = "plain"}, -- 28
	{id = 7, x = 1, y = 2, kind = "plain"}, -- 29
	{id = 8, x = 2, y = 2, kind = "plain"} -- 30
} -- 30
--- 玩家从这里落第一笔。
____exports.RELOAD_START = 0 -- 34
--- 枪机复位点：连到这里才算画完。
____exports.RELOAD_TARGET = 8 -- 36
--- 作答预算：240 个有效作答拍 = 60 个世界拍 = 4 秒。
____exports.RELOAD_ANSWER_TICKS = 240 -- 38
--- 盘开着时世界每 4 拍只推进 1 拍。
____exports.RELOAD_ANSWER_PER_WORLD = 4 -- 40
--- 只连相邻点（含斜角），不跳格。
function ____exports.reloadAdjacent(a, b) -- 43
	if a == b then -- 43
		return false -- 45
	end -- 45
	local na = ____exports.RELOAD_NODES[a + 1] -- 47
	local nb = ____exports.RELOAD_NODES[b + 1] -- 48
	if na == nil or nb == nil then -- 48
		return false -- 50
	end -- 50
	return math.abs(na.x - nb.x) <= 1 and math.abs(na.y - nb.y) <= 1 -- 52
end -- 43
--- 路径合法：从 0 起、每步相邻、不重复、末点是 8。
function ____exports.reloadPathValid(path) -- 56
	if #path < 2 then -- 56
		return false -- 58
	end -- 58
	if path[1] ~= ____exports.RELOAD_START then -- 58
		return false -- 61
	end -- 61
	if path[#path] ~= ____exports.RELOAD_TARGET then -- 61
		return false -- 64
	end -- 64
	local seen = {} -- 66
	local i = 0 -- 67
	do -- 67
		i = 0 -- 68
		while i < #path do -- 68
			local n = path[i + 1] -- 69
			if n < 0 or n >= #____exports.RELOAD_NODES or seen[n + 1] == true then -- 69
				return false -- 71
			end -- 71
			seen[n + 1] = true -- 73
			if i > 0 and not ____exports.reloadAdjacent(path[i], n) then -- 73
				return false -- 75
			end -- 75
			i = i + 1 -- 68
		end -- 68
	end -- 68
	return true -- 78
end -- 56
--- 路径经过铃纹就给回声，经过灯纹就给照明；都没有就是普通推退。
function ____exports.reloadEffectOf(path) -- 82
	if not ____exports.reloadPathValid(path) then -- 82
		return "" -- 84
	end -- 84
	local bell = false -- 86
	local lamp = false -- 87
	local i = 0 -- 88
	do -- 88
		i = 0 -- 89
		while i < #path do -- 89
			do -- 89
				local node = ____exports.RELOAD_NODES[path[i + 1] + 1] -- 90
				if node == nil then -- 90
					goto __continue16 -- 92
				end -- 92
				if node.kind == "bell" then -- 92
					bell = true -- 95
				end -- 95
				if node.kind == "lamp" then -- 95
					lamp = true -- 98
				end -- 98
			end -- 98
			::__continue16:: -- 98
			i = i + 1 -- 89
		end -- 89
	end -- 89
	if bell then -- 89
		return "echo" -- 102
	end -- 102
	if lamp then -- 102
		return "light" -- 105
	end -- 105
	return "push" -- 107
end -- 82
--- 效果的短名，给 HUD 与一次性事件用。
function ____exports.reloadEffectName(e) -- 111
	if e == "push" then -- 111
		return "推退" -- 113
	end -- 113
	if e == "echo" then -- 113
		return "回声·引到声源" -- 116
	end -- 116
	if e == "light" then -- 116
		return "照明·照亮遮蔽" -- 119
	end -- 119
	return "普通" -- 121
end -- 111
return ____exports -- 111