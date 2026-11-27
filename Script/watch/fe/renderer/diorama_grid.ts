/**
 * 《向西守望》Dora SSR 原生 Grid 纹理 2.5D 微缩剧场渲染宿主（Phase 1 · Diorama Engine）。
 *
 * 架构核心：
 * - 将 `Grid`（透视细分纹理面）、`Sprite`（3D 空间立体剪纸卡）与按连续批次复用的 `DrawNode`
 *   统一挂载到同一个容器 `Node` 下，共享同一套单调递增的整数 painter's-algorithm `order`；
 * - 严格兼容 Dora SSR Lua 绑定约定：`Grid.setPos(ix, iy, pos)` / `Grid.setColor(ix, iy, col)`
 *   采用 1-based 顶点索引（ix ∈ [1..segX+1] 自左向右，iy ∈ [1..segY+1] 自顶向下）；
 * - 零每帧纹理/节点分配：跨帧按池键复用节点并在 `endFrame()` 自动隐藏未使用的节点，切房无残留。
 */

import { BlendFunc, BlendOp, Color, Content, DrawNode, Grid, Node, Sprite, TextureFilter, Vec2 } from "Dora";

export interface DioramaVec3 {
    x: number;
    y: number;
    z: number;
}

export interface DioramaProjected {
    x: number;
    y: number;
    scale: number;
    zEff: number;
}

export interface DioramaWaveSpec {
    /** 水平波幅（屏幕像素或世界单位，按点缩放） */
    ampX: number;
    /** 竖直波幅 */
    ampY: number;
    /** 当前相位（弧度） */
    phase: number;
    /** 沿 U 方向的空间频率 */
    freqU: number;
    /** 沿 V 方向的空间频率 */
    freqV: number;
    /** 固定边：'top' 表示顶边固定（垂布/桌布），'left' 表示左边固定（红布飘旗），'none' 表示全幅波纹（水面） */
    pin?: "top" | "left" | "none";
}

export interface DioramaProjector {
    project(wx: number, wy: number, wz: number): DioramaProjected;
}

export interface DioramaTexturedQuadParams {
    clipStr: string;
    v0: DioramaVec3;
    v1: DioramaVec3;
    v2: DioramaVec3;
    v3: DioramaVec3;
    segX: number;
    segY: number;
    projector: DioramaProjector;
    tintColor: Color.Type;
    bottomShade: number;
    opacity: number;
    order: number;
    additive?: boolean;
    wave?: DioramaWaveSpec;
}

export interface DioramaCutoutParams {
    clipStr: string;
    x: number;
    y: number;
    targetW: number;
    targetH: number;
    order: number;
    anchorX?: number;
    anchorY?: number;
    facing?: number;
    flipY?: boolean;
    angle?: number;
    color?: Color.Type;
    opacity?: number;
    smooth?: boolean;
    additive?: boolean;
}

interface GridPoolEntry {
    node: Grid.Type;
    clipStr: string;
    segX: number;
    segY: number;
    additive: boolean;
}

interface SpritePoolEntry {
    node: Sprite.Type;
    clipStr: string;
    smooth: boolean;
    additive: boolean;
}

const WHITE = Color(255, 255, 255, 255);
const NORMAL_BLEND = BlendFunc(BlendOp.SrcAlpha, BlendOp.InvSrcAlpha);
const ADDITIVE_BLEND = BlendFunc(BlendOp.SrcAlpha, BlendOp.One);

function fileOfClip(clipStr: string): string {
    const idx = clipStr.indexOf("|");
    return idx < 0 ? clipStr : clipStr.slice(0, idx);
}

export class DioramaLayerHost {
    private container: Node.Type;
    private unavailable: Record<string, boolean> = {};

    // 按 clip+subdiv+blend 分桶的 Grid 池
    private gridPools: Record<string, GridPoolEntry[]> = {};
    private gridCursor: Record<string, number> = {};

    // 按 clip+smooth+blend 分桶的 Sprite 池
    private spritePools: Record<string, SpritePoolEntry[]> = {};
    private spriteCursor: Record<string, number> = {};

    // 交错在 Grid/Sprite 之间的连续 DrawNode 池（用于无纹理远山、雾幕、接触影等）
    private drawPool: DrawNode.Type[] = [];
    private drawCursor = 0;

    private orderCounter = 0;

    constructor(parent: Node.Type, order: number) {
        this.container = Node();
        this.container.order = order;
        this.container.addTo(parent);
    }

    /** 每帧开始时重置游标（实际隐藏推迟到 endFrame，减少无效显隐切换） */
    beginFrame(): void {
        this.gridCursor = {};
        this.spriteCursor = {};
        this.drawCursor = 0;
        this.orderCounter = 0;
    }

    /** 分配下一个严格递增的画家算法绘制序号 */
    nextOrder(): number {
        const cur = this.orderCounter;
        this.orderCounter += 1;
        return cur;
    }

    /** 申请一个指定 order 的交错 DrawNode（用于与 Grid / Cutout 精确深度穿插） */
    acquireDrawRun(order: number): DrawNode.Type {
        let node = this.drawPool[this.drawCursor];
        if (node === undefined) {
            node = DrawNode();
            node.addTo(this.container);
            this.drawPool[this.drawCursor] = node;
        }
        this.drawCursor += 1;
        node.clear();
        node.order = order;
        node.visible = true;
        return node;
    }

    /**
     * 在容器中放置一个透视细分纹理 Grid 四边形：
     * v0=左下, v1=右下, v2=右上, v3=左上；自动按 segX × segY 做 3D 空间插值后逐点投影，
     * 大幅消除大透视斜面的仿射贴图扭曲，并支持红布/桌布/溪水顶点波浪变形。
     */
    placeTexturedQuad(params: DioramaTexturedQuadParams): boolean {
        if (params.opacity <= 0.008) {
            return false;
        }
        const segX = Math.max(1, Math.min(12, Math.floor(params.segX)));
        const segY = Math.max(1, Math.min(8, Math.floor(params.segY)));
        const add = params.additive === true;
        const poolKey = params.clipStr + "#" + segX + "x" + segY + (add ? ":add" : "");

        if (this.unavailable[params.clipStr] === true) {
            return false;
        }

        let bucket = this.gridPools[poolKey];
        if (bucket === undefined) {
            bucket = [];
            this.gridPools[poolKey] = bucket;
        }
        const idx = this.gridCursor[poolKey] ?? 0;
        let entry = bucket[idx];
        if (entry === undefined) {
            const file = fileOfClip(params.clipStr);
            if (!Content.exist(file)) {
                this.unavailable[params.clipStr] = true;
                return false;
            }
            const grid = Grid(params.clipStr, segX, segY);
            if (grid === undefined) {
                this.unavailable[params.clipStr] = true;
                return false;
            }
            grid.position = Vec2(0, 0);
            grid.blendFunc = add ? ADDITIVE_BLEND : NORMAL_BLEND;
            grid.addTo(this.container);
            entry = { node: grid, clipStr: params.clipStr, segX, segY, additive: add };
            bucket[idx] = entry;
        }
        this.gridCursor[poolKey] = idx + 1;

        const grid = entry.node;
        const { v0, v1, v2, v3, projector, wave } = params;

        // 1-based 顶点遍历：iy = 1 对应顶边 (v3 → v2)，iy = segY + 1 对应底边 (v0 → v1)
        let iy = 1;
        for (iy = 1; iy <= segY + 1; iy++) {
            const vTop = (iy - 1) / segY; // 0 = top, 1 = bottom
            const vBot = 1 - vTop;
            const shade = Math.round(255 * (vBot + vTop * params.bottomShade));
            const rowColor = Color(shade, shade, shade, 255);
            // 左边插值 (v3 -> v0) 与右边插值 (v2 -> v1)
            const lx = v3.x * vBot + v0.x * vTop;
            const ly = v3.y * vBot + v0.y * vTop;
            const lz = v3.z * vBot + v0.z * vTop;
            const rx = v2.x * vBot + v1.x * vTop;
            const ry = v2.y * vBot + v1.y * vTop;
            const rz = v2.z * vBot + v1.z * vTop;

            let ix = 1;
            for (ix = 1; ix <= segX + 1; ix++) {
                const u = (ix - 1) / segX;
                const wx = lx + (rx - lx) * u;
                const wy = ly + (ry - ly) * u;
                const wz = lz + (rz - lz) * u;
                const pt = projector.project(wx, wy, wz);
                let sx = pt.x;
                let sy = pt.y;
                if (wave !== undefined) {
                    let weight = 1;
                    if (wave.pin === "top") {
                        weight = vTop * vTop;
                    } else if (wave.pin === "left") {
                        weight = u * u;
                    }
                    const ang = wave.phase + u * wave.freqU + vTop * wave.freqV;
                    sx += Math.sin(ang) * wave.ampX * weight * pt.scale;
                    sy += Math.cos(ang * 0.85) * wave.ampY * weight * pt.scale;
                }
                grid.setPos(ix, iy, Vec2(sx, sy));
                grid.setColor(ix, iy, rowColor);
            }
        }

        grid.order = params.order;
        grid.color = params.tintColor;
        const baseA = params.tintColor.a / 255;
        grid.opacity = Math.max(0, Math.min(1, baseA * params.opacity));
        grid.visible = true;
        return true;
    }

