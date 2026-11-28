/**
 * 《向西守望》暗黑像素风（Dead Cells 风格）场景透视贴图与道具图集动态槽位注册：
 * - 图集文件：`assets/art/scene_dark_pixel.png` + `assets/art/scene_dark_pixel.clip`；
 * - 通过 registerDynamicSlot 动态注册，保持静态 ASSET_SLOTS 兼容（零破坏既有回归断言）；
 * - 所有帧均使用 TextureFilter.Point（smooth: false），统一明代冷月暗黑像素质感。
 */

import { AssetSlotConfig, registerDynamicSlot } from "Script/watch/fe/assets";

export const DARK_PIXEL_SLOTS: Record<string, AssetSlotConfig> = {
    // 三车道透视青石路面与前后路缘石
    dp_road_upper: { paths: ["assets/art/scene_dark_pixel.clip|dp_road_upper"], anchorY: 0, preserveAspect: false },
    dp_road_mid: { paths: ["assets/art/scene_dark_pixel.clip|dp_road_mid"], anchorY: 0, preserveAspect: false },
    dp_road_lower: { paths: ["assets/art/scene_dark_pixel.clip|dp_road_lower"], anchorY: 0, preserveAspect: false },
    dp_road_curb: { paths: ["assets/art/scene_dark_pixel.clip|dp_road_curb"], anchorY: 0, preserveAspect: false },

    // 2.5D 掩体专属顶面与阴影侧面（告别竖墙正视图压扁当顶盖）
    dp_wall_top: { paths: ["assets/art/scene_dark_pixel.clip|dp_wall_top"], anchorY: 0, preserveAspect: false },
    dp_wall_side: { paths: ["assets/art/scene_dark_pixel.clip|dp_wall_side"], anchorY: 0, preserveAspect: false },
    dp_wood_top: { paths: ["assets/art/scene_dark_pixel.clip|dp_wood_top"], anchorY: 0, preserveAspect: false },
    dp_wood_side: { paths: ["assets/art/scene_dark_pixel.clip|dp_wood_side"], anchorY: 0, preserveAspect: false },
    dp_stone_top: { paths: ["assets/art/scene_dark_pixel.clip|dp_stone_top"], anchorY: 0, preserveAspect: false },
    dp_stone_side: { paths: ["assets/art/scene_dark_pixel.clip|dp_stone_side"], anchorY: 0, preserveAspect: false },

    // 石阶、门闩、牌坊横梁、补丁红布车、火盆、焦痕危险带、庭院侧灶、边界封口拒马
    dp_stair_step: { paths: ["assets/art/scene_dark_pixel.clip|dp_stair_step"], anchorY: 0, preserveAspect: false },
    dp_latch: { paths: ["assets/art/scene_dark_pixel.clip|dp_latch"], anchorY: 0, preserveAspect: true },
    dp_gate_arch_beam: { paths: ["assets/art/scene_dark_pixel.clip|dp_gate_arch_beam"], anchorY: 0, preserveAspect: false },
    dp_red_cart: { paths: ["assets/art/scene_dark_pixel.clip|dp_red_cart"], anchorY: 0, preserveAspect: true },
    dp_brazier: { paths: ["assets/art/scene_dark_pixel.clip|dp_brazier"], anchorY: 0, preserveAspect: true },
    dp_scorch_zone: { paths: ["assets/art/scene_dark_pixel.clip|dp_scorch_zone"], anchorY: 0, preserveAspect: false },
    dp_stove_hearth: { paths: ["assets/art/scene_dark_pixel.clip|dp_stove_hearth"], anchorY: 0, preserveAspect: true },
    dp_boundary_barricade: { paths: ["assets/art/scene_dark_pixel.clip|dp_boundary_barricade"], anchorY: 0, preserveAspect: false },

    // 中景与前景暗黑像素建筑/官仓柱/崖岩立牌（替换纯色多边形剪影灰模）
    dp_ruin_house_a: { paths: ["assets/art/scene_dark_pixel.clip|dp_ruin_house_a"], anchorY: 0, preserveAspect: true },
    dp_ruin_house_b: { paths: ["assets/art/scene_dark_pixel.clip|dp_ruin_house_b"], anchorY: 0, preserveAspect: true },
    dp_granary_pillar: { paths: ["assets/art/scene_dark_pixel.clip|dp_granary_pillar"], anchorY: 0, preserveAspect: false },
    dp_cliff_rock: { paths: ["assets/art/scene_dark_pixel.clip|dp_cliff_rock"], anchorY: 0, preserveAspect: true },
    dp_fg_rock: { paths: ["assets/art/scene_dark_pixel.clip|dp_fg_rock"], anchorY: 0, preserveAspect: false },

    // 脚底接地接触影与滞空投影圈（直接放入 worldArt 随 depthOrder 排序，杜绝被地面/精灵覆盖）
    dp_shadow_contact: { paths: ["assets/art/scene_dark_pixel.clip|dp_shadow_contact"], anchorY: 0.5, preserveAspect: false },
    dp_shadow_air: { paths: ["assets/art/scene_dark_pixel.clip|dp_shadow_air"], anchorY: 0.5, preserveAspect: false },
};

let registered = false;

export function ensureDarkPixelAssetsRegistered(): void {
    if (registered) {
        return;
    }
    registered = true;
    for (const key in DARK_PIXEL_SLOTS) {
        registerDynamicSlot(key, DARK_PIXEL_SLOTS[key]);
    }
}
