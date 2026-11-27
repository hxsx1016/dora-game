-- [ts]: craft.ts
local ____exports = {} -- 1
____exports.ARTIFACT_WEAPON_ID = "time_shuttler" -- 11
--- 本轮唯一的两张配方：木纹筹两枚 / 木纹筹一枚 + 铃纹筹一枚。
____exports.CRAFT_RECIPES = {{ -- 27
	id = "guide_lantern_gun", -- 29
	name = "引路灯铳", -- 30
	desc = "两枚木纹筹改制；灯纹照亮更远，命中后余明不散，能照穿一道薄掩体", -- 31
	enhancedEffect = "light", -- 32
	cost = {wood = 2} -- 33
}, { -- 35
	id = "echo_gun", -- 36
	name = "回声铳", -- 37
	desc = "一枚木纹筹与一枚铃纹筹改制；铃纹回声一次惊起两处声源", -- 38
	enhancedEffect = "echo", -- 39
	cost = {wood = 1, bell = 1} -- 40
}} -- 40
function ____exports.findRecipe(id) -- 44
	local i = 0 -- 45
	do -- 45
		i = 0 -- 46
		while i < #____exports.CRAFT_RECIPES do -- 46
			if ____exports.CRAFT_RECIPES[i + 1].id == id then -- 47
				return ____exports.CRAFT_RECIPES[i + 1] -- 48
			end -- 48
			i = i + 1 -- 46
		end -- 46
	end -- 46
	return nil -- 51
end -- 44
--- 配方还差哪些材料；空数组表示可以做。
function ____exports.missingMaterials(inv, recipe) -- 55
	local missing = {} -- 56
	if recipe.cost.wood ~= nil and inv.wood < recipe.cost.wood then -- 57
		missing[#missing + 1] = "木纹筹 " .. tostring(recipe.cost.wood - inv.wood) -- 58
	end -- 58
	if recipe.cost.bell ~= nil and inv.bell < recipe.cost.bell then -- 60
		missing[#missing + 1] = "铃纹筹 " .. tostring(recipe.cost.bell - inv.bell) -- 61
	end -- 61
	return missing -- 63
end -- 55
--- 扣一份配方材料；材料不足时不扣任何东西。
function ____exports.payMaterials(inv, recipe) -- 67
	if #____exports.missingMaterials(inv, recipe) > 0 then -- 68
		return false -- 69
	end -- 69
	if recipe.cost.wood ~= nil then -- 71
		inv.wood = inv.wood - recipe.cost.wood -- 72
	end -- 72
	if recipe.cost.bell ~= nil then -- 74
		inv.bell = inv.bell - recipe.cost.bell -- 75
	end -- 75
	return true -- 77
end -- 67
function ____exports.weaponEffectOf(weapon) -- 80
	if weapon == "guide_lantern_gun" or weapon == ____exports.ARTIFACT_WEAPON_ID then -- 81
		return "light" -- 82
	end -- 82
	if weapon == "echo_gun" then -- 84
		return "echo" -- 85
	end -- 85
	return "" -- 87
end -- 80
function ____exports.weaponNameOf(weapon) -- 90
	if weapon == ____exports.ARTIFACT_WEAPON_ID then -- 91
		return "时间穿梭器" -- 92
	end -- 92
	local recipe = ____exports.findRecipe(weapon) -- 94
	return recipe == nil and "标准铳" or recipe.name -- 95
end -- 90
--- 材料与武器的一句话读数，给 HUD / 回放日志用。
function ____exports.craftSnapshotText(inv, weapon, crafted) -- 99
	return ((((("木 " .. tostring(inv.wood)) .. " · 铃 ") .. tostring(inv.bell)) .. " · 装备 ") .. ____exports.weaponNameOf(weapon)) .. (crafted == "" and " · 未改制" or " · 已改制 " .. ____exports.weaponNameOf(crafted)) -- 100
end -- 99
return ____exports -- 99
