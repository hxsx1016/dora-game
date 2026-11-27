/**
 * 《向西守望》Wave 1 · FE-02：第三段安全武器工台与首次试握动画插件（M02）。
 *
 * 核心设计约束：
 * 1. 与序章军粮棚同尺度、同灯光的明朝木案像素风界面：
 *    - 保留上方世界全景（周戍与落地的小满同框，同世界 ppu 尺度），仅在中下方推开明朝旧木案台面与提灯暖光；
 * 2. 桌边材料排布 + 两份武器方案 + 增强连线纹样预览：
 *    - 桌左逐枚实物排布持有筹码（木纹筹 / 铃纹筹），案右并列「引路灯铳」（强化灯纹）与「回声铳」（强化铃纹）；
 *    - 方案卡内嵌与 reload_wheel.ts 同源的迷你 3×3 路径与纹样预览（静音/灰度可辨）；
 * 3. 严格状态口径与幂等防重：
 *    - 库存不足立即高亮缺项并反馈空木声，不提交请求；取消保留全部材料；
 *    - 确认仅发一次带唯一 requestId 的 craftSubmit 请求，不预扣本地库存，收到后端快照确认结果后才更新持有物与试握；
 *    - 首次制成播放约 1 秒试握动画（小满递到哥哥惯用手一侧 → 周戍试握 → 她松手 → 接回全身景并可立刻装备）；
 *    - 重复制作仅播短递交动作（0.45 秒）；读档/切房按快照完整还原。
 */

