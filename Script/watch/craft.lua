-- [ts]: craft.ts
local ____exports = {} -- 1
--- 本轮唯一的两张配方：木纹筹两枚 / 木纹筹一枚 + 铃纹筹一枚。
____exports.CRAFT_RECIPES = {{ -- 25
	id = "guide_lantern_gun", -- 27
	name = "引路灯铳", -- 28
	desc = "两枚木纹筹改制；灯纹照亮更远，命中后余明不散，能照穿一道薄掩体", -- 29
	enhancedEffect = "light", -- 30
	cost = {wood = 2} -- 31
}, { -- 31
	id = "echo_gun", -- 34
	name = "回声铳", -- 35
	desc = "一枚木纹筹与一枚铃纹筹改制；铃纹回声一次惊起两处声源", -- 36
	enhancedEffect = "echo", -- 37
	cost = {wood = 1, bell = 1} -- 38
}} -- 38
function ____exports.findRecipe(id) -- 42
	local i = 0 -- 43
	do -- 43
		i = 0 -- 44
		while i < #____exports.CRAFT_RECIPES do -- 44
			if ____exports.CRAFT_RECIPES[i + 1].id == id then -- 44
				return ____exports.CRAFT_RECIPES[i + 1] -- 46
			end -- 46
			i = i + 1 -- 44
		end -- 44
	end -- 44
	return nil -- 49
end -- 42
--- 配方还差哪些材料；空数组表示可以做。
function ____exports.missingMaterials(inv, recipe) -- 53
	local missing = {} -- 54
	if recipe.cost.wood ~= nil and inv.wood < recipe.cost.wood then -- 54
		missing[#missing + 1] = "木纹筹 " .. tostring(recipe.cost.wood - inv.wood) -- 56
	end -- 56
	if recipe.cost.bell ~= nil and inv.bell < recipe.cost.bell then -- 56
		missing[#missing + 1] = "铃纹筹 " .. tostring(recipe.cost.bell - inv.bell) -- 59
	end -- 59
	return missing -- 61
end -- 53
--- 扣一份配方材料；材料不足时不扣任何东西。
function ____exports.payMaterials(inv, recipe) -- 65
	if #____exports.missingMaterials(inv, recipe) > 0 then -- 65
		return false -- 67
	end -- 67
	if recipe.cost.wood ~= nil then -- 67
		inv.wood = inv.wood - recipe.cost.wood -- 70
	end -- 70
	if recipe.cost.bell ~= nil then -- 70
		inv.bell = inv.bell - recipe.cost.bell -- 73
	end -- 73
	return true -- 75
end -- 65
function ____exports.weaponEffectOf(weapon) -- 78
	if weapon == "guide_lantern_gun" then -- 78
		return "light" -- 80
	end -- 80
	if weapon == "echo_gun" then -- 80
		return "echo" -- 83
	end -- 83
	return "" -- 85
end -- 78
function ____exports.weaponNameOf(weapon) -- 88
	local recipe = ____exports.findRecipe(weapon) -- 89
	return recipe == nil and "标准铳" or recipe.name -- 90
end -- 88
--- 材料与武器的一句话读数，给 HUD / 回放日志用。
function ____exports.craftSnapshotText(inv, weapon, crafted) -- 94
	return ((((("木 " .. tostring(inv.wood)) .. " · 铃 ") .. tostring(inv.bell)) .. " · 装备 ") .. ____exports.weaponNameOf(weapon)) .. (crafted == "" and " · 未改制" or " · 已改制 " .. ____exports.weaponNameOf(crafted)) -- 95
end -- 94
return ____exports -- 94