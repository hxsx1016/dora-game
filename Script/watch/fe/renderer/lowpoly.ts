/**
 * 《向西守望》程序化 2.5D 透视低模渲染内核（Wave 1 · feature/fe-01-gate-cuff-lowpoly）。
 *
 * 架构职责（供 fe-01 城门风台转景 与 Wave 2 fe-04 小满线《小小梦魇》四房共同复用）：
 * 1. 严格数学不变量：
 *    - 世界空间采用右手系扩展 (wx, wy, wz)，wz = 0 为可玩走面，wz > 0 退入远景，wz < 0 探向前景；
 *    - 对任意形变因子 morph ∈ [0, 1]、任意灭点偏移、任意相机侧移与窗口分辨率：
 *      凡位于 wz = 0 的点（小满脚底、门槛、车柄、投瓶落点、碰撞面）恒满足
 *      projectWorld3D(wx, wy, 0) === cam.worldToScreen(wx, wy)，
 *      保证与 Play.worldMapper (cam.screenToWorld) 0.00 px 误差；
 *    - morph = 0 时严格退化为正交像素平面；morph = 1 时呈现《小小梦魇》第一作尺度、
 *      高反差方向侧光、前景压迫遮挡与分层体积雾的低模空间。
 * 2. 画家算法真深度排序：
 *    - 所有 3D 面按 (bucket, sortZ DESC, sortBias) 稳定由远及近绘制，
 *      确保前景木板自然遮挡后排石阶、门框内壁随视角/形变显露、体积雾夹在远墙与山体之间；
 *    - 全部人物保持本作 2D 精灵（位于 worldArt 层），通过本内核在 wz = 0 铺设脚底接触影融入空间；
 *    - 需压在角色前方的前景遮挡件提供 worldArt 高 layer 投影接口（位于角色前、HUD 后）。
 * 3. 明初海防卫城材质与静音/灰度可读性：
 *    - 内置青砖、风化杉木、磨旧青石、暗铁、旧红布等明初色板与边线提亮，确保关 HUD/转灰度仍清晰可辨。
 */

import { Color, DrawNode, Vec2 } from "Dora";
import { RoomSpec, StairSpec } from "Script/watch/rooms";
import { AssetSlotHost, AssetSlotKey } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { RGBA, lerpRGBA, rgba, toColor } from "Script/watch/fe/theme";

export interface Vec3 {
    x: number;
    y: number;
    z: number;
}

export interface ProjectedPoint {
    x: number;
    y: number;
    scale: number;
    zEff: number;
}

export interface LowpolyProjection {
    /** 连续形变因子：0 = 严格正交像素平面，1 = 完整 2.5D 透视低模 */
    morph: number;
    /** 透视焦距（世界深度单位，推荐 340..480） */
    focal: number;
    /** 灭点水平视口占比（0..1） */
    vpFracX: number;
    /** 灭点竖直视口占比（0..1） */
    vpFracY: number;
    /** 可选灭点像素微偏（用于呼吸微动，绝不改变 wz=0 对齐点） */
    vpOffsetX?: number;
    vpOffsetY?: number;
    /** 走面基准纵深（默认 0） */
    baseDepth?: number;
}

export interface LightRig {
    /** 主方向光（单位向量，指向光源方向） */
    keyDir: Vec3;
    keyColor: RGBA;
    keyStrength: number;
    /** 侧/轮廓补光（单位向量） */
    rimDir: Vec3;
    rimColor: RGBA;
    rimStrength: number;
    /** 暗面环境色 */
    ambientColor: RGBA;
    /** 景深体积雾色与起止深度 */
    fogColor: RGBA;
    fogStartZ: number;
    fogEndZ: number;
    fogMaxAlpha: number;
    /** 暗面对比度（0..1，越大越接近《小小梦魇》强明暗） */
    shadowContrast: number;
}

export interface LowpolyMaterial {
    base: RGBA;
    edge?: RGBA;
    /** 暗面最低亮度系数 */
    minShade?: number;
    /** 顶面/受光面微提亮 */
    rimBoost?: number;
    /** 底部环境光遮蔽压暗比例 (0..0.6) */
    bottomAo?: number;
}

export type LowpolyBucket = 0 | 1 | 2 | 3 | 4;

export const LP_BUCKET = {
    BACKDROP: 0 as LowpolyBucket,
    MIDGROUND: 1 as LowpolyBucket,
    WALK_DECK: 2 as LowpolyBucket,
    PROP: 3 as LowpolyBucket,
    FOREGROUND: 4 as LowpolyBucket,
};

export interface LowpolyFaceOptions {
    bucket?: LowpolyBucket;
    sortBias?: number;
    /** 额外不透明度倍率 0..1 */
    opacity?: number;
    /** 覆写边线颜色 */
    edgeColor?: RGBA;
    edgeWidth?: number;
    /** 跳过光照着色（用于雾帘、纯暗剪影等） */
    unlit?: boolean;
    /** 顶底渐变压暗（覆盖材质 bottomAo） */
    bottomAo?: number;
    /** 覆写排序深度（不传则取顶点平均 z） */
    sortZOverride?: number;
}

export interface LowpolyBoxSpec {
    x0: number;
    x1: number;
    y0: number;
    y1: number;
    z0: number;
    z1: number;
    material: LowpolyMaterial;
    bucket?: LowpolyBucket;
    sortBias?: number;
    opacity?: number;
    /** 是否绘制顶面高亮边（提升灰度/暗部可读性） */
    highlightTopEdge?: boolean;
    /** 是否跳过某些面（例如贴墙背面或镂空内侧） */
    skipFront?: boolean;
    skipLeft?: boolean;
    skipRight?: boolean;
    skipTop?: boolean;
    skipBottom?: boolean;
    edgeWidth?: number;
}

interface QueuedFace {
    bucket: LowpolyBucket;
    sortZ: number;
    sortBias: number;
    pts: ProjectedPoint[];
    cols: Color.Type[];
    edgeCol: Color.Type | undefined;
    edgeWidth: number;
    topHighlight: [ProjectedPoint, ProjectedPoint, Color.Type] | undefined;
}

interface QueuedGlowQuad {
    pts: ProjectedPoint[];
    cols: Color.Type[];
}

export function clamp01(v: number): number {
    return Math.max(0, Math.min(1, v));
}

export function smoothstep(edge0: number, edge1: number, x: number): number {
    if (edge1 <= edge0) {
        return x >= edge1 ? 1 : 0;
    }
    const t = clamp01((x - edge0) / (edge1 - edge0));
    return t * t * (3 - 2 * t);
}

export function vec3(x: number, y: number, z: number): Vec3 {
    return { x, y, z };
}

