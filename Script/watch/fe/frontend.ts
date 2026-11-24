/**
 * 《守望》像素贴图前端总控器。
 *
 * 职责边界：
 * - 统一管理 Dora SSR 渲染节点分层（远景 / 远景发光 / 外部 Sprite 槽位 / 前景 / 前景发光 / UI / UI 发光 / 文本池）；
 * - 接管标题菜单、章节直达、操作图鉴、局内渲染、动态镜头、VFX、HUD 与电影叙事演出；
 * - 后端零侵入：只读消费 Play 实例，并把高清 CameraDirector.screenToWorld 注入 Play.worldMapper；
 * - 挂出运行时验收钩子 package.loaded["watch.fe"]，便于自动化切场/演示状态与高清截帧验收。
 */

import { BlendFunc, BlendOp, DrawNode, Node } from "Dora";
import { Play } from "Script/watch/play";
import { Input } from "Script/watch/input";
import { PlayAdapter } from "Script/watch/fe/adapter";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { CameraDirector } from "Script/watch/fe/camera";
import { DepthOcclusion } from "Script/watch/fe/occlusion";
import { StageRenderer } from "Script/watch/fe/renderer/stage";
import { PropsRenderer } from "Script/watch/fe/renderer/props";
import { ActorsRenderer } from "Script/watch/fe/renderer/actors";
import { VfxSystem } from "Script/watch/fe/renderer/vfx";
import { TextPool } from "Script/watch/fe/ui/textpool";
import { HudRenderer } from "Script/watch/fe/ui/hud";
import { NarrativeRenderer } from "Script/watch/fe/ui/narrative";
import { MenuAction, MenuRenderer, ScreenKind } from "Script/watch/fe/ui/menus";
import { themeOf } from "Script/watch/fe/theme";

export class WatchFrontend {
    private occlusion = new DepthOcclusion();
    private layerRoot: Node.Type;
    private bgDraw: DrawNode.Type;
    private bgGlow: DrawNode.Type;
    private backdropArt: AssetSlotHost;
    private worldArt: AssetSlotHost;
    private uiArt: AssetSlotHost;
    private fgDraw: DrawNode.Type;
    private fgGlow: DrawNode.Type;
    private uiLayer: Node.Type;
    private uiDraw: DrawNode.Type;
    private uiInkDraw: DrawNode.Type;
    private uiGlow: DrawNode.Type;
    private texts: TextPool;

    readonly cam = new CameraDirector();
    readonly adapter = new PlayAdapter();
    readonly stage = new StageRenderer();
    readonly props = new PropsRenderer();
    readonly actors = new ActorsRenderer();
    readonly vfx = new VfxSystem();
    readonly hud = new HudRenderer();
    readonly narrative = new NarrativeRenderer();
    readonly menus = new MenuRenderer();

    screen: ScreenKind = "title";
    private time = 0;
    private boundPlay: Play | undefined;

    constructor(parent: Node.Type) {
        this.layerRoot = Node();
        this.layerRoot.order = 5;
        this.layerRoot.addTo(parent);

        const additive = BlendFunc(BlendOp.SrcAlpha, BlendOp.One);

        this.bgDraw = DrawNode();
        this.bgDraw.order = 10;
        this.bgDraw.addTo(this.layerRoot);

        this.bgGlow = DrawNode();
        this.bgGlow.order = 15;
        this.bgGlow.blendFunc = additive;
        this.bgGlow.addTo(this.layerRoot);

        this.backdropArt = new AssetSlotHost(this.layerRoot, 12);
        this.worldArt = new AssetSlotHost(this.layerRoot, 32);

        this.fgDraw = DrawNode();
        this.fgDraw.order = 30;
        this.fgDraw.addTo(this.layerRoot);

        this.fgGlow = DrawNode();
        this.fgGlow.order = 35;
        this.fgGlow.blendFunc = additive;
        this.fgGlow.addTo(this.layerRoot);

        this.uiLayer = Node();
        this.uiLayer.order = 40;
        this.uiLayer.addTo(this.layerRoot);

        this.uiDraw = DrawNode();
        this.uiDraw.order = 0;
        this.uiDraw.addTo(this.uiLayer);

        this.uiArt = new AssetSlotHost(this.uiLayer, 2);

        this.uiInkDraw = DrawNode();
        this.uiInkDraw.order = 4;
        this.uiInkDraw.addTo(this.uiLayer);

        this.uiGlow = DrawNode();
        this.uiGlow.order = 6;
        this.uiGlow.blendFunc = additive;
        this.uiGlow.addTo(this.uiLayer);

        this.texts = new TextPool(this.uiLayer, 10);
    }

    private resizeInterface(w: number, h: number): number {
        const scale = Math.max(0.25, Math.min(w / 1280, h / 720));
        this.uiLayer.scaleX = scale;
        this.uiLayer.scaleY = scale;
        return scale;
    }

    /** 显示或隐藏整套高清前端（切回 D1 灰盒调试模式时自动隐藏） */
    setVisible(v: boolean): void {
        this.layerRoot.visible = v;
        if (!v) {
            this.texts.hideAll();
        }
    }

