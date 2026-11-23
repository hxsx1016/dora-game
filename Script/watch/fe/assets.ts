/**
 * 可插拔图像资产槽位注册表。
 *
 * 本分支（独立前端分支）不含 AI 生图类外部图像文件，全部默认回退到高完成度程序化矢量渲染。
 * 下游「完整前端分支」接入生图资产时，只需把对应 PNG / clip 路径填入 ASSET_SLOTS，
 * 前端会自动用真实 Sprite 替换或叠加对应槽位，无需改动 HUD、镜头、特效与状态机。
 */

import { Content, Node, Sprite, Vec2 } from "Dora";

export type AssetSlotKey =
    | "bgFar_prologue" | "bgFar_street" | "bgFar_checkpoint" | "bgFar_gate"
    | "bgFar_outside" | "bgFar_village" | "bgFar_forest" | "bgFar_tower"
    | "bgMid_prologue" | "bgMid_street" | "bgMid_checkpoint" | "bgMid_gate"
    | "bgMid_outside" | "bgMid_village" | "bgMid_forest" | "bgMid_tower"
    | "soldier_idle" | "soldier_run" | "soldier_roll" | "soldier_cover"
    | "child_idle" | "child_run" | "child_crouch" | "child_fear"
    | "enemy_idle" | "enemy_aim" | "enemy_down"
    | "scavenger" | "dog"
    | "prop_cart" | "prop_bottle" | "prop_tower_door"
    | "title_backdrop";

export interface AssetSlotConfig {
    path?: string;
    anchorX?: number;
    anchorY?: number;
    scale?: number;
}

/**
 * 留空表示使用本分支的程序化 ICEY 矢量绘制。
 * 完整前端分支在此填写相对路径（如 "assets/art/soldier_idle.png"）。
 */
export const ASSET_SLOTS: Partial<Record<AssetSlotKey, AssetSlotConfig>> = {};

interface CachedSlot {
    checked: boolean;
    exists: boolean;
    sprite?: Sprite.Type;
}

/** 轻量 Sprite 槽位宿主：每帧仅激活实际有外部贴图资源的槽位。 */
export class AssetSlotHost {
    private container: Node.Type;
    private cache: Record<string, CachedSlot> = {};
    private usedThisFrame: Record<string, boolean> = {};

    constructor(parent: Node.Type, order: number) {
        this.container = Node();
        this.container.order = order;
        this.container.addTo(parent);
    }

    /** 帧首重置：隐藏上一帧启用但本帧未出现的 Sprite。 */
    beginFrame(): void {
        this.usedThisFrame = {};
    }

    /**
     * 尝试用外部贴图绘制指定槽位。
     * 返回 true 表示外部图像已接管绘制；返回 false 表示继续走程序化矢量回退。
     */
    tryPlace(
        slotKey: AssetSlotKey,
        instanceKey: string,
        x: number,
        y: number,
        targetW: number,
        targetH: number,
        facing: number = 1,
        opacity: number = 1,
    ): boolean {
        const cfg = ASSET_SLOTS[slotKey];
        if (cfg === undefined || cfg.path === undefined || cfg.path === "") {
            return false;
        }
        let entry = this.cache[instanceKey];
        if (entry === undefined) {
            const exists = Content.exist(cfg.path);
            entry = { checked: true, exists };
            if (exists) {
                const sp = Sprite(cfg.path);
                if (sp !== undefined) {
                    sp.anchor = Vec2(cfg.anchorX !== undefined ? cfg.anchorX : 0.5, cfg.anchorY !== undefined ? cfg.anchorY : 0);
                    sp.addTo(this.container);
                    entry.sprite = sp;
                } else {
                    entry.exists = false;
                }
            }
            this.cache[instanceKey] = entry;
        }
        if (!entry.exists || entry.sprite === undefined) {
            return false;
        }
        const sp = entry.sprite;
        const sw = sp.width > 0 ? sp.width : 1;
        const sh = sp.height > 0 ? sp.height : 1;
        const baseScale = cfg.scale !== undefined ? cfg.scale : 1;
        const sx = (targetW / sw) * baseScale * (facing < 0 ? -1 : 1);
        const sy = (targetH / sh) * baseScale;
        sp.position = Vec2(x, y);
        sp.scaleX = sx;
        sp.scaleY = sy;
        sp.opacity = opacity;
        sp.visible = true;
        this.usedThisFrame[instanceKey] = true;
        return true;
    }

    /** 帧尾清理本帧未命中的 Sprite。 */
    endFrame(): void {
        for (const key in this.cache) {
            if (!this.usedThisFrame[key]) {
                const sp = this.cache[key].sprite;
                if (sp !== undefined) {
                    sp.visible = false;
                }
            }
        }
    }

    /** 检查是否至少挂载了一张外部图。 */
    hasExternalAsset(slotKey: AssetSlotKey): boolean {
        const cfg = ASSET_SLOTS[slotKey];
        return cfg !== undefined && cfg.path !== undefined && cfg.path !== "" && Content.exist(cfg.path);
    }
}