    /** 在同一深度排序队列中放置 3D 空间手绘立体剪纸卡（古松、飞檐、桌裙、铁盆、树根等） */
    placeCutoutCard(params: DioramaCutoutParams): boolean {
        const op = params.opacity ?? 1;
        if (op <= 0.008 || params.targetW <= 0.5 || params.targetH <= 0.5) {
            return false;
        }
        if (this.unavailable[params.clipStr] === true) {
            return false;
        }
        const smooth = params.smooth !== false;
        const add = params.additive === true;
        const poolKey = params.clipStr + (smooth ? ":s" : ":p") + (add ? ":a" : "");

        let bucket = this.spritePools[poolKey];
        if (bucket === undefined) {
            bucket = [];
            this.spritePools[poolKey] = bucket;
        }
        const idx = this.spriteCursor[poolKey] ?? 0;
        let entry = bucket[idx];
        if (entry === undefined) {
            const file = fileOfClip(params.clipStr);
            if (!Content.exist(file)) {
                this.unavailable[params.clipStr] = true;
                return false;
            }
            const sp = Sprite(params.clipStr);
            if (sp === undefined) {
                this.unavailable[params.clipStr] = true;
                return false;
            }
            sp.filter = smooth ? TextureFilter.Anisotropic : TextureFilter.Point;
            sp.blendFunc = add ? ADDITIVE_BLEND : NORMAL_BLEND;
            sp.addTo(this.container);
            entry = { node: sp, clipStr: params.clipStr, smooth, additive: add };
            bucket[idx] = entry;
        }
        this.spriteCursor[poolKey] = idx + 1;

        const sp = entry.node;
        sp.anchor = Vec2(params.anchorX ?? 0.5, params.anchorY ?? 0);
        sp.position = Vec2(params.x, params.y);
        const sx = params.targetW / Math.max(1, sp.width);
        const sy = params.targetH / Math.max(1, sp.height);
        sp.scaleX = (params.facing ?? 1) < 0 ? -sx : sx;
        sp.scaleY = params.flipY === true ? -sy : sy;
        sp.angle = params.angle ?? 0;
        sp.order = params.order;
        const col = params.color ?? WHITE;
        sp.color = col;
        sp.opacity = Math.max(0, Math.min(1, (col.a / 255) * op));
        sp.visible = true;
        return true;
    }

    /** 帧末隐藏全部本帧未使用的池化节点，确保切房或退回像素风零残留 */
    endFrame(): void {
        for (const key in this.gridPools) {
            const bucket = this.gridPools[key];
            const used = this.gridCursor[key] ?? 0;
            let i = used;
            for (i = used; i < bucket.length; i++) {
                if (bucket[i].node.visible) {
                    bucket[i].node.visible = false;
                }
            }
        }
        for (const key in this.spritePools) {
            const bucket = this.spritePools[key];
            const used = this.spriteCursor[key] ?? 0;
            let i = used;
            for (i = used; i < bucket.length; i++) {
                if (bucket[i].node.visible) {
                    bucket[i].node.visible = false;
                }
            }
        }
        let d = this.drawCursor;
        for (d = this.drawCursor; d < this.drawPool.length; d++) {
            const dn = this.drawPool[d];
            if (dn.visible) {
                dn.clear();
                dn.visible = false;
            }
        }
    }
}
