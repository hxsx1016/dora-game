/**
 * 第三段安全工台的武器改制。
 *
 * 后端保有盘面规则、可用配方、扣料、装备与射击增益的唯一状态；
 * 前端只领取选择与表现。配方两项在本轮固定：引路灯铳（两木）、回声铳（一木一铃）。
 * 材料不占消耗品格，走 run.inventory 的 wood / bell 两个计数。
 */

import { Inventory } from "Script/watch/run";

export const ARTIFACT_WEAPON_ID = "time_shuttler";

export type WeaponId = "standard_gun" | "guide_lantern_gun" | "echo_gun" | "time_shuttler";

/** 改制武器在射击结算里的增益类别；空串表示标准铳。 */
export type WeaponEffect = "light" | "echo" | "";

export interface RecipeSpec {
    id: WeaponId;
    name: string;
    desc: string;
    enhancedEffect: "light" | "echo";
    cost: { wood?: number; bell?: number };
}

/** 本轮唯一的两张配方：木纹筹两枚 / 木纹筹一枚 + 铃纹筹一枚。 */
export const CRAFT_RECIPES: RecipeSpec[] = [
    {
        id: "guide_lantern_gun",
        name: "引路灯铳",
        desc: "两枚木纹筹改制；灯纹照亮更远，命中后余明不散，能照穿一道薄掩体",
        enhancedEffect: "light",
        cost: { wood: 2 },
    },
    {
        id: "echo_gun",
        name: "回声铳",
        desc: "一枚木纹筹与一枚铃纹筹改制；铃纹回声一次惊起两处声源",
        enhancedEffect: "echo",
        cost: { wood: 1, bell: 1 },
    },
];

export function findRecipe(id: string): RecipeSpec | undefined {
    let i = 0;
    for (i = 0; i < CRAFT_RECIPES.length; i++) {
        if (CRAFT_RECIPES[i].id === id) {
            return CRAFT_RECIPES[i];
        }
    }
    return undefined;
}

/** 配方还差哪些材料；空数组表示可以做。 */
export function missingMaterials(inv: Inventory, recipe: RecipeSpec): string[] {
    const missing: string[] = [];
    if (recipe.cost.wood !== undefined && inv.wood < recipe.cost.wood) {
        missing.push("木纹筹 " + (recipe.cost.wood - inv.wood));
    }
    if (recipe.cost.bell !== undefined && inv.bell < recipe.cost.bell) {
        missing.push("铃纹筹 " + (recipe.cost.bell - inv.bell));
    }
    return missing;
}

/** 扣一份配方材料；材料不足时不扣任何东西。 */
export function payMaterials(inv: Inventory, recipe: RecipeSpec): boolean {
    if (missingMaterials(inv, recipe).length > 0) {
        return false;
    }
    if (recipe.cost.wood !== undefined) {
        inv.wood -= recipe.cost.wood;
    }
    if (recipe.cost.bell !== undefined) {
        inv.bell -= recipe.cost.bell;
    }
    return true;
}

export function weaponEffectOf(weapon: string): WeaponEffect {
    if (weapon === "guide_lantern_gun") {
        return "light";
    }
    if (weapon === "echo_gun") {
        return "echo";
    }
    return "";
}

export function weaponNameOf(weapon: string): string {
    if (weapon === ARTIFACT_WEAPON_ID) {
        return "时间穿梭器";
    }
    const recipe = findRecipe(weapon);
    return recipe === undefined ? "标准铳" : recipe.name;
}

/** 材料与武器的一句话读数，给 HUD / 回放日志用。 */
export function craftSnapshotText(inv: Inventory, weapon: string, crafted: string): string {
    return "木 " + inv.wood + " · 铃 " + inv.bell
        + " · 装备 " + weaponNameOf(weapon)
        + (crafted === "" ? " · 未改制" : " · 已改制 " + weaponNameOf(crafted));
}