import { Color, DrawNode, Keyboard, KeyName, Mouse, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { ZERO_SAFE_INSETS } from "Script/watch/platform";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { keyTagFor } from "Script/watch/fe/ui/control_prompts";
import {
    CraftRecipeView,
    DualRouteContract,
    DualRouteSnapshot,
    FrontendIntent,
    ReloadEffectKind,
} from "Script/watch/fe/contract";
import { FePluginContext, FeRenderPlugin } from "Script/watch/fe/plugins";
import { CUFF_PALETTE } from "Script/watch/fe/cutscenes/cuff_shots";
import {
    RELOAD_GRID,
    drawReloadPatternGlyph,
} from "Script/watch/fe/ui/reload_wheel";
import {
    PALETTE,
    RGBA,
    drawBlossomDot,
    drawFiligreeCorners,
    drawHairline,
    drawSilkRibbon,
    drawSilkVeil,
    fillRadialGlow,
    fillVGradRect,
    toColor,
} from "Script/watch/fe/theme";

const MATERIAL_NAMES: Record<string, string> = {
    wood: "木纹筹",
    bell: "铃纹筹",
    wood_tally: "木纹筹",
    bell_tally: "铃纹筹",
    scrap: "旧木料",
    wedge: "木楔",
    ammo: "备用弹",
};

const WOOD_TOP = Color(98, 68, 48, 252);
const WOOD_BODY = Color(58, 40, 30, 250);
const WOOD_EDGE = Color(152, 114, 82, 235);
const WOOD_DARK = Color(30, 21, 17, 248);

export interface CraftBenchDebugState {
    active: boolean;
    selectedIndex: number;
    pendingRecipeId: string;
    missingFlashT: number;
    missingMaterials: string[];
    handoverActive: boolean;
    handoverDuration: number;
    handoverRemaining: number;
    handoverWeaponId: string;
    equippedWeapon: string;
    inventory: Record<string, number>;
    craftedIds: string[];
}

interface SimulatedBenchInput {
    pointerX?: number;
    pointerY?: number;
    click?: boolean;
    rightClick?: boolean;
    move?: number;
    confirm?: boolean;
    cancel?: boolean;
}

function materialLabel(key: string): string {
    return MATERIAL_NAMES[key] ?? key;
}

function resolveRuntimeContract(injected?: DualRouteContract): DualRouteContract | undefined {
    if (injected !== undefined) {
        return injected;
    }
    const g = globalThis as unknown as { package?: { loaded?: Record<string, unknown> } };
    const loaded = g.package !== undefined ? g.package.loaded : undefined;
    if (loaded === undefined) {
        return undefined;
    }
    const feHook = loaded["watch.fe"];
    if (feHook !== undefined && typeof feHook === "object") {
        const c = (feHook as Record<string, unknown>)["contract"];
        if (c !== undefined && typeof c === "object") {
            return c as DualRouteContract;
        }
    }
    return undefined;
}

function dispatchIntentFallback(p: Play, intent: FrontendIntent): boolean {
    const rec = p as unknown as Record<string, unknown>;
    const handler = rec["submitFeIntent"];
    if (typeof handler === "function") {
        return (handler as (self: Play, req: FrontendIntent) => unknown)(p, intent) !== false;
    }
    return false;
}

function collectMissingMaterials(
    recipe: CraftRecipeView,
    inventory: Record<string, number>,
): string[] {
    const missing: string[] = [];
    for (const mat in recipe.cost) {
        const need = recipe.cost[mat];
        const have = inventory[mat] ?? 0;
        if (have < need) {
            missing.push(mat);
        }
    }
    return missing;
}

function sortedMaterialKeys(
    inventory: Record<string, number>,
    recipes: readonly CraftRecipeView[],
): string[] {
    const seen: Record<string, boolean> = {};
    const out: string[] = [];
    // 优先按当前配方实际消耗键顺序呈现（自动兼容 B2 后端 wood/bell 与排演态 wood_tally/bell_tally，避免双排重复）
    const prefer: string[] = ["wood", "bell", "wood_tally", "bell_tally"];
    let hasBackendKeys = inventory["wood"] !== undefined || inventory["bell"] !== undefined;
    let i = 0;
    for (i = 0; i < recipes.length; i++) {
        if (recipes[i].cost["wood"] !== undefined || recipes[i].cost["bell"] !== undefined) {
            hasBackendKeys = true;
        }
    }
    const primary = hasBackendKeys ? ["wood", "bell"] : ["wood_tally", "bell_tally"];
    for (i = 0; i < primary.length; i++) {
        seen[primary[i]] = true;
        out.push(primary[i]);
    }
    for (i = 0; i < recipes.length; i++) {
        const cost = recipes[i].cost;
        for (const k in cost) {
            if (!seen[k]) {
                seen[k] = true;
                out.push(k);
            }
        }
    }
    for (i = 0; i < prefer.length; i++) {
        const k = prefer[i];
        if (!seen[k] && inventory[k] !== undefined && inventory[k] > 0) {
            seen[k] = true;
            out.push(k);
        }
    }
    return out;
}

export class CraftBenchPlugin implements FeRenderPlugin {
    readonly id = "fe-02-craft-bench";

    private injectedContract: DualRouteContract | undefined;

    private wasActive = false;
    private selectedIdx = 0;
    private animTime = 0;
    private openAnimT = 0;

    // 幂等制作提交保护
    private requestSeq = 0;
    private pendingRecipeId = "";
    private pendingFirstCraftAtSubmit = true;
    private prevCraftedMap: Record<string, boolean> = {};

    // 缺料反馈
    private missingFlashT = 0;
    private missingList: string[] = [];

    // 首次试握 / 短递交动画（首制 1.0s，续制 0.45s）
    private handoverRemaining = 0;
    private handoverDuration = 1.0;
    private handoverWeaponId = "";
    private handoverWeaponName = "";
    private handoverEffect: ReloadEffectKind = "light";

    // 输入边沿状态（防 app.ts clearEdges 丢边沿）
    private prevLeft = false;
    private prevRight = false;
    private prevLeftKey = false;
    private prevRightKey = false;
    private prevConfirm = false;
    private prevCancel = false;
    private pointerActive = false;

    // 布局缓存（供点击命中与测试定位）
    private cardBoxes: Rect.Type[] = [];
    private closeBox: Rect.Type = Rect(0, 0, 0, 0);
    private lastSnapshotBench: DualRouteSnapshot["craftBench"] | undefined;
    private pendingSimInput: SimulatedBenchInput | undefined;

    constructor(contract?: DualRouteContract) {
        this.injectedContract = contract;
    }

    /** 供自动化验证脚本按帧注入键鼠动作 */
    injectInputForTest(sim: SimulatedBenchInput): void {
        this.pendingSimInput = sim;
    }

    getState(): CraftBenchDebugState {
        const inv: Record<string, number> = {};
        const craftedIds: string[] = [];
        let equipped = "standard_gun";
        if (this.lastSnapshotBench !== undefined) {
            for (const k in this.lastSnapshotBench.inventory) {
                inv[k] = this.lastSnapshotBench.inventory[k];
            }
            let i = 0;
            for (i = 0; i < this.lastSnapshotBench.recipes.length; i++) {
                if (this.lastSnapshotBench.recipes[i].crafted) {
                    craftedIds.push(this.lastSnapshotBench.recipes[i].id);
                }
            }
            equipped = this.lastSnapshotBench.equippedWeapon;
        }
        return {
            active: this.wasActive,
            selectedIndex: this.selectedIdx,
            pendingRecipeId: this.pendingRecipeId,
            missingFlashT: this.missingFlashT,
            missingMaterials: this.missingList.slice(),
            handoverActive: this.handoverRemaining > 0,
            handoverDuration: this.handoverDuration,
            handoverRemaining: this.handoverRemaining,
            handoverWeaponId: this.handoverWeaponId,
            equippedWeapon: equipped,
            inventory: inv,
            craftedIds,
        };
    }

    onBindPlay(_p: Play, view: DualRouteSnapshot): void {
        // 切房或读档：完全以快照重建状态，清空所有本地瞬时态与提交锁
        this.wasActive = view.craftBench.active;
        this.selectedIdx = 0;
        this.animTime = 0;
        this.openAnimT = view.craftBench.active ? 1 : 0;
        this.pendingRecipeId = "";
        this.pendingFirstCraftAtSubmit = !view.craftBench.firstCraftDone;
        this.missingFlashT = 0;
        this.missingList = [];
        this.handoverRemaining = 0;
        this.handoverDuration = 1.0;
        this.handoverWeaponId = "";
        this.handoverWeaponName = "";
        this.pendingSimInput = undefined;
        this.syncCraftedSnapshot(view.craftBench);
        this.lastSnapshotBench = view.craftBench;
        this.resetInputEdges();
    }

    private syncCraftedSnapshot(bench: DualRouteSnapshot["craftBench"]): void {
        this.prevCraftedMap = {};
        let i = 0;
        for (i = 0; i < bench.recipes.length; i++) {
            this.prevCraftedMap[bench.recipes[i].id] = bench.recipes[i].crafted;
        }
    }

    private resetInputEdges(touchMode: boolean = false): void {
        this.prevLeft = !touchMode && typeof Mouse !== "undefined" ? Mouse.leftButtonPressed : false;
        this.prevRight = !touchMode && typeof Mouse !== "undefined" ? Mouse.rightButtonPressed : false;
        if (typeof Keyboard !== "undefined") {
            this.prevLeftKey = Keyboard.isKeyPressed(KeyName.A) || Keyboard.isKeyPressed(KeyName.Left);
            this.prevRightKey = Keyboard.isKeyPressed(KeyName.D) || Keyboard.isKeyPressed(KeyName.Right);
            this.prevConfirm = Keyboard.isKeyPressed(KeyName.Return) || Keyboard.isKeyPressed(KeyName.Space) || Keyboard.isKeyPressed(KeyName.E);
            this.prevCancel = Keyboard.isKeyPressed(KeyName.Escape) || Keyboard.isKeyPressed(KeyName.BackSpace);
        }
    }

    private submitIntent(p: Play, intent: FrontendIntent): boolean {
        const contract = resolveRuntimeContract(this.injectedContract);
        if (contract !== undefined) {
            return contract.submitIntent(p, intent);
        }
        return dispatchIntentFallback(p, intent);
    }

    private computeLayout(ctx: FePluginContext, recipeCount: number): {
        benchX: number;
        benchY: number;
        benchW: number;
        benchH: number;
        matW: number;
    } {
        const uiW = ctx.uiW;
        const uiH = ctx.uiH;
        const safe = ctx.safeUi ?? ZERO_SAFE_INSETS;
        const touchMode = ctx.input.isTouchMode();
        const count = Math.max(1, recipeCount);
        const wantW = count >= 3 ? 840 : 692;
        const benchW = Math.min(uiW - 44 - safe.left - safe.right, wantW);
        const benchH = 290;
        // 智能侧向停靠：避让画面中的周戍与落地小满，保持人物与木案同尺度同框可见
        const soldierUiX = ctx.cam.sx(ctx.p.player.x) / ctx.uiScale;
        const minX = 24 + safe.left;
        const maxX = Math.max(minX, uiW - benchW - 24 - safe.right);
        const benchX = count >= 3
            ? Math.max(minX, (uiW - benchW) * 0.5)
            : (soldierUiX < uiW * 0.52 ? maxX : minX);
        const benchY = Math.max(46 + safe.bottom, Math.min(uiH * 0.10 + safe.bottom, 66 + safe.bottom));
        const matW = count >= 3 ? 168 : 196;

        const cardsAreaX = benchX + matW + 16;
        const cardsAreaW = benchW - matW - 30;
        const gap = count >= 3 ? 10 : 14;
        const cardW = (cardsAreaW - gap * (count - 1)) / count;
        const cardH = benchH - 72;
        const cardY = benchY + 20;

        this.cardBoxes = [];
        let i = 0;
        for (i = 0; i < count; i++) {
            this.cardBoxes.push(Rect(cardsAreaX + i * (cardW + gap), cardY, cardW, cardH));
        }
        const closeW = touchMode ? 88 : 76;
        const closeH = touchMode ? 32 : 26;
        this.closeBox = Rect(benchX + benchW - closeW - 16, benchY + benchH - closeH - 12, closeW, closeH);
        return { benchX, benchY, benchW, benchH, matW };
    }

    update(ctx: FePluginContext): void {
        const bench = ctx.view.craftBench;
        this.lastSnapshotBench = bench;

        // 暂停态严格冻结所有计时与试握动画
        if (ctx.paused) {
            this.resetInputEdges(ctx.input.isTouchMode());
            return;
        }

        const udt = Math.max(0, ctx.uiDt);
        this.animTime += udt;

        if (this.missingFlashT > 0) {
            this.missingFlashT = Math.max(0, this.missingFlashT - udt);
        }
        if (this.handoverRemaining > 0) {
            this.handoverRemaining = Math.max(0, this.handoverRemaining - udt);
        }

        // 检测后端快照确认某件武器刚制成（仅在收到后端结果后触发试握与音效！）
        this.detectCraftCompletion(ctx, bench);

        if (bench.active && !this.wasActive) {
            this.openAnimT = 0;
            this.pendingRecipeId = "";
            this.missingFlashT = 0;
            this.missingList = [];
            this.selectedIdx = Math.max(0, Math.min(Math.max(0, bench.recipes.length - 1), this.selectedIdx));
            this.resetInputEdges(ctx.input.isTouchMode());
        } else if (!bench.active && this.wasActive) {
            this.pendingRecipeId = "";
            this.missingFlashT = 0;
        }
        this.wasActive = bench.active;

        if (!bench.active) {
            this.pendingSimInput = undefined;
            return;
        }

        this.openAnimT = Math.min(1, this.openAnimT + udt / 0.22);
        this.computeLayout(ctx, bench.recipes.length);

        // 试握动画播完前吞掉重复制作确认，防止连击误触发
        this.processInputs(ctx, bench);
    }

    private detectCraftCompletion(ctx: FePluginContext, bench: DualRouteSnapshot["craftBench"]): void {
        let newlyCrafted: CraftRecipeView | undefined;
        let i = 0;
        for (i = 0; i < bench.recipes.length; i++) {
            const r = bench.recipes[i];
            if (r.crafted && this.prevCraftedMap[r.id] !== true) {
                newlyCrafted = r;
            }
            this.prevCraftedMap[r.id] = r.crafted;
        }

        // 若后端发回 benchRejected，立即释放防重锁并触发缺料反馈
        for (i = 0; i < ctx.events.rawEvents.length; i++) {
            const ename = ctx.events.rawEvents[i].name as string;
            if (ename === "benchRejected") {
                this.pendingRecipeId = "";
                this.missingFlashT = 0.45;
            }
        }

        if (newlyCrafted !== undefined) {
            const isFirst = this.pendingRecipeId === newlyCrafted.id
                ? this.pendingFirstCraftAtSubmit
                : (bench.justCraftedTimer >= 0.72);
            this.pendingRecipeId = "";
            this.handoverWeaponId = newlyCrafted.id;
            this.handoverWeaponName = newlyCrafted.name;
            this.handoverEffect = newlyCrafted.enhancedEffect;
            this.handoverDuration = isFirst ? 1.0 : 0.45;
            this.handoverRemaining = this.handoverDuration;

            let hasBackendDone = false;
            for (i = 0; i < ctx.events.rawEvents.length; i++) {
                const ename = ctx.events.rawEvents[i].name as string;
                if (ename === "craftDone" || ename === "benchCraft") {
                    hasBackendDone = true;
                    break;
                }
            }
            if (!hasBackendDone) {
                ctx.audio.playOnce(
                    "fe02:craft_done:r" + ctx.events.roomSessionId + ":" + newlyCrafted.id,
                    "sfx",
                    "assets/audio/combat/craft_done.wav",
                    0.88,
                    "craft:done:" + newlyCrafted.id,
                    ctx.p.ticks,
                );
            }
        }
    }

    private processInputs(ctx: FePluginContext, bench: DualRouteSnapshot["craftBench"]): void {
        const sim = this.pendingSimInput;
        this.pendingSimInput = undefined;

        const touchMode = ctx.input.isTouchMode();
        const useUiPtr = sim?.pointerX === undefined
            && (ctx.input.uiHeld || ctx.input.uiPressed || ctx.input.uiReleased || (touchMode && ctx.input.uiInside));
        const ptrX = sim?.pointerX !== undefined
            ? sim.pointerX
            : ((useUiPtr ? ctx.input.uiX : ctx.input.mx) / ctx.uiScale);
        const ptrY = sim?.pointerY !== undefined
            ? sim.pointerY
            : ((useUiPtr ? ctx.input.uiY : ctx.input.my) / ctx.uiScale);
        const inside = sim?.pointerX !== undefined
            ? true
            : (useUiPtr ? ctx.input.uiInside : ctx.input.inside);
        const kbmMode = ctx.input.inputMode === "kbm";
        const leftHeld = sim?.click !== undefined
            ? sim.click
            : (ctx.input.uiHeld || ctx.input.fire.held || (kbmMode && typeof Mouse !== "undefined" && Mouse.leftButtonPressed));
        const rightHeld = sim?.rightClick !== undefined
            ? sim.rightClick
            : (ctx.input.uiRightPressed || (kbmMode && typeof Mouse !== "undefined" && Mouse.rightButtonPressed));

        const click = sim?.click !== undefined
            ? sim.click
            : (ctx.input.uiPressed || (leftHeld && !this.prevLeft));
        const rightClick = sim?.rightClick !== undefined
            ? sim.rightClick
            : (ctx.input.uiRightPressed || (rightHeld && !this.prevRight));
        this.prevLeft = leftHeld;
        this.prevRight = rightHeld;

        let move = 0;
        let confirm = false;
        let cancel = false;

        if (sim !== undefined && (sim.move !== undefined || sim.confirm !== undefined || sim.cancel !== undefined)) {
            move = sim.move ?? 0;
            confirm = sim.confirm === true;
            cancel = sim.cancel === true;
        } else {
            if (typeof Keyboard !== "undefined") {
                const lk = Keyboard.isKeyPressed(KeyName.A) || Keyboard.isKeyPressed(KeyName.Left);
                const rk = Keyboard.isKeyPressed(KeyName.D) || Keyboard.isKeyPressed(KeyName.Right);
                const cf = Keyboard.isKeyPressed(KeyName.Return) || Keyboard.isKeyPressed(KeyName.Space) || Keyboard.isKeyPressed(KeyName.E);
                const cc = Keyboard.isKeyPressed(KeyName.BackSpace);
                if (lk && !this.prevLeftKey) { move -= 1; }
                if (rk && !this.prevRightKey) { move += 1; }
                confirm = cf && !this.prevConfirm;
                cancel = cc && !this.prevCancel;
                this.prevLeftKey = lk;
                this.prevRightKey = rk;
                this.prevConfirm = cf;
                this.prevCancel = cc;
            }
            if (ctx.input.navLeft || ctx.input.navPrevTab) { move -= 1; }
            if (ctx.input.navRight || ctx.input.navNextTab) { move += 1; }
            if (ctx.input.navConfirm) { confirm = true; }
            if (ctx.input.navBack) { cancel = true; }
        }

        // 右键或点击「收起」取消工台：完整保留所有材料
        const ptr = Vec2(ptrX, ptrY);
        const hitClose = inside && this.closeBox.containsPoint(ptr);
        if (cancel || rightClick || (click && hitClose)) {
            this.submitIntent(ctx.p, { kind: "craftClose" });
            return;
        }

        const count = bench.recipes.length;
        if (count === 0) {
            return;
        }

        const rawDx = useUiPtr ? ctx.input.uiDx : ctx.input.mdx;
        const rawDy = useUiPtr ? ctx.input.uiDy : ctx.input.mdy;
        const pointerMoved = sim?.pointerX !== undefined
            || (!touchMode && inside && Math.abs(rawDx) + Math.abs(rawDy) >= ctx.uiScale);
        let hitCard = -1;
        if (inside) {
            let i = 0;
            for (i = 0; i < this.cardBoxes.length; i++) {
                if (this.cardBoxes[i].containsPoint(ptr)) {
                    hitCard = i;
                    break;
                }
            }
        }

        if (move !== 0) {
            this.pointerActive = false;
            this.selectedIdx = (this.selectedIdx + move + count) % count;
        } else if (pointerMoved && hitCard >= 0) {
            this.pointerActive = true;
            this.selectedIdx = hitCard;
        }

        const triggerConfirm = confirm || (click && hitCard >= 0);
        if (!triggerConfirm) {
            return;
        }
        if (click && hitCard >= 0) {
            this.selectedIdx = hitCard;
        }

        // 试握演出期间不接受二次确认，保证幂等与节拍完整
        if (this.handoverRemaining > 0.05) {
            return;
        }

        const recipe = bench.recipes[this.selectedIdx];
        if (recipe === undefined) {
            return;
        }

        if (recipe.crafted) {
            if (bench.equippedWeapon !== recipe.id) {
                this.submitIntent(ctx.p, { kind: "craftEquip", weaponId: recipe.id });
            }
            return;
        }

        // 幂等保护：同一方案已提交未回执时不重复提交
        if (this.pendingRecipeId === recipe.id) {
            return;
        }

        // 检查材料库存：不足即时高亮缺项并播空木反馈，绝不发送制作请求
        const missing = collectMissingMaterials(recipe, bench.inventory);
        if (missing.length > 0) {
            this.missingList = missing;
            this.missingFlashT = 0.55;
            ctx.audio.playOnce(
                "fe02:craft_lack:r" + ctx.events.roomSessionId + ":" + recipe.id + ":" + ctx.p.ticks,
                "sfx",
                "assets/audio/combat/craft_insufficient.wav",
                0.76,
                "craft:insufficient:" + recipe.id,
                ctx.p.ticks,
            );
            return;
        }

        this.missingList = [];
        this.missingFlashT = 0;
        this.pendingRecipeId = recipe.id;
        this.pendingFirstCraftAtSubmit = !bench.firstCraftDone;
        this.requestSeq += 1;
        const requestId = "craft:r" + ctx.events.roomSessionId + ":" + recipe.id + ":" + this.requestSeq;
        const accepted = this.submitIntent(ctx.p, {
            kind: "craftSubmit",
            requestId,
            recipeId: recipe.id,
        });
        if (!accepted) {
            this.pendingRecipeId = "";
        }
    }

    drawFullSpeedUi(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean {
        const bench = ctx.view.craftBench;
        if (!bench.active && this.handoverRemaining <= 0.01) {
            return false;
        }

        // 若工台已收起但仍在播首次试握收尾，仅绘试握演出并返回全身景
        if (!bench.active) {
            this.drawHandoverOverlay(uiDraw, uiInkDraw, uiArt, uiGlow, ctx);
            return false;
        }

        const appear = Math.min(1, this.openAnimT);
        const layout = this.computeLayout(ctx, bench.recipes.length);
        const bx = layout.benchX;
        const by = layout.benchY;
        const bw = layout.benchW;
        const bh = layout.benchH;

        // 1. 保留上方世界实景（周戍 + 落地小满同尺度同灯光），仅在底部轻压一层暖暗影托起木案
        fillVGradRect(
            uiDraw,
            0,
            0,
            ctx.uiW,
            by + bh + 64,
            Color(12, 10, 10, Math.round(168 * appear)),
            Color(12, 10, 10, 0),
        );

        // 2. 明朝军粮棚同尺度木案台面（暖褐旧木案面 + 磨亮木沿 + 左侧单盏提灯暖黄侧光）
        this.drawWoodenBenchBody(uiDraw, uiInkDraw, uiArt, uiGlow, bx, by, bw, bh, appear);

        // 案头题签与收起入口
        ctx.texts.put("md", "安全工台 · 改制鸟铳", bx + 54, by + bh - 26, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 2.0, 0.96 * appear, 0.08);
        drawHairline(uiInkDraw, uiArt, "cb_head_line", bx + bw * 0.5, by + bh - 46, bw - 36, PALETTE.amberDim, 0.55 * appear, false, 2);

        const hoverX = (ctx.input.uiInside ? ctx.input.uiX : ctx.input.mx) / ctx.uiScale;
        const hoverY = (ctx.input.uiInside ? ctx.input.uiY : ctx.input.my) / ctx.uiScale;
        const closeHover = (ctx.input.uiInside || ctx.input.inside) && this.closeBox.containsPoint(Vec2(hoverX, hoverY));
        uiInkDraw.drawRect(
            this.closeBox,
            Color(24, 18, 16, Math.round((closeHover ? 215 : 155) * appear)),
            0.9,
            toColor(closeHover ? PALETTE.amberCore : PALETTE.silkDim, 185 * appear),
        );
        const closeText = ctx.input.isGamepadMode()
            ? (keyTagFor("back", "gamepad", ctx.input.gamepadLayout) + " 收起")
            : "收起";
        ctx.texts.put(
            "xs",
            closeText,
            this.closeBox.x + this.closeBox.width * 0.5,
            this.closeBox.y + this.closeBox.height * 0.5,
            toColor(closeHover ? PALETTE.textBright : PALETTE.textMid),
            0.5,
            0.5,
            TextAlign.Center,
            1.4,
            0.95 * appear,
            0.06,
        );

        // 3. 案左：桌边排布持有材料（实物筹码 + 缺料高亮）
        this.drawTableMaterials(uiDraw, uiInkDraw, uiArt, ctx, bench, bx + 18, by + 22, layout.matW - 14, bh - 76, appear);

        // 4. 案右：两份武器方案（含同源 3×3 增强纹样预览）
        let i = 0;
        for (i = 0; i < bench.recipes.length && i < this.cardBoxes.length; i++) {
            this.drawRecipeCard(
                uiDraw,
                uiInkDraw,
                uiArt,
                uiGlow,
                ctx,
                bench,
                bench.recipes[i],
                this.cardBoxes[i],
                i === this.selectedIdx,
                appear,
            );
        }

        // 5. 首次制成 1 秒试握动画 / 二次短递交叠层
        if (this.handoverRemaining > 0.01) {
            this.drawHandoverOverlay(uiDraw, uiInkDraw, uiArt, uiGlow, ctx);
        }

        return true;
    }

    private drawWoodenBenchBody(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        bx: number,
        by: number,
        bw: number,
        bh: number,
        appear: number,
    ): void {
        // 木案主体（与序章军粮棚木柜同色温，叠铺明代旧木板纹理，非现代战术板）
        uiDraw.drawRect(Rect(bx, by, bw, bh), Color(WOOD_BODY.r, WOOD_BODY.g, WOOD_BODY.b, Math.round(244 * appear)), 1.4, toColor(PALETTE.amberDim, 190 * appear));
        uiArt.tryPlacePath("assets/art/tex_diorama_ming.clip|ming_timber", "cb_wood_tex", bx + bw * 0.5, by + bh * 0.5, bw - 4, bh - 12, {
            anchorX: 0.5,
            anchorY: 0.5,
            color: Color(172, 132, 98, 255),
            opacity: 0.34 * appear,
            smooth: true,
            layer: 0,
        });
        // 上沿厚木台板与磨亮边线
        uiDraw.drawRect(Rect(bx - 8, by + bh - 10, bw + 16, 14), Color(WOOD_TOP.r, WOOD_TOP.g, WOOD_TOP.b, Math.round(250 * appear)), 1.0, WOOD_EDGE);
        uiInkDraw.drawSegment(Vec2(bx - 6, by + bh + 3), Vec2(bx + bw + 6, by + bh + 3), 1.2, toColor(PALETTE.amberCore, 115 * appear));
        // 底部木案桌腿暗影
        uiDraw.drawRect(Rect(bx + 18, by - 26, 22, 26), Color(WOOD_DARK.r, WOOD_DARK.g, WOOD_DARK.b, Math.round(235 * appear)));
        uiDraw.drawRect(Rect(bx + bw - 40, by - 26, 22, 26), Color(WOOD_DARK.r, WOOD_DARK.g, WOOD_DARK.b, Math.round(235 * appear)));

        // 木纹细线画在 uiDraw 底层（在宣纸方案笺 uiArt 之下，绝不压过文字）
        let g = 1;
        for (g = 1; g <= 4; g++) {
            const gy = by + (bh - 50) * (g / 5);
            uiDraw.drawSegment(Vec2(bx + 10, gy), Vec2(bx + bw - 10, gy), 0.75, Color(34, 23, 18, Math.round(92 * appear)));
        }

        // 左上角明式提灯与军粮棚同色温暖黄侧光
        const lx = bx + 28;
        const ly = by + bh - 24;
        uiArt.tryPlace("prop_lantern", "cb_lantern", lx, ly, 20, 26, { opacity: 0.94 * appear, layer: 4 });
        const pulse = 0.88 + 0.12 * Math.sin(this.animTime * 2.8);
        fillRadialGlow(
            uiGlow,
            lx + 10,
            ly - 10,
            260 * pulse,
            180 * pulse,
            Color(238, 198, 128, Math.round(38 * appear)),
            Color(238, 180, 92, 0),
            16,
        );
    }

    private drawTableMaterials(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        ctx: FePluginContext,
        bench: DualRouteSnapshot["craftBench"],
        x: number,
        y: number,
        w: number,
        h: number,
        appear: number,
    ): void {
        uiDraw.drawRect(Rect(x, y, w, h), Color(26, 20, 17, Math.round(188 * appear)), 0.9, toColor(PALETTE.amberDim, 130 * appear));
        drawFiligreeCorners(uiInkDraw, uiArt, "cb_mat_frame", x + 3, y + 3, w - 6, h - 6, PALETTE.amberDim, 0.48 * appear, 16, false, 2);

        ctx.texts.put("xs", "案边持有", x + 12, y + h - 18, toColor(PALETTE.amberCore), 0, 0.5, TextAlign.Left, 1.4, 0.92 * appear, 0.06);
        uiInkDraw.drawSegment(Vec2(x + 10, y + h - 32), Vec2(x + w - 10, y + h - 32), 0.75, toColor(PALETTE.amberDim, 115 * appear));

        const keys = sortedMaterialKeys(bench.inventory, bench.recipes);
        let i = 0;
        for (i = 0; i < keys.length && i < 4; i++) {
            const mat = keys[i];
            const count = bench.inventory[mat] ?? 0;
            const isMissing = this.missingFlashT > 0.02 && this.missingList.indexOf(mat) >= 0;
            const shake = isMissing ? Math.sin(this.animTime * 54) * 3.5 : 0;
            const rowY = y + h - 62 - i * 48;

            if (isMissing) {
                uiDraw.drawRect(Rect(x + 6 + shake, rowY - 18, w - 12, 38), toColor(PALETTE.rougeSoft, 145 * appear), 1.0, toColor(PALETTE.crimsonCore, 220 * appear));
            }

            // 实物筹码排布（优先使用 props_ming.clip 手绘道具精灵，零几何矩形占位）
            const matClip = (mat === "bell_tally" || mat === "bell")
                ? "pickup_bell"
                : (mat === "scrap"
                    ? "pickup_scrap"
                    : (mat === "wedge" ? "pickup_wedge" : (mat === "ammo" ? "pickup_ammo" : "pickup_wood")));
            const shown = Math.max(1, Math.min(3, count));
            let t = 0;
            for (t = 0; t < shown; t++) {
                const tx = x + 22 + t * 19 + shake;
                const filled = t < count;
                if (uiArt.tryPlacePath("assets/art/props_ming.clip|" + matClip, "cb_mat_" + mat + "_" + t, tx, rowY, 20, 20, {
                    anchorX: 0.5,
                    anchorY: 0.5,
                    preserveAspect: true,
                    color: filled ? Color(255, 255, 255, 255) : Color(138, 134, 128, 255),
                    opacity: (filled ? 0.96 : 0.34) * appear,
                    layer: 3,
                })) {
                    continue;
                }
                if (mat === "bell_tally" || mat === "bell") {
                    drawReloadPatternGlyph(
                        uiInkDraw,
                        tx,
                        rowY,
                        7.5,
                        "echo",
                        filled ? PALETTE.amberCore : PALETTE.silkDim,
                        (filled ? 0.96 : 0.38) * appear,
                    );
                } else {
                    const col = filled ? PALETTE.amber : PALETTE.silkDim;
                    uiInkDraw.drawRect(
                        Rect(tx - 4, rowY - 10, 8, 20),
                        filled ? toColor(col, 195 * appear) : Color(0, 0, 0, 0),
                        1.0,
                        toColor(filled ? PALETTE.amberCore : PALETTE.silkDim, (filled ? 230 : 120) * appear),
                    );
                    if (filled) {
                        uiInkDraw.drawSegment(Vec2(tx - 2, rowY + 3), Vec2(tx + 2, rowY + 3), 0.9, toColor(PALETTE.xuanInk, 185 * appear));
                        uiInkDraw.drawSegment(Vec2(tx - 2, rowY - 3), Vec2(tx + 2, rowY - 3), 0.9, toColor(PALETTE.xuanInk, 185 * appear));
                    }
                }
            }

            ctx.texts.put(
                "xs",
                materialLabel(mat),
                x + 86 + shake,
                rowY + 5,
                toColor(isMissing ? PALETTE.crimsonCore : PALETTE.textBright),
                0,
                0.5,
                TextAlign.Left,
                0.8,
                0.95 * appear,
                0.06,
            );
            ctx.texts.put(
                "xs",
                "存 " + count,
                x + 86 + shake,
                rowY - 11,
                toColor(isMissing ? PALETTE.crimsonCore : (count > 0 ? PALETTE.amberCore : PALETTE.textDim)),
                0,
                0.5,
                TextAlign.Left,
                0.8,
                0.88 * appear,
                0.06,
            );
        }

        // 左下显示当前佩铳状态
        const eqName = this.resolveWeaponName(bench, bench.equippedWeapon);
        uiInkDraw.drawSegment(Vec2(x + 10, y + 32), Vec2(x + w - 10, y + 32), 0.75, toColor(PALETTE.amberDim, 105 * appear));
        ctx.texts.put("xs", "现佩：" + eqName, x + 12, y + 16, toColor(PALETTE.textMid), 0, 0.5, TextAlign.Left, 0.8, 0.90 * appear, 0.06);
    }

    private resolveWeaponName(bench: DualRouteSnapshot["craftBench"], weaponId: string): string {
        let i = 0;
        for (i = 0; i < bench.recipes.length; i++) {
            if (bench.recipes[i].id === weaponId) {
                return bench.recipes[i].name;
            }
        }
        return "旧制鸟铳";
    }

    private drawRecipeCard(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
        bench: DualRouteSnapshot["craftBench"],
        recipe: CraftRecipeView,
        box: Rect.Type,
        selected: boolean,
        appear: number,
    ): void {
        const missing = collectMissingMaterials(recipe, bench.inventory);
        const canCraft = !recipe.crafted && missing.length === 0;
        const equipped = bench.equippedWeapon === recipe.id;
        const isPending = this.pendingRecipeId === recipe.id;
        const highlightMissing = selected && this.missingFlashT > 0.02 && missing.length > 0;

        // 冷素宣纸方案笺
        if (!uiArt.tryPlace("ink_song_paper", "cb_card_" + recipe.id, box.x + box.width * 0.5, box.y + box.height * 0.5, box.width, box.height, { opacity: (selected ? 0.96 : 0.84) * appear, layer: 1 })) {
            uiDraw.drawRect(box, toColor(PALETTE.xuanPaper, (selected ? 242 : 212) * appear));
        }

        const borderCol = highlightMissing
            ? PALETTE.rouge
            : (selected ? PALETTE.xuanInk : PALETTE.xuanInkSub);
        drawFiligreeCorners(uiInkDraw, uiArt, "cb_cf_" + recipe.id, box.x + 5, box.y + 5, box.width - 10, box.height - 10, borderCol, (selected ? 0.88 : 0.46) * appear, 18, true, 2);

        if (selected) {
            drawSilkRibbon(uiDraw, uiArt, "cb_sel_rib_" + recipe.id, box.x + box.width * 0.5, box.y + box.height - 26, box.width - 14, 30, PALETTE.amberDim, 0.24 * appear, 2);
        }

        // 标题与状态微签
        const topY = box.y + box.height - 26;
        drawBlossomDot(uiInkDraw, uiArt, "cb_dot_" + recipe.id, box.x + 18, topY, selected ? 11 : 7, selected ? PALETTE.rouge : PALETTE.xuanInkSub, 0.92 * appear, 3);
        ctx.texts.put("md", recipe.name, box.x + 30, topY, toColor(PALETTE.xuanInk), 0, 0.5, TextAlign.Left, 1.6, 0.98 * appear, 0);

        const badge = equipped ? "已携" : (recipe.crafted ? "已制" : (canCraft ? "可制" : "缺料"));
        const badgeCol = equipped ? PALETTE.rouge : (canCraft ? PALETTE.xuanInk : PALETTE.rougeSoft);
        ctx.texts.put("xs", badge, box.x + box.width - 14, topY, toColor(badgeCol), 1, 0.5, TextAlign.Right, 1.0, 0.94 * appear, 0);

        // 中部左：迷你 3×3 连线强化效果预览（直接复用 reload_wheel 同源几何坐标与纹样）
        const narrow = box.width < 195;
        const miniCx = box.x + (narrow ? 36 : 46);
        const miniCy = box.y + box.height - 96;
        this.drawMiniReloadPreview(uiInkDraw, uiGlow, miniCx, miniCy, recipe.enhancedEffect, appear);

        // 中部右：强化要点 + 所需材料逐项状态（留足右侧呼吸边距）
        const infoX = box.x + (narrow ? 72 : 90);
        const effTitle = recipe.enhancedEffect === "light" ? "增强 · 灯纹照亮" : (recipe.enhancedEffect === "echo" ? "增强 · 铃纹回声" : "增强 · 推退");
        ctx.texts.put("xs", effTitle, infoX, box.y + box.height - 64, toColor(PALETTE.rouge), 0, 0.5, TextAlign.Left, narrow ? 0.3 : 0.8, 0.95 * appear, 0);

        let row = 0;
        for (const mat in recipe.cost) {
            const need = recipe.cost[mat];
            const have = bench.inventory[mat] ?? 0;
            const lack = !recipe.crafted && have < need;
            const ry = box.y + box.height - 90 - row * 22;
            const col = lack ? PALETTE.rouge : PALETTE.xuanInkSub;
            const text = materialLabel(mat) + " " + have + "/" + need + (lack ? "（缺）" : "");
            ctx.texts.put("xs", text, infoX, ry, toColor(col), 0, 0.5, TextAlign.Left, 0.6, 0.94 * appear, 0);
            row += 1;
        }

        // 中下宣纸留白带：展示手绘改制明式鸟铳图样（引路灯铳 / 回声铳 / 快装器具），与文字与 3×3 零重叠
        const weaponArtPath = recipe.enhancedEffect === "echo"
            ? "assets/art/vfx_craft_art.clip|craft_echo_gun"
            : (recipe.enhancedEffect === "light"
                ? "assets/art/vfx_craft_art.clip|craft_lantern_gun"
                : "assets/art/props_ming.clip|pickup_quickbelt");
        uiArt.tryPlacePath(weaponArtPath, "cb_wpn_art_" + recipe.id, box.x + box.width * 0.5, box.y + 68, Math.min(box.width - 36, 126), 34, {
            anchorX: 0.5,
            anchorY: 0.5,
            preserveAspect: true,
            smooth: true,
            opacity: (selected ? 0.96 : 0.78) * appear,
            layer: 3,
        });

        // 底部动作条（零按键教学文案，仅表达当前动作语义）
        const btnRect = Rect(box.x + 14, box.y + 14, box.width - 28, 34);
        const btnLabel = equipped
            ? "已佩此铳"
            : (recipe.crafted ? "改佩此铳" : (isPending ? "制器中……" : (canCraft ? "制成并试握" : "材料不足")));
        const btnBg = equipped
            ? Color(168, 46, 44, Math.round(32 * appear))
            : (selected && (canCraft || recipe.crafted)
                ? Color(32, 30, 32, Math.round(218 * appear))
                : Color(32, 30, 32, Math.round((highlightMissing ? 42 : 24) * appear)));
        const btnTextCol = selected && (canCraft || recipe.crafted) && !equipped
            ? PALETTE.xuanPaper
            : (highlightMissing ? PALETTE.rouge : PALETTE.xuanInk);
        uiInkDraw.drawRect(btnRect, btnBg, 0.9, toColor(highlightMissing ? PALETTE.rouge : PALETTE.xuanInkSub, 175 * appear));
        ctx.texts.put(
            "sm",
            btnLabel,
            btnRect.x + btnRect.width * 0.5,
            btnRect.y + btnRect.height * 0.5,
            toColor(btnTextCol),
            0.5,
            0.5,
            TextAlign.Center,
            1.6,
            0.96 * appear,
            0,
        );
    }

    /** 方案卡上的迷你 3×3 连线强化示意（灯纹 0→1→2→5→8 / 铃纹 0→1→4→5→8） */
    private drawMiniReloadPreview(
        uiInkDraw: DrawNode.Type,
        uiGlow: DrawNode.Type,
        cx: number,
        cy: number,
        effect: ReloadEffectKind,
        appear: number,
    ): void {
        const step = 20;
        const samplePath = effect === "light" ? [0, 1, 2, 5, 8] : (effect === "echo" ? [0, 1, 4, 5, 8] : [0, 3, 6, 7, 8]);
        const accent: RGBA = effect === "echo" ? PALETTE.rouge : (effect === "light" ? PALETTE.amberDim : PALETTE.xuanInk);

        // 底框与 9 点
        uiInkDraw.drawRect(Rect(cx - 32, cy - 32, 64, 64), Color(224, 218, 206, Math.round(145 * appear)), 0.8, toColor(PALETTE.xuanInkSub, 120 * appear));
        let i = 0;
        for (i = 0; i < RELOAD_GRID.length; i++) {
            const g = RELOAD_GRID[i];
            const nx = cx + (g.col - 1) * step;
            const ny = cy + (g.row - 1) * step;
            uiInkDraw.drawDot(Vec2(nx, ny), 1.8, toColor(PALETTE.xuanInkSub, 130 * appear));
        }

        // 示例连线
        for (i = 0; i < samplePath.length - 1; i++) {
            const a = RELOAD_GRID[samplePath[i]];
            const b = RELOAD_GRID[samplePath[i + 1]];
            uiInkDraw.drawSegment(
                Vec2(cx + (a.col - 1) * step, cy + (a.row - 1) * step),
                Vec2(cx + (b.col - 1) * step, cy + (b.row - 1) * step),
                1.8,
                toColor(accent, 220 * appear),
            );
        }

        // 高亮目标纹样点
        const keyNode = effect === "light" ? RELOAD_GRID[2] : (effect === "echo" ? RELOAD_GRID[4] : RELOAD_GRID[8]);
        const kx = cx + (keyNode.col - 1) * step;
        const ky = cy + (keyNode.row - 1) * step;
        drawReloadPatternGlyph(uiInkDraw, kx, ky, 7.5, effect, accent, appear);
        fillRadialGlow(uiGlow, kx, ky, 14, 14, toColor(PALETTE.amberCore, 45 * appear), Color(244, 234, 214, 0), 10);
    }

    /** 首次制成 1 秒试握演出 / 后续 0.45 秒短递交动作（小满递至惯用手一侧 → 周戍试握 → 小满松手） */
    private drawHandoverOverlay(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): void {
        const prog = Math.max(0, Math.min(1, 1 - this.handoverRemaining / Math.max(0.01, this.handoverDuration)));
        const fade = prog < 0.14 ? prog / 0.14 : (prog > 0.84 ? (1 - prog) / 0.16 : 1);
        const cx = ctx.uiW * 0.5;
        const cy = ctx.uiH * 0.68;
        const w = 440;
        const h = 112;

        drawSilkVeil(uiDraw, uiArt, "cb_handover_veil", cx, cy, w + 80, h + 28, PALETTE.inkWash, 0.84 * fade, 0);
        drawHairline(uiInkDraw, uiArt, "cb_handover_top", cx, cy + h * 0.48, w - 30, PALETTE.amber, 0.58 * fade, true, 2);

        // 三段动作节奏：0..0.38 递出，0.38..0.74 试握微抬，0.74..1.0 小满松手退步
        const passK = Math.min(1, prog / 0.38);
        const gripLift = prog >= 0.38 && prog < 0.74 ? Math.sin(((prog - 0.38) / 0.36) * Math.PI) * 9 : 0;
        const releaseK = prog >= 0.74 ? (prog - 0.74) / 0.26 : 0;
        const a245 = Math.round(245 * fade);
        const a235 = Math.round(235 * fade);

        // 左侧：小满红褐短袄递出之手；右侧：周戍同源青布补线袖口接握；中央：手绘改制鸟铳
        const childHandX = cx - 78 + passK * 42 - releaseK * 38;
        const childHandY = cy - 4 + gripLift * 0.2;
        const solHandX = cx + 82 - Math.min(1, Math.max(0, (prog - 0.18) / 0.28)) * 42;
        const solHandY = cy - 4 + gripLift;
        const gunX = prog < 0.38 ? childHandX + 14 : solHandX - 8;
        const gunY = cy + 6 + gripLift;

        const childPlaced = uiArt.tryPlacePath("assets/art/cutscene_cuff_rig.clip|cuff_xiaoman_reach", "cb_ho_child", childHandX, childHandY - 6, 154, 68, {
            anchorX: 0.43,
            anchorY: 0.52,
            facing: -1,
            smooth: true,
            opacity: 0.94 * fade,
            layer: 3,
        });
        if (!childPlaced) {
            uiInkDraw.drawPolygon([
                Vec2(cx - 148, cy - 22),
                Vec2(cx - 146, cy - 8),
                Vec2(childHandX - 10, childHandY + 4),
                Vec2(childHandX - 10, childHandY - 6),
            ], Color(164, 78, 54, a235), 1.0, Color(52, 28, 22, a235));
            uiInkDraw.drawSegment(Vec2(childHandX - 11, childHandY + 4), Vec2(childHandX - 11, childHandY - 6), 2.0, Color(204, 174, 122, a245));
            uiInkDraw.drawEllipse(Vec2(childHandX, childHandY - 1), 6.2, 4.4, Color(238, 212, 182, a245));
        }

        const solPlaced = uiArt.tryPlacePath("assets/art/cutscene_cuff_rig.clip|cuff_zhou_clasp", "cb_ho_zhou", solHandX, solHandY - 4, 168, 78, {
            anchorX: 0.57,
            anchorY: 0.50,
            facing: -1,
            smooth: true,
            opacity: 0.96 * fade,
            layer: 4,
        });
        if (!solPlaced) {
            uiInkDraw.drawPolygon([
                Vec2(cx + 154, cy - 18),
                Vec2(cx + 154, cy - 1),
                Vec2(solHandX + 12, solHandY + 6),
                Vec2(solHandX + 12, solHandY - 7),
            ], toColor(CUFF_PALETTE.indigoBase, a245), 1.0, toColor(CUFF_PALETTE.indigoShadow, a245));
            const mendCol = toColor(CUFF_PALETTE.stitchThread, a245);
            uiInkDraw.drawSegment(Vec2(solHandX + 16, solHandY - 5), Vec2(solHandX + 19, solHandY + 4), 1.5, mendCol);
            uiInkDraw.drawSegment(Vec2(solHandX + 21, solHandY - 5), Vec2(solHandX + 24, solHandY + 4), 1.5, mendCol);
            uiInkDraw.drawSegment(Vec2(solHandX + 26, solHandY - 5), Vec2(solHandX + 29, solHandY + 4), 1.5, mendCol);
            uiInkDraw.drawEllipse(Vec2(solHandX, solHandY), 6.8, 5.0, toColor(CUFF_PALETTE.skinBase, a245));
        }

        const gunClip = this.handoverEffect === "echo" ? "craft_echo_gun" : "craft_lantern_gun";
        if (!uiArt.tryPlacePath("assets/art/vfx_craft_art.clip|" + gunClip, "cb_ho_gun", gunX, gunY, 170, 52, {
            anchorX: 0.5,
            anchorY: 0.5,
            preserveAspect: true,
            smooth: true,
            opacity: 0.98 * fade,
            layer: 5,
        })) {
            uiInkDraw.drawPolygon([
                Vec2(gunX - 42, gunY - 8),
                Vec2(gunX - 12, gunY - 3),
                Vec2(gunX + 16, gunY + 1),
                Vec2(gunX + 16, gunY + 6),
                Vec2(gunX - 16, gunY + 3),
                Vec2(gunX - 40, gunY + 1),
            ], Color(108, 72, 48, a245), 1.0, Color(46, 30, 20, a245));
            uiInkDraw.drawSegment(Vec2(gunX - 6, gunY + 4), Vec2(gunX + 56, gunY + 8), 2.8, Color(152, 148, 138, a245));
            uiInkDraw.drawSegment(Vec2(gunX + 14, gunY + 1), Vec2(gunX + 14, gunY + 8), 2.0, Color(198, 166, 112, a245));
            uiInkDraw.drawSegment(Vec2(gunX + 36, gunY + 3), Vec2(gunX + 36, gunY + 9), 1.6, Color(198, 166, 112, a245));
        }
        drawReloadPatternGlyph(uiInkDraw, gunX + 2, gunY + 26, 8.5, this.handoverEffect, PALETTE.amberCore, fade);
        fillRadialGlow(uiGlow, gunX + 4, gunY + 4, 48, 22, toColor(PALETTE.amberCore, 52 * fade), Color(244, 234, 214, 0), 12);

        const caption = this.handoverDuration >= 0.8
            ? (this.handoverWeaponName + " 已成 · 周戍试握上手")
            : (this.handoverWeaponName + " 已交接佩用");
        ctx.texts.put("xs", caption, cx, cy - 34, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.4, 0.94 * fade, 0.08);
    }
}

export function createCraftBenchPlugin(contract?: DualRouteContract): CraftBenchPlugin {
    return new CraftBenchPlugin(contract);
}