    /** 绑定新的 Play 实例（切房间或重试时调用），对齐镜头并挂接高清坐标反算 */
    bindPlay(p: Play, w: number, h: number): void {
        this.boundPlay = p;
        p.worldMapper = (sx: number, sy: number) => this.cam.screenToWorld(sx, sy);
        this.cam.snap(p, w, h);
        this.adapter.reset(p);
        this.actors.reset(p);
        this.occlusion.reset();
        this.vfx.reset();
        this.hud.reset(p);
        this.narrative.onEnterRoom(p.room.key);
    }

    private clearAll(): void {
        this.bgDraw.clear();
        this.bgGlow.clear();
        this.fgDraw.clear();
        this.fgGlow.clear();
        this.uiDraw.clear();
        this.uiInkDraw.clear();
        this.uiGlow.clear();
        this.backdropArt.beginFrame();
        this.worldArt.beginFrame();
        this.uiArt.beginFrame();
        this.texts.beginFrame();
    }

    private finishFrame(): void {
        this.backdropArt.endFrame();
        this.worldArt.endFrame();
        this.uiArt.endFrame();
        this.texts.endFrame();
    }

    /** 菜单态每帧更新与渲染 */
    renderMenu(dt: number, input: Input, w: number, h: number): MenuAction {
        this.setVisible(true);
        this.clearAll();
        const uiScale = this.resizeInterface(w, h);
        const act = this.menus.updateAndDrawScreen(
            dt,
            this.screen,
            input,
            this.stage,
            this.bgDraw,
            this.bgGlow,
            this.backdropArt,
            this.uiArt,
            this.uiDraw,
            this.uiInkDraw,
            this.uiGlow,
            this.texts,
            w,
            h,
            uiScale,
        );
        this.finishFrame();
        return act;
    }

    /** 局内试玩态每帧更新与渲染（返回暂停菜单动作，非暂停时返回 none） */
    renderPlay(dt: number, p: Play, input: Input, w: number, h: number): MenuAction {
        this.setVisible(true);
        if (this.boundPlay !== p) {
            this.bindPlay(p, w, h);
        }
        const safeDt = Math.min(0.05, Math.max(0.001, dt));

        // 采样后端边沿事件 → 触发震屏/残影/粒子/顿帧
        const ev = this.adapter.sample(p);
        this.vfx.ingest(ev, p, this.cam);

        if (!p.paused) {
            this.time += safeDt;
            this.cam.update(safeDt, p, w, h);
            this.actors.update(safeDt, p);
            this.vfx.update(safeDt, themeOf(p.room.key).ambient);
            this.hud.update(safeDt, p);
            this.narrative.update(safeDt, p);
        } else {
            // 暂停时立即收净切场斜切幕布，避免遮挡暂停面板
            this.narrative.wipeT = 0;
            this.cam.update(0, p, w, h);
        }

        this.clearAll();

        // 1. 远景与中景视差舞台
        this.stage.drawBackdrop(this.bgDraw, this.bgGlow, this.backdropArt, p, this.cam, this.time);

        // 2. 逻辑平面建筑与地面
        const fadeDt = p.paused ? 0 : safeDt;
        this.stage.drawPlayableWorld(this.fgDraw, this.fgGlow, this.worldArt, p, this.cam, this.time, this.occlusion, fadeDt);

        // 3. 互动道具（红布板车、村口瓶架/桌子/抛物线、区域与信标）
        this.props.drawAll(this.fgDraw, this.fgGlow, this.worldArt, p, this.cam, this.time, this.occlusion, fadeDt);

        // 4. 关节剪影角色与翻滚冰青残影
        this.actors.drawAll(this.fgDraw, this.fgGlow, this.worldArt, p, this.cam);

        // 5. 世界空间特效（霓虹曳光弹道、护盾格挡、声波环、火花）
        this.vfx.drawWorldVfx(this.fgGlow, this.worldArt, this.cam);

        // 6. 近景压边与暗角 + 屏幕环境粒子/受击红边
        this.stage.drawForegroundFraming(this.fgDraw, w, h, p, this.cam);
        this.vfx.drawScreenVfx(this.fgGlow, w, h, p.room.key);

        // 7. 水墨 HUD、旁白叙事与暂停垂纱
        const uiScale = this.resizeInterface(w, h);
        let action: MenuAction = { type: "none" };
        if (p.paused) {
            action = this.menus.updateAndDrawPause(
                safeDt,
                input,
                this.uiDraw,
                this.uiInkDraw,
                this.uiArt,
                this.uiGlow,
                this.texts,
                w / uiScale,
                h / uiScale,
                uiScale,
            );
        } else {
            this.hud.draw(this.uiDraw, this.uiInkDraw, this.uiArt, this.uiGlow, this.texts, p, this.cam, this.vfx, this.narrative.letterbox, uiScale);
            this.narrative.draw(this.uiDraw, this.uiInkDraw, this.uiGlow, this.uiArt, this.texts, p, w / uiScale, h / uiScale);
        }

        this.finishFrame();
        return action;
    }
}
