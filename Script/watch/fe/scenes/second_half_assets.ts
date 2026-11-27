/**
 * 后半段美术图集动态槽位注册（assets/art/props_second_half.clip）：
 * - 通过 registerDynamicSlot 动态挂载，不修改静态 ASSET_SLOTS，保证 verify-integration 全槽位断言零回归；
 * - 所有帧路径使用显式字面量 `assets/art/props_second_half.clip|<frame>`，由 tools/audit-assets.py 自动校验存在性。
 */

import { AssetSlotConfig, registerDynamicSlot } from "Script/watch/fe/assets";

export const SECOND_HALF_SLOTS: Record<string, AssetSlotConfig> = {
    // 男主护送线 & 公共实景道具（32-bit 明代冷月像素风格）
    sh_grain_sacks: { paths: ["assets/art/props_second_half.clip|grain_sacks"], anchorY: 0, preserveAspect: true },
    sh_craft_workbench: { paths: ["assets/art/props_second_half.clip|craft_workbench"], anchorY: 0, preserveAspect: true },
    sh_old_watchman: { paths: ["assets/art/props_second_half.clip|old_watchman"], anchorY: 0, preserveAspect: true },
    sh_root_burrow: { paths: ["assets/art/props_second_half.clip|root_burrow"], anchorY: 0, preserveAspect: true },
    sh_salt_hut: { paths: ["assets/art/props_second_half.clip|salt_hut"], anchorY: 0, preserveAspect: true },
    sh_gong_target: { paths: ["assets/art/props_second_half.clip|gong_target"], anchorY: 0, preserveAspect: true },
    sh_iron_basin: { paths: ["assets/art/props_second_half.clip|iron_basin"], anchorY: 0, preserveAspect: true },
    sh_wood_tally: { paths: ["assets/art/props_second_half.clip|wood_tally"], anchorY: 0.15, preserveAspect: true },
    sh_bell_tally: { paths: ["assets/art/props_second_half.clip|bell_tally"], anchorY: 0.15, preserveAspect: true },
    sh_guard_desk: { paths: ["assets/art/props_second_half.clip|guard_desk"], anchorY: 0, preserveAspect: true },
    sh_straw_mat: { paths: ["assets/art/props_second_half.clip|straw_mat"], anchorY: 0, preserveAspect: true },
    sh_stele_banner: { paths: ["assets/art/props_second_half.clip|stele_banner"], anchorY: 0, preserveAspect: true },

    // 北塔双结局与现代展厅精细工笔/宋明版画切片（平滑滤波）
    sh_museum_plate_wall: { paths: ["assets/art/props_second_half.clip|museum_plate_wall"], anchorY: 0.5, preserveAspect: false, smooth: true },
    sh_museum_plate_lamp: { paths: ["assets/art/props_second_half.clip|museum_plate_lamp"], anchorY: 0.5, preserveAspect: false, smooth: true },
    sh_museum_compass_relic: { paths: ["assets/art/props_second_half.clip|museum_compass_relic"], anchorY: 0.5, preserveAspect: true, smooth: true },
    sh_ending_cuff_hand: { paths: ["assets/art/props_second_half.clip|ending_cuff_hand"], anchorY: 0.5, preserveAspect: true, smooth: true },
    sh_ending_bowl_hands: { paths: ["assets/art/props_second_half.clip|ending_bowl_hands"], anchorY: 0.5, preserveAspect: true, smooth: true },
};

let registered = false;

export function ensureSecondHalfAssetsRegistered(): void {
    if (registered) {
        return;
    }
    registered = true;
    for (const key in SECOND_HALF_SLOTS) {
        registerDynamicSlot(key, SECOND_HALF_SLOTS[key]);
    }
}