export function normalize3(v: Vec3): Vec3 {
    const len = Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    if (len < 0.00001) {
        return { x: 0, y: 1, z: 0 };
    }
    return { x: v.x / len, y: v.y / len, z: v.z / len };
}

function dot3(a: Vec3, b: Vec3): number {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

function cross3(a: Vec3, b: Vec3): Vec3 {
    return {
        x: a.y * b.z - a.z * b.y,
        y: a.z * b.x - a.x * b.z,
        z: a.x * b.y - a.y * b.x,
    };
}

function sub3(a: Vec3, b: Vec3): Vec3 {
    return { x: a.x - b.x, y: a.y - b.y, z: a.z - b.z };
}

function clampByte(v: number): number {
    return Math.max(0, Math.min(255, Math.round(v)));
}

function scaleRGBA(c: RGBA, k: number, alphaMul: number = 1): RGBA {
    return {
        r: clampByte(c.r * k),
        g: clampByte(c.g * k),
        b: clampByte(c.b * k),
        a: clampByte(c.a * alphaMul),
    };
}

/** 明初温州宁村所海防卫城低模材质预设（高灰度区分度、禁现代/仙侠荧光） */
export const MING_MATERIALS: Record<string, LowpolyMaterial> = {
    mingBrick: {
        base: rgba(96, 102, 112, 255),
        edge: rgba(154, 162, 174, 155),
        minShade: 0.30,
        rimBoost: 0.24,
        bottomAo: 0.28,
    },
    mingBrickDark: {
        base: rgba(54, 60, 72, 255),
        edge: rgba(108, 118, 134, 135),
        minShade: 0.24,
        rimBoost: 0.18,
        bottomAo: 0.34,
    },
    mingTimber: {
        base: rgba(114, 84, 62, 255),
        edge: rgba(168, 134, 104, 160),
        minShade: 0.26,
        rimBoost: 0.22,
        bottomAo: 0.30,
    },
    mingTimberDark: {
        base: rgba(68, 50, 38, 255),
        edge: rgba(122, 96, 76, 145),
        minShade: 0.20,
        rimBoost: 0.16,
        bottomAo: 0.36,
    },
    mingStoneStep: {
        base: rgba(118, 122, 128, 255),
        edge: rgba(188, 194, 200, 185),
        minShade: 0.28,
        rimBoost: 0.26,
        bottomAo: 0.26,
    },
    mingIron: {
        base: rgba(46, 52, 62, 255),
        edge: rgba(136, 146, 158, 165),
        minShade: 0.22,
        rimBoost: 0.28,
        bottomAo: 0.25,
    },
    mingTile: {
        base: rgba(44, 52, 66, 255),
        edge: rgba(102, 116, 136, 140),
        minShade: 0.24,
        rimBoost: 0.18,
        bottomAo: 0.24,
    },
    mingRedCloth: {
        base: rgba(176, 52, 48, 255),
        edge: rgba(224, 116, 102, 195),
        minShade: 0.36,
        rimBoost: 0.24,
        bottomAo: 0.18,
    },
    distantWall: {
        base: rgba(42, 52, 68, 255),
        edge: rgba(98, 114, 136, 115),
        minShade: 0.35,
        rimBoost: 0.14,
        bottomAo: 0.22,
    },
    distantHill: {
        base: rgba(28, 38, 54, 255),
        edge: rgba(74, 92, 116, 90),
        minShade: 0.38,
        rimBoost: 0.12,
        bottomAo: 0.20,
    },
};

/** 城门风台与小满线四房灯光预设（对齐《小小梦魇》第一作高反差侧光） */
export const GATE_NIGHTMARE_LIGHT: LightRig = {
    keyDir: normalize3(vec3(-0.62, 0.64, -0.45)),
    keyColor: rgba(206, 224, 240, 255),
    keyStrength: 0.88,
    rimDir: normalize3(vec3(0.76, 0.36, -0.54)),
    rimColor: rgba(224, 196, 150, 255),
    rimStrength: 0.34,
    ambientColor: rgba(26, 34, 48, 255),
    fogColor: rgba(26, 36, 52, 255),
    fogStartZ: 36,
    fogEndZ: 560,
    fogMaxAlpha: 0.84,
    shadowContrast: 0.72,
};

export const OUTSIDE_JETTY_LIGHT: LightRig = {
    keyDir: normalize3(vec3(-0.56, 0.68, -0.48)),
    keyColor: rgba(196, 214, 232, 255),
    keyStrength: 0.86,
    rimDir: normalize3(vec3(0.78, 0.32, -0.54)),
    rimColor: rgba(226, 188, 136, 255),
    rimStrength: 0.32,
    ambientColor: rgba(24, 32, 46, 255),
    fogColor: rgba(24, 34, 50, 255),
    fogStartZ: 42,
    fogEndZ: 520,
    fogMaxAlpha: 0.80,
    shadowContrast: 0.74,
};

export const VILLAGE_UNDERTABLE_LIGHT: LightRig = {
    keyDir: normalize3(vec3(0.72, 0.44, -0.54)),
    keyColor: rgba(214, 208, 194, 255),
    keyStrength: 0.92,
    rimDir: normalize3(vec3(-0.64, 0.52, -0.56)),
    rimColor: rgba(146, 166, 186, 255),
    rimStrength: 0.28,
    ambientColor: rgba(18, 22, 30, 255),
    fogColor: rgba(22, 26, 34, 255),
    fogStartZ: 55,
    fogEndZ: 460,
    fogMaxAlpha: 0.78,
    shadowContrast: 0.82,
};

export const FOREST_CREEK_LIGHT: LightRig = {
    keyDir: normalize3(vec3(-0.48, 0.74, -0.47)),
    keyColor: rgba(178, 206, 202, 255),
    keyStrength: 0.80,
    rimDir: normalize3(vec3(0.82, 0.28, -0.50)),
    rimColor: rgba(232, 196, 132, 255),
    rimStrength: 0.36,
    ambientColor: rgba(18, 30, 34, 255),
    fogColor: rgba(20, 34, 38, 255),
    fogStartZ: 34,
    fogEndZ: 480,
    fogMaxAlpha: 0.86,
    shadowContrast: 0.76,
};

export const TOWER_WEST_LAMP_LIGHT: LightRig = {
    keyDir: normalize3(vec3(-0.74, 0.48, -0.47)),
    keyColor: rgba(242, 202, 138, 255),
    keyStrength: 0.94,
    rimDir: normalize3(vec3(0.62, 0.54, -0.57)),
    rimColor: rgba(142, 168, 198, 255),
    rimStrength: 0.26,
    ambientColor: rgba(24, 26, 36, 255),
    fogColor: rgba(24, 28, 40, 255),
    fogStartZ: 60,
    fogEndZ: 480,
    fogMaxAlpha: 0.72,
    shadowContrast: 0.70,
};

/**
 * 核心 2.5D 低模投影：
 * 凡 wz === 0（走面、脚底、门槛、车柄、投瓶落点），恒精确等于 cam.worldToScreen(wx, wy, baseDepth)。
 */
export function projectWorld3D(
    wx: number,
    wy: number,
    wz: number,
    cam: CameraDirector,
    proj: LowpolyProjection,
): ProjectedPoint {
    const bx = cam.sx(wx);
    const by = cam.sy(wy, proj.baseDepth ?? 0);
    const m = clamp01(proj.morph);
    if (m <= 0.00001 || Math.abs(wz) <= 0.00001) {
        return { x: bx, y: by, scale: 1, zEff: 0 };
    }
    const focal = Math.max(60, proj.focal);
    const zEff = wz * m;
    const denom = Math.max(focal * 0.22, focal + zEff);
    const s = focal / denom;
    const vpX = cam.viewW * proj.vpFracX + (proj.vpOffsetX ?? 0);
    const vpY = cam.viewH * proj.vpFracY + (proj.vpOffsetY ?? 0);
    return {
        x: vpX + (bx - vpX) * s,
        y: vpY + (by - vpY) * s,
        scale: s,
        zEff,
    };
}

/**
 * 走面对齐自检辅助（供自动化脚本断言 wz = 0 与 screenToWorld 严格互逆）：
 * 返回前向投影误差与反算世界坐标误差（均为像素/世界单位绝对误差）。
 */
export function verifyWalkPlaneAlignment(
    cam: CameraDirector,
    proj: LowpolyProjection,
    wx: number,
    wy: number,
): { forwardErrPx: number; inverseErrWorld: number; screenX: number; screenY: number } {
    const p3 = projectWorld3D(wx, wy, 0, cam, proj);
    const p2 = cam.worldToScreen(wx, wy, proj.baseDepth ?? 0);
    const fwdDx = p3.x - p2.x;
    const fwdDy = p3.y - p2.y;
    const forwardErrPx = Math.sqrt(fwdDx * fwdDx + fwdDy * fwdDy);

    const inv = cam.screenToWorld(p3.x, p3.y);
    const invDx = inv.x - wx;
    const invDy = inv.y - (wy + (proj.baseDepth ?? 0));
    const inverseErrWorld = Math.sqrt(invDx * invDx + invDy * invDy);
    return {
        forwardErrPx,
        inverseErrWorld,
        screenX: p3.x,
        screenY: p3.y,
    };
}

/** 计算给定法线与深度的低模平面受光+雾效颜色 */
export function shadeSurface(
    base: RGBA,
    normal: Vec3,
    avgZ: number,
    morph: number,
    light: LightRig,
    mat?: LowpolyMaterial,
    opacityMul: number = 1,
): RGBA {
    const m = clamp01(morph);
    const n = normalize3(normal);
    const ndl = Math.max(0, dot3(n, light.keyDir));
    const ndr = Math.max(0, dot3(n, light.rimDir));
    const minShade = mat?.minShade ?? 0.28;
    const rimBoost = mat?.rimBoost ?? 0.20;
    const contrast = light.shadowContrast * (0.45 + 0.55 * m);

    const keyFactor = minShade + (1 - minShade) * (ndl * light.keyStrength + (1 - contrast) * 0.25);
    const rimFactor = ndr * light.rimStrength * (0.35 + 0.65 * m) * (1 + rimBoost);

    const rLit = (base.r * keyFactor * (0.55 + 0.45 * light.keyColor.r / 255))
        + light.ambientColor.r * (0.28 * (1 - ndl * 0.5))
        + light.rimColor.r * rimFactor * 0.45;
    const gLit = (base.g * keyFactor * (0.55 + 0.45 * light.keyColor.g / 255))
        + light.ambientColor.g * (0.28 * (1 - ndl * 0.5))
        + light.rimColor.g * rimFactor * 0.45;
    const bLit = (base.b * keyFactor * (0.55 + 0.45 * light.keyColor.b / 255))
        + light.ambientColor.b * (0.28 * (1 - ndl * 0.5))
        + light.rimColor.b * rimFactor * 0.45;

    const lit: RGBA = {
        r: clampByte(rLit),
        g: clampByte(gLit),
        b: clampByte(bLit),
        a: clampByte(base.a * clamp01(opacityMul)),
    };

    if (avgZ > light.fogStartZ && m > 0.01) {
        const span = Math.max(1, light.fogEndZ - light.fogStartZ);
        const fogT = clamp01((avgZ - light.fogStartZ) / span) * light.fogMaxAlpha * m;
        const mixed = lerpRGBA(lit, light.fogColor, fogT);
        mixed.a = lit.a;
        return mixed;
    }
    return lit;
}

/**
 * 画家算法低模场景批处理器：
 * 每帧收集所有 3D 几何面与体积光，flush 时按 (bucket, sortZ DESC, sortBias) 统一绘制。
 */
export class LowpolyScene {
    readonly cam: CameraDirector;
    readonly proj: LowpolyProjection;
    readonly light: LightRig;
    private faces: QueuedFace[] = [];
    private glows: QueuedGlowQuad[] = [];

    constructor(cam: CameraDirector, proj: LowpolyProjection, light: LightRig = GATE_NIGHTMARE_LIGHT) {
        this.cam = cam;
        this.proj = proj;
        this.light = light;
    }

    getFaceCount(): number {
        return this.faces.length;
    }

    project(wx: number, wy: number, wz: number): ProjectedPoint {
        return projectWorld3D(wx, wy, wz, this.cam, this.proj);
    }

    private vanishingPointScreen(): { x: number; y: number } {
        return {
            x: this.cam.viewW * this.proj.vpFracX + (this.proj.vpOffsetX ?? 0),
            y: this.cam.viewH * this.proj.vpFracY + (this.proj.vpOffsetY ?? 0),
        };
    }

    /** 添加一个 3D 四边形面（逆时针 v0→v1→v2→v3，v0/v1 为底边、v2/v3 为顶边以便施加底部 AO 渐变） */
    addQuad3D(
        v0: Vec3,
        v1: Vec3,
        v2: Vec3,
        v3: Vec3,
        mat: LowpolyMaterial,
        opts: LowpolyFaceOptions = {},
    ): void {
        const opacity = opts.opacity ?? 1;
        if (opacity <= 0.01) {
            return;
        }
        const p0 = this.project(v0.x, v0.y, v0.z);
        const p1 = this.project(v1.x, v1.y, v1.z);
        const p2 = this.project(v2.x, v2.y, v2.z);
        const p3 = this.project(v3.x, v3.y, v3.z);

        // 过滤退化零面积面（如 morph = 0 时完全折叠的侧面）
        const area2 = Math.abs(
            (p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y)
            + (p2.x - p0.x) * (p3.y - p0.y) - (p3.x - p0.x) * (p2.y - p0.y),
        );
        if (area2 < 0.25) {
            return;
        }

        const avgZ = opts.sortZOverride !== undefined ? opts.sortZOverride : (v0.z + v1.z + v2.z + v3.z) * 0.25;
        let topRgba: RGBA;
        if (opts.unlit === true) {
            topRgba = scaleRGBA(mat.base, 1, opacity);
        } else {
            const n = cross3(sub3(v1, v0), sub3(v3, v0));
            topRgba = shadeSurface(mat.base, n, avgZ, this.proj.morph, this.light, mat, opacity);
        }

        const ao = opts.bottomAo !== undefined ? opts.bottomAo : (mat.bottomAo ?? 0.22);
        const botRgba = ao > 0.005 ? scaleRGBA(topRgba, Math.max(0.35, 1 - ao * (0.45 + 0.55 * this.proj.morph)), 1) : topRgba;
        const cBot = toColor(botRgba);
        const cTop = toColor(topRgba);

        const edgeRgba = opts.edgeColor ?? mat.edge;
        const edgeW = opts.edgeWidth ?? 0;
        const edgeCol = edgeRgba !== undefined && edgeW > 0
            ? toColor(edgeRgba, Math.round(edgeRgba.a * opacity))
            : undefined;

        this.faces.push({
            bucket: opts.bucket ?? LP_BUCKET.MIDGROUND,
            sortZ: avgZ,
            sortBias: opts.sortBias ?? 0,
            pts: [p0, p1, p2, p3],
            cols: [cBot, cBot, cTop, cTop],
            edgeCol,
            edgeWidth: edgeW,
            topHighlight: undefined,
        });
    }

    /** 添加一个 3D 三角形面（用于低模山脊、屋檐斜坡、碎石、飘动红布） */
    addTri3D(
        v0: Vec3,
        v1: Vec3,
        v2: Vec3,
        mat: LowpolyMaterial,
        opts: LowpolyFaceOptions = {},
    ): void {
        const opacity = opts.opacity ?? 1;
        if (opacity <= 0.01) {
            return;
        }
        const p0 = this.project(v0.x, v0.y, v0.z);
        const p1 = this.project(v1.x, v1.y, v1.z);
        const p2 = this.project(v2.x, v2.y, v2.z);

        const area2 = Math.abs((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y));
        if (area2 < 0.25) {
            return;
        }

        const avgZ = opts.sortZOverride !== undefined ? opts.sortZOverride : (v0.z + v1.z + v2.z) / 3;
        const colRgba = opts.unlit === true
            ? scaleRGBA(mat.base, 1, opacity)
            : shadeSurface(mat.base, cross3(sub3(v1, v0), sub3(v2, v0)), avgZ, this.proj.morph, this.light, mat, opacity);
        const ao = opts.bottomAo !== undefined ? opts.bottomAo : (mat.bottomAo ?? 0.16);
        const botRgba = ao > 0.005 ? scaleRGBA(colRgba, Math.max(0.4, 1 - ao), 1) : colRgba;

        const edgeRgba = opts.edgeColor ?? mat.edge;
        const edgeW = opts.edgeWidth ?? 0;
        const edgeCol = edgeRgba !== undefined && edgeW > 0
            ? toColor(edgeRgba, Math.round(edgeRgba.a * opacity))
            : undefined;

        this.faces.push({
            bucket: opts.bucket ?? LP_BUCKET.MIDGROUND,
            sortZ: avgZ,
            sortBias: opts.sortBias ?? 0,
            pts: [p0, p1, p2],
            cols: [toColor(botRgba), toColor(botRgba), toColor(colRgba)],
            edgeCol,
            edgeWidth: edgeW,
            topHighlight: undefined,
        });
    }

    /**
     * 添加 3D 长方体建筑块 [x0..x1, y0..y1, z0..z1]（z0 < z1，z0 靠前、z1 靠后）：
     * 根据当前灭点位置自动判定可见侧面与顶/底面，并按法线独立受光。
     */
    addBox(spec: LowpolyBoxSpec): void {
        const opacity = spec.opacity ?? 1;
        if (opacity <= 0.01) {
            return;
        }
        const x0 = Math.min(spec.x0, spec.x1);
        const x1 = Math.max(spec.x0, spec.x1);
        const y0 = Math.min(spec.y0, spec.y1);
        const y1 = Math.max(spec.y0, spec.y1);
        const z0 = Math.min(spec.z0, spec.z1);
        const z1 = Math.max(spec.z0, spec.z1);

        const bucket = spec.bucket ?? LP_BUCKET.MIDGROUND;
        const bias = spec.sortBias ?? 0;
        const edgeW = spec.edgeWidth ?? 0.85;
        const midZ = (z0 + z1) * 0.5;
        const vp = this.vanishingPointScreen();
        const m = clamp01(this.proj.morph);

        const sx0 = this.cam.sx(x0);
        const sx1 = this.cam.sx(x1);
        const sy0 = this.cam.sy(y0, this.proj.baseDepth ?? 0);
        const sy1 = this.cam.sy(y1, this.proj.baseDepth ?? 0);

        if (m > 0.002 && (z1 - z0) > 0.05) {
            // 左侧面（法线 -X）：当块体左沿在灭点右侧时可见
            if (spec.skipLeft !== true && sx0 > vp.x + 0.5) {
                this.addQuad3D(
                    vec3(x0, y0, z1),
                    vec3(x0, y0, z0),
                    vec3(x0, y1, z0),
                    vec3(x0, y1, z1),
                    spec.material,
                    { bucket, sortZOverride: midZ + 0.4, sortBias: bias - 0.1, opacity, edgeWidth: edgeW },
                );
            }
            // 右侧面（法线 +X）：当块体右沿在灭点左侧时可见
            if (spec.skipRight !== true && sx1 < vp.x - 0.5) {
                this.addQuad3D(
                    vec3(x1, y0, z0),
                    vec3(x1, y0, z1),
                    vec3(x1, y1, z1),
                    vec3(x1, y1, z0),
                    spec.material,
                    { bucket, sortZOverride: midZ + 0.4, sortBias: bias - 0.1, opacity, edgeWidth: edgeW },
                );
            }
            // 顶面（法线 +Y）：当块体顶沿在灭点下方时可见
            if (spec.skipTop !== true && sy1 < vp.y - 0.5) {
                this.addQuad3D(
                    vec3(x0, y1, z0),
                    vec3(x1, y1, z0),
                    vec3(x1, y1, z1),
                    vec3(x0, y1, z1),
                    spec.material,
                    { bucket, sortZOverride: midZ + 0.2, sortBias: bias - 0.05, opacity, edgeWidth: edgeW, bottomAo: 0.08 },
                );
            }
            // 底面（法线 -Y）：当块体底沿在灭点上方时可见（如门楣下底面、桌沿底面）
            if (spec.skipBottom !== true && sy0 > vp.y + 0.5) {
                this.addQuad3D(
                    vec3(x0, y0, z1),
                    vec3(x1, y0, z1),
                    vec3(x1, y0, z0),
                    vec3(x0, y0, z0),
                    spec.material,
                    { bucket, sortZOverride: midZ + 0.2, sortBias: bias - 0.05, opacity, edgeWidth: edgeW, bottomAo: 0.34 },
                );
            }
        }

        // 正面（法线 -Z，朝向观众）
        if (spec.skipFront !== true) {
            const beforeLen = this.faces.length;
            this.addQuad3D(
                vec3(x0, y0, z0),
                vec3(x1, y0, z0),
                vec3(x1, y1, z0),
                vec3(x0, y1, z0),
                spec.material,
                { bucket, sortZOverride: z0, sortBias: bias, opacity, edgeWidth: edgeW },
            );
            if (spec.highlightTopEdge === true && this.faces.length > beforeLen) {
                const face = this.faces[this.faces.length - 1];
                const rimCol = spec.material.edge ?? rgba(198, 206, 214, 180);
                face.topHighlight = [
                    face.pts[3],
                    face.pts[2],
                    toColor(rimCol, Math.round(Math.min(245, rimCol.a * 1.15) * opacity)),
                ];
            }
        }
    }

    /**
     * 3D 立体门框/拱券内壁（门洞左壁、右壁、门楣底面与正面框体）：
     * 当 morph 从 0 拉大到 0.25（风台第 6 秒）时，门框内壁侧面自然露出并吃侧光。
     */
    addBeveledFrame(
        openX0: number,
        openX1: number,
        y0: number,
        openY1: number,
        pillarW: number,
        lintelH: number,
        z0: number,
        z1: number,
        mat: LowpolyMaterial,
        opts: {
            bucket?: LowpolyBucket;
            opacity?: number;
            innerRimLight?: RGBA;
            innerRimStrength?: number;
            sortBias?: number;
        } = {},
    ): void {
        const bucket = opts.bucket ?? LP_BUCKET.MIDGROUND;
        const opacity = opts.opacity ?? 1;
        const bias = opts.sortBias ?? 0;

        // 左门柱（其右侧面即为门洞左内壁，能承接方向侧光）
        this.addBox({
            x0: openX0 - pillarW,
            x1: openX0,
            y0,
            y1: openY1 + lintelH,
            z0,
            z1,
            material: mat,
            bucket,
            sortBias: bias,
            opacity,
            highlightTopEdge: true,
        });
        // 右门柱（其左侧面即为门洞右内壁）
        this.addBox({
            x0: openX1,
            x1: openX1 + pillarW,
            y0,
            y1: openY1 + lintelH,
            z0,
            z1,
            material: mat,
            bucket,
            sortBias: bias,
            opacity,
            highlightTopEdge: true,
        });
        // 门楣横梁（底面在视点上方时会显露厚重石楣下壁）
        this.addBox({
            x0: openX0 - pillarW * 0.2,
            x1: openX1 + pillarW * 0.2,
            y0: openY1,
            y1: openY1 + lintelH,
            z0,
            z1,
            material: mat,
            bucket,
            sortBias: bias + 0.05,
            opacity,
            highlightTopEdge: true,
        });

        // 门框内壁光擦亮带（风台 6s 视觉焦点：一缕冷月侧光擦过门框内壁立体面）
        const rimAlpha = (opts.innerRimStrength ?? 0) * clamp01(this.proj.morph) * opacity;
        if (rimAlpha > 0.02) {
            const rimCol = opts.innerRimLight ?? rgba(226, 236, 246, 255);
            const p0 = this.project(openX0, y0 + 2, z0);
            const p1 = this.project(openX0, y0 + 2, z1);
            const p2 = this.project(openX0, openY1 - 2, z1);
            const p3 = this.project(openX0, openY1 - 2, z0);
            const cNear = toColor(rimCol, Math.round(135 * rimAlpha));
            const cFar = toColor(rimCol, Math.round(28 * rimAlpha));
            this.glows.push({
                pts: [p0, p1, p2, p3],
                cols: [cNear, cFar, cFar, cNear],
            });
        }
    }

    /** 3D 立体石阶（直接兼容 rooms.ts 的 StairSpec，逐级绘制亮踏面、暗踢面与露出的踏步侧面） */
    addStairFlight(
        stair: StairSpec,
        z0: number,
        z1: number,
        mat: LowpolyMaterial = MING_MATERIALS.mingStoneStep,
        opts: { bucket?: LowpolyBucket; opacity?: number; sortBias?: number; baseY?: number } = {},
    ): void {
        const n = Math.max(1, stair.steps + 1);
        const stepW = (stair.x1 - stair.x0) / n;
        const floorY = opts.baseY !== undefined ? opts.baseY : Math.min(stair.y0, stair.y1);
        const bucket = opts.bucket ?? LP_BUCKET.WALK_DECK;
        const opacity = opts.opacity ?? 1;
        const bias = opts.sortBias ?? 0;

        let k = 0;
        for (k = 0; k < n; k++) {
            const wy = n === 1 ? stair.y1 : stair.y0 + (stair.y1 - stair.y0) * k / (n - 1);
            const wx0 = stair.x0 + stepW * k;
            const wx1 = wx0 + stepW;
            if (wy <= floorY + 1) {
                continue;
            }
            this.addBox({
                x0: wx0,
                x1: wx1,
                y0: floorY,
                y1: wy,
                z0,
                z1,
                material: mat,
                bucket,
                sortBias: bias + k * 0.01,
                opacity,
                highlightTopEdge: true,
                edgeWidth: 0.9,
            });
        }
    }

    /**
     * 3D 木栈台铺板与板缝（将 [z0..z1] 切分为多条带微缝的木板，含木梁支撑）：
     * 当 z0 < 0 时前景木板向观众侧伸展，自然遮挡 z > 0 的后排石阶一角。
     */
    addPlankDeck(
        x0: number,
        x1: number,
        topY: number,
        z0: number,
        z1: number,
        plankCount: number,
        thickness: number,
        mat: LowpolyMaterial = MING_MATERIALS.mingTimber,
        opts: {
            bucket?: LowpolyBucket;
            opacity?: number;
            sortBias?: number;
            withPosts?: boolean;
            postBottomY?: number;
        } = {},
    ): void {
        const count = Math.max(1, Math.floor(plankCount));
        const bucket = opts.bucket ?? LP_BUCKET.WALK_DECK;
        const opacity = opts.opacity ?? 1;
        const bias = opts.sortBias ?? 0;
        const spanZ = Math.max(1, z1 - z0);
        const gap = Math.min(2.6, spanZ / (count * 6));
        const plankDepth = (spanZ - gap * (count - 1)) / count;

        // 栈台下方粗木托柱（若开启）
        if (opts.withPosts === true) {
            const postBot = opts.postBottomY ?? (topY - 92);
            const postMat = MING_MATERIALS.mingTimberDark;
            const postCount = Math.max(2, Math.min(5, Math.floor((x1 - x0) / 110) + 1));
            let pi = 0;
            for (pi = 0; pi < postCount; pi++) {
                const px = x0 + 18 + ((x1 - x0 - 36) * pi) / Math.max(1, postCount - 1);
                this.addBox({
                    x0: px - 6,
                    x1: px + 6,
                    y0: postBot,
                    y1: topY - thickness,
                    z0: z0 + 4,
                    z1: z0 + 18,
                    material: postMat,
                    bucket,
                    sortBias: bias - 0.3,
                    opacity,
                    edgeWidth: 0.7,
                });
            }
        }

        // 逐条铺设木板（明暗微交替，增强灰度与透视板缝节奏）
        let i = 0;
        for (i = 0; i < count; i++) {
            const pz0 = z0 + i * (plankDepth + gap);
            const pz1 = pz0 + plankDepth;
            const plankMat: LowpolyMaterial = (i & 1) === 0
                ? mat
                : {
                    base: scaleRGBA(mat.base, 0.88),
                    edge: mat.edge,
                    minShade: mat.minShade,
                    rimBoost: mat.rimBoost,
                    bottomAo: mat.bottomAo,
                };
            this.addBox({
                x0,
                x1,
                y0: topY - thickness,
                y1: topY,
                z0: pz0,
                z1: pz1,
                material: plankMat,
                bucket,
                sortBias: bias + (count - i) * 0.01,
                opacity,
                highlightTopEdge: i === 0,
                edgeWidth: 0.8,
            });
        }
    }

    /** 雾中远山 / 远城脊线（低模三角面分割，区分受光坡与背光坡） */
    addDistantRidge(
        peaks: { x: number; y: number }[],
        baseY: number,
        z: number,
        mat: LowpolyMaterial = MING_MATERIALS.distantHill,
        opts: { bucket?: LowpolyBucket; opacity?: number; sortBias?: number } = {},
    ): void {
        if (peaks.length < 2) {
            return;
        }
        const bucket = opts.bucket ?? LP_BUCKET.BACKDROP;
        const opacity = opts.opacity ?? 1;
        const bias = opts.sortBias ?? 0;

        let i = 0;
        for (i = 0; i < peaks.length - 1; i++) {
            const a = peaks[i];
            const b = peaks[i + 1];
            const midX = (a.x + b.x) * 0.5;
            const midY = Math.min(a.y, b.y) - Math.abs(b.y - a.y) * 0.25;
            const ridgeMat: LowpolyMaterial = b.y >= a.y
                ? mat
                : {
                    base: scaleRGBA(mat.base, 0.84),
                    edge: mat.edge,
                    minShade: mat.minShade,
                    rimBoost: mat.rimBoost,
                    bottomAo: mat.bottomAo,
                };
            this.addTri3D(
                vec3(a.x, baseY, z),
                vec3(b.x, baseY, z),
                vec3(a.x, a.y, z),
                ridgeMat,
                { bucket, sortBias: bias, opacity, edgeWidth: 0 },
            );
            this.addTri3D(
                vec3(b.x, baseY, z),
                vec3(b.x, b.y, z),
                vec3(a.x, a.y, z),
                ridgeMat,
                { bucket, sortBias: bias + 0.01, opacity, edgeWidth: 0 },
            );
            // 山脊微暗切面，呈现经典低模棱角
            this.addTri3D(
                vec3(midX, Math.max(baseY, midY), z - 8),
                vec3(b.x, baseY, z),
                vec3(b.x, b.y, z),
                { base: scaleRGBA(mat.base, 0.78), minShade: 0.3, bottomAo: 0.2 },
                { bucket, sortBias: bias + 0.02, opacity: opacity * 0.85 },
            );
        }
    }

    /** 深度排序的体积雾幕（夹在远山、远墙与近景栈台之间） */
    addFogBand(
        x0: number,
        x1: number,
        y0: number,
        y1: number,
        z: number,
        color: RGBA,
        bottomAlpha: number,
        topAlpha: number,
        opts: { bucket?: LowpolyBucket; sortBias?: number } = {},
    ): void {
        const m = clamp01(this.proj.morph);
        const ba = clamp01(bottomAlpha * m);
        const ta = clamp01(topAlpha * m);
        if (ba <= 0.008 && ta <= 0.008) {
            return;
        }
        const p0 = this.project(x0, y0, z);
        const p1 = this.project(x1, y0, z);
        const p2 = this.project(x1, y1, z);
        const p3 = this.project(x0, y1, z);
        const cBot = toColor(color, Math.round(255 * ba));
        const cTop = toColor(color, Math.round(255 * ta));
        this.faces.push({
            bucket: opts.bucket ?? LP_BUCKET.BACKDROP,
            sortZ: z,
            sortBias: opts.sortBias ?? 0.5,
            pts: [p0, p1, p2, p3],
            cols: [cBot, cBot, cTop, cTop],
            edgeCol: undefined,
            edgeWidth: 0,
            topHighlight: undefined,
        });
    }

    /** 斜射方向体积光束（汇入加法混合 glow 层） */
    addLightShaft(
        topX0: number,
        topX1: number,
        topY: number,
        botX0: number,
        botX1: number,
        botY: number,
        z: number,
        color: RGBA,
        topAlpha: number,
        botAlpha: number,
    ): void {
        const ta = clamp01(topAlpha);
        const ba = clamp01(botAlpha);
        if (ta <= 0.005 && ba <= 0.005) {
            return;
        }
        const p0 = this.project(botX0, botY, z);
        const p1 = this.project(botX1, botY, z);
        const p2 = this.project(topX1, topY, z);
        const p3 = this.project(topX0, topY, z);
        const cTop = toColor(color, Math.round(255 * ta));
        const cBot = toColor(color, Math.round(255 * ba));
        this.glows.push({
            pts: [p0, p1, p2, p3],
            cols: [cBot, cBot, cTop, cTop],
        });
    }

    /**
     * 2D 角色/道具脚底接触影（严格贴合 wz = 0 走面）：
     * 外层柔影 + 内层浓核 + 方向拉长投射影，令二维角色稳稳踩在低模平面上。
     */
    addContactShadow(
        wx: number,
        wy: number,
        radiusX: number,
        radiusZ: number,
        opacity: number = 0.72,
        opts: { bucket?: LowpolyBucket; sortBias?: number; castDirX?: number } = {},
    ): void {
        const op = clamp01(opacity);
        if (op <= 0.01) {
            return;
        }
        const bucket = opts.bucket ?? LP_BUCKET.PROP;
        const bias = opts.sortBias ?? 0.2;
        const m = clamp01(this.proj.morph);
        const castShiftX = (opts.castDirX ?? -this.light.keyDir.x) * radiusX * (0.28 + 0.42 * m);

        // 1. 方向拉伸地面投射影（沿 wz 方向贴走面展开）
        const segs = 10;
        const outerZ = Math.max(4, radiusZ * (0.55 + 0.65 * m));
        const centerP = this.project(wx + castShiftX * 0.45, wy + 0.4, outerZ * 0.15);
        const innerCol = Color(7, 9, 14, Math.round(145 * op * (0.55 + 0.45 * m)));
        const outerCol = Color(7, 9, 14, 0);
        let i = 0;
        for (i = 0; i < segs; i++) {
            const a0 = (i / segs) * Math.PI * 2;
            const a1 = ((i + 1) / segs) * Math.PI * 2;
            const pA = this.project(
                wx + castShiftX * 0.45 + Math.cos(a0) * radiusX * 1.42,
                wy + 0.4,
                outerZ * 0.15 + Math.sin(a0) * outerZ,
            );
            const pB = this.project(
                wx + castShiftX * 0.45 + Math.cos(a1) * radiusX * 1.42,
                wy + 0.4,
                outerZ * 0.15 + Math.sin(a1) * outerZ,
            );
            this.faces.push({
                bucket,
                sortZ: 0.05,
                sortBias: bias,
                pts: [centerP, pA, pB],
                cols: [innerCol, outerCol, outerCol],
                edgeCol: undefined,
                edgeWidth: 0,
                topHighlight: undefined,
            });
        }

        // 2. 紧贴脚底的深色接触核心（wz = 0，保证脚跟永不悬空）
        const footP = this.project(wx, wy + 0.5, 0);
        const coreRx = this.cam.len(radiusX * 0.78);
        const coreRy = Math.max(2.5, this.cam.len(Math.max(2.4, radiusZ * 0.24)));
        const coreIn = Color(5, 7, 12, Math.round(210 * op));
        const coreOut = Color(5, 7, 12, Math.round(32 * op));
        const coreSegs = 8;
        for (i = 0; i < coreSegs; i++) {
            const a0 = (i / coreSegs) * Math.PI * 2;
            const a1 = ((i + 1) / coreSegs) * Math.PI * 2;
            this.faces.push({
                bucket,
                sortZ: 0.01,
                sortBias: bias + 0.05,
                pts: [
                    footP,
                    { x: footP.x + Math.cos(a0) * coreRx, y: footP.y + Math.sin(a0) * coreRy, scale: 1, zEff: 0 },
                    { x: footP.x + Math.cos(a1) * coreRx, y: footP.y + Math.sin(a1) * coreRy, scale: 1, zEff: 0 },
                ],
                cols: [coreIn, coreOut, coreOut],
                edgeCol: undefined,
                edgeWidth: 0,
                topHighlight: undefined,
            });
        }
    }

    /**
     * 将位于角色前方（wz < 0）的前景遮挡体通过 worldArt 高 layer 放置：
     * 严格排在角色精灵（order ~4101）之前、HUD（uiLayer）之后。
     */
    placeForegroundOccluder(
        worldArt: AssetSlotHost,
        slotKey: AssetSlotKey | string,
        instanceKey: string,
        x0: number,
        x1: number,
        y0: number,
        y1: number,
        wz: number,
        opts: { color?: Color.Type; opacity?: number; layer?: number } = {},
    ): boolean {
        const pBL = this.project(x0, y0, wz);
        const pTR = this.project(x1, y1, wz);
        const w = Math.abs(pTR.x - pBL.x);
        const h = Math.abs(pTR.y - pBL.y);
        if (w < 1 || h < 1) {
            return false;
        }
        return worldArt.tryPlace(
            slotKey,
            instanceKey,
            (pBL.x + pTR.x) * 0.5,
            Math.min(pBL.y, pTR.y),
            w,
            h,
            {
                color: opts.color ?? Color(28, 32, 42, 255),
                opacity: opts.opacity ?? 0.92,
                layer: opts.layer ?? 5200,
            },
        );
    }

    /** 按真深度顺序刷出全部低模面与方向体积光 */
    flush(draw: DrawNode.Type, glowDraw?: DrawNode.Type): void {
        if (this.faces.length > 1) {
            this.faces.sort((a, b) => {
                if (a.bucket !== b.bucket) {
                    return a.bucket - b.bucket;
                }
                if (Math.abs(a.sortZ - b.sortZ) > 0.001) {
                    return b.sortZ - a.sortZ;
                }
                return a.sortBias - b.sortBias;
            });
        }

        let i = 0;
        for (i = 0; i < this.faces.length; i++) {
            const f = this.faces[i];
            if (f.pts.length === 3) {
                draw.drawVertices([
                    [Vec2(f.pts[0].x, f.pts[0].y), f.cols[0]],
                    [Vec2(f.pts[1].x, f.pts[1].y), f.cols[1]],
                    [Vec2(f.pts[2].x, f.pts[2].y), f.cols[2]],
                ]);
            } else if (f.pts.length === 4) {
                const v0 = Vec2(f.pts[0].x, f.pts[0].y);
                const v1 = Vec2(f.pts[1].x, f.pts[1].y);
                const v2 = Vec2(f.pts[2].x, f.pts[2].y);
                const v3 = Vec2(f.pts[3].x, f.pts[3].y);
                draw.drawVertices([
                    [v0, f.cols[0]],
                    [v1, f.cols[1]],
                    [v2, f.cols[2]],
                ]);
                draw.drawVertices([
                    [v0, f.cols[0]],
                    [v2, f.cols[2]],
                    [v3, f.cols[3]],
                ]);
            }
            if (f.edgeCol !== undefined && f.edgeWidth > 0) {
                const count = f.pts.length;
                let k = 0;
                for (k = 0; k < count; k++) {
                    const a = f.pts[k];
                    const b = f.pts[(k + 1) % count];
                    draw.drawSegment(Vec2(a.x, a.y), Vec2(b.x, b.y), f.edgeWidth * 0.5, f.edgeCol);
                }
            }
            if (f.topHighlight !== undefined) {
                const hl = f.topHighlight;
                draw.drawSegment(Vec2(hl[0].x, hl[0].y), Vec2(hl[1].x, hl[1].y), 1.15, hl[2]);
            }
        }

        if (glowDraw !== undefined && this.glows.length > 0) {
            for (i = 0; i < this.glows.length; i++) {
                const g = this.glows[i];
                if (g.pts.length === 4) {
                    const v0 = Vec2(g.pts[0].x, g.pts[0].y);
                    const v1 = Vec2(g.pts[1].x, g.pts[1].y);
                    const v2 = Vec2(g.pts[2].x, g.pts[2].y);
                    const v3 = Vec2(g.pts[3].x, g.pts[3].y);
                    glowDraw.drawVertices([
                        [v0, g.cols[0]],
                        [v1, g.cols[1]],
                        [v2, g.cols[2]],
                    ]);
                    glowDraw.drawVertices([
                        [v0, g.cols[0]],
                        [v2, g.cols[2]],
                        [v3, g.cols[3]],
                    ]);
                }
            }
        }

        this.faces = [];
        this.glows = [];
    }
}

/**
 * 复用级低模栈台构建器（同时服务 M1 城外栈台小幅侧移验收 与 Wave 2 fe-04 `outside` 房间）：
 * 直接读取 RoomSpec 的 floors / stairs / solids / arch 真实世界坐标生成 3D 几何体，
 * 保证木板前后遮挡、踏步侧面、拱洞内壁与 wz = 0 碰撞/车柄落点严丝合缝。
 */
export function buildOutsideJettyLowpoly(
    scene: LowpolyScene,
    room: RoomSpec,
    actorX: number,
    actorY: number,
    cartAxle: number,
    time: number,
): void {
    // 1. 远景海滨山脊与宁村所外城墙轮廓
    scene.addDistantRidge(
        [
            { x: room.minX - 180, y: 125 },
            { x: room.minX + 120, y: 196 },
            { x: room.minX + 420, y: 162 },
            { x: room.minX + 760, y: 224 },
            { x: room.maxX + 220, y: 150 },
        ],
        -40,
        420,
        MING_MATERIALS.distantHill,
        { bucket: LP_BUCKET.BACKDROP },
    );
    scene.addFogBand(room.minX - 240, room.maxX + 240, -30, 175, 290, scene.light.fogColor, 0.56, 0.04, {
        bucket: LP_BUCKET.BACKDROP,
    });

    // 2. 底层主走面与城墙外立面
    let i = 0;
    for (i = 0; i < room.floors.length; i++) {
        const fl = room.floors[i];
        const isMain = fl.y <= 0.1;
        if (isMain) {
            scene.addBox({
                x0: fl.x0,
                x1: fl.x1,
                y0: -48,
                y1: fl.y,
                z0: -26,
                z1: 88,
                material: MING_MATERIALS.mingBrickDark,
                bucket: LP_BUCKET.MIDGROUND,
                highlightTopEdge: true,
            });
        } else {
            // 上层栈台铺木板（前景木板 z0 = -24 探出，自然遮挡后排石阶 z = 14..78）
            scene.addPlankDeck(fl.x0, fl.x1, fl.y, -24, 52, 5, 11, MING_MATERIALS.mingTimber, {
                bucket: LP_BUCKET.WALK_DECK,
                withPosts: true,
                postBottomY: 0,
            });
        }
    }

    // 3. 真 3D 踏步石阶（位于后排 z = 14..76，侧移时踏步侧面与近处木板遮挡清晰可见）
    for (i = 0; i < room.stairs.length; i++) {
        scene.addStairFlight(room.stairs[i], 14, 76, MING_MATERIALS.mingStoneStep, {
            bucket: LP_BUCKET.MIDGROUND,
            baseY: 0,
        });
    }

    // 4. 城墙实体块（对悬空城墙 y > 0 在后景 z=34..72 增补落地砖拱墩，消除悬浮灰块感且不挡底层通行）
    for (i = 0; i < room.solids.length; i++) {
        const s = room.solids[i];
        scene.addBox({
            x0: s.x,
            x1: s.x + s.w,
            y0: s.y,
            y1: s.y + s.h,
            z0: -8,
            z1: 72,
            material: MING_MATERIALS.mingBrick,
            bucket: LP_BUCKET.MIDGROUND,
            highlightTopEdge: true,
        });
        if (s.y > 10) {
            scene.addBox({
                x0: s.x,
                x1: s.x + 18,
                y0: 0,
                y1: s.y,
                z0: 32,
                z1: 72,
                material: MING_MATERIALS.mingBrickDark,
                bucket: LP_BUCKET.MIDGROUND,
                sortBias: -0.08,
                edgeWidth: 0.7,
            });
            scene.addBox({
                x0: s.x + s.w - 18,
                x1: s.x + s.w,
                y0: 0,
                y1: s.y,
                z0: 32,
                z1: 72,
                material: MING_MATERIALS.mingBrickDark,
                bucket: LP_BUCKET.MIDGROUND,
                sortBias: -0.08,
                edgeWidth: 0.7,
            });
        }
    }

    // 5. 下层矮石拱洞（保留 44 世界单位真实净空，不加垂布遮挡）
    const arch = room.arch;
    if (arch.h > 0 && arch.x1 > arch.x0) {
        scene.addBeveledFrame(arch.x0, arch.x1, arch.y, arch.y + arch.h, 22, 18, -10, 64, MING_MATERIALS.mingStoneStep, {
            bucket: LP_BUCKET.WALK_DECK,
            innerRimLight: rgba(176, 206, 228, 255),
            innerRimStrength: 0.45,
        });
    }

    // 6. 栈台红布车投影底座影与随风飘动的左端旧红布（固定在车身左端，不翻面）
    const c = room.cart;
    if (c.bodyW > 0) {
        scene.addContactShadow(cartAxle, c.baseY, c.bodyW * 0.62, 14, 0.70, { bucket: LP_BUCKET.PROP });
        const clothX = cartAxle - c.bodyW * 0.5;
        const clothTop = c.baseY + c.wheelR * 1.05 + c.bodyH;
        const sway = Math.sin(time * 3.1) * 5.5;
        scene.addTri3D(
            vec3(clothX, clothTop, -4),
            vec3(clothX + 9, clothTop, -4),
            vec3(clothX - 5 + sway, clothTop - 22, -6),
            MING_MATERIALS.mingRedCloth,
            { bucket: LP_BUCKET.PROP, sortBias: 0.4, edgeWidth: 0.9 },
        );
    }

    // 7. 小满脚底接触影（严格贴合 wz = 0）
    scene.addContactShadow(actorX, actorY, 15, 11, 0.78, { bucket: LP_BUCKET.PROP, sortBias: 0.5 });
}
