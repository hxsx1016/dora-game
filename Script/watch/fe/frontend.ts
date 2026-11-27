/**
 * 《守望》像素贴图前端总控器（Phase 0 · 底座与插件扩展架构）。
 *
 * 职责边界：
 * - 统一管理 Dora SSR 渲染节点分层（远景 / 远景发光 / 外部 Sprite 槽位 / 前景 / 前景发光 / UI / UI 发光 / 文本池）；
 * - 集成双模式契约（contract）、分轨防重播音频（audio）与零冲突渲染插件体系（plugins）；
 * - 实现双时钟分离（worldDt = safeDt * view.timeScale，uiDt = safeDt；暂停全部归零冻结）；
 * - 后端零侵入：只读消费 Play 实例并注入高清 CameraDirector.screenToWorld，
 *   惰性向 package.loaded["watch.fe"] 挂载 contract/audio/registerPlugin 调试钩子（零改动 app.ts）。
 */

import { BlendFunc, BlendOp, DrawNode, Node, Rect, TextAlign, Vec2 } from "Dora";
import { Play } from "Script/watch/play";
import { Input } from "Script/watch/input";
import { StageViewport, computeStageViewport } from "Script/watch/platform";
import { FrameEvents, PlayAdapter } from "Script/watch/fe/adapter";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { AudioDirector } from "Script/watch/fe/audio";
import { SoundscapeDirector } from "Script/watch/fe/bgm";
import { CameraDirector } from "Script/watch/fe/camera";
import { DualRouteContract } from "Script/watch/fe/contract";
import { DepthOcclusion } from "Script/watch/fe/occlusion";
import { FePluginContext, FeRenderPlugin, PartyPose } from "Script/watch/fe/plugins";
import { StageRenderer } from "Script/watch/fe/renderer/stage";
import { PropsRenderer } from "Script/watch/fe/renderer/props";
import { ActorsRenderer } from "Script/watch/fe/renderer/actors";
import { DioramaLayerHost } from "Script/watch/fe/renderer/diorama_grid";
import { VfxSystem } from "Script/watch/fe/renderer/vfx";
import { TextPool } from "Script/watch/fe/ui/textpool";
import { HudRenderer } from "Script/watch/fe/ui/hud";
import { NarrativeRenderer } from "Script/watch/fe/ui/narrative";
import { MenuAction, MenuRenderer, ScreenKind, UiSoundKind } from "Script/watch/fe/ui/menus";
import { PALETTE, drawSilkVeil, themeOf, toColor } from "Script/watch/fe/theme";
import { MingArtAuditPlugin } from "Script/watch/fe/renderer/ming_audit";
import { GateTransitionPlugin } from "Script/watch/fe/scenes/gate_transition";
import { LowpolyWorldPlugin } from "Script/watch/fe/scenes/lowpoly_world";
import { AfterimageArtifactPlugin } from "Script/watch/fe/renderer/afterimage_artifact";
import { CarryPosePlugin } from "Script/watch/fe/renderer/carry_pose";
import { PrologueIntroPlugin } from "Script/watch/fe/cutscenes/prologue_intro";
import { CuffShotsPlugin } from "Script/watch/fe/cutscenes/cuff_shots";
import { TowerEndingsPlugin } from "Script/watch/fe/cutscenes/tower_endings";
import { WellMuseumPlugin } from "Script/watch/fe/scenes/well_museum";
import { ReloadWheelPlugin } from "Script/watch/fe/ui/reload_wheel";
import { CraftBenchPlugin } from "Script/watch/fe/ui/craft_bench";

export class WatchFrontend {
    private occlusion = new DepthOcclusion();
    private layerRoot: Node.Type;
    private bgDraw: DrawNode.Type;
    private bgGlow: DrawNode.Type;
    private backdropArt: AssetSlotHost;
    private dioramaBg: DioramaLayerHost;
    private dioramaWorld: DioramaLayerHost;
    private dioramaFg: DioramaLayerHost;
    private worldArt: AssetSlotHost;
    private uiArt: AssetSlotHost;
    private fgDraw: DrawNode.Type;
    private fgGlow: DrawNode.Type;
    private uiLayer: Node.Type;
    private uiDraw: DrawNode.Type;
    private uiInkDraw: DrawNode.Type;
    private uiGlow: DrawNode.Type;
    private uiMask: DrawNode.Type;
    private texts: TextPool;

    readonly cam = new CameraDirector();
    readonly adapter = new PlayAdapter();
    readonly contract = new DualRouteContract();
    readonly audio = new AudioDirector();
    readonly soundscape = new SoundscapeDirector();
    readonly stage = new StageRenderer();
    readonly props = new PropsRenderer();
    readonly actors = new ActorsRenderer();
    readonly vfx = new VfxSystem();
    readonly hud = new HudRenderer();
    readonly narrative = new NarrativeRenderer();
    readonly menus = new MenuRenderer();

    private plugins: FeRenderPlugin[] = [];

    screen: ScreenKind = "title";
    private time = 0;
    private boundPlay: Play | undefined;
    private stageVp: StageViewport = computeStageViewport(1280, 720);
    private toastText = "";
    private toastTimer = 0;

    constructor(parent: Node.Type) {
        this.layerRoot = Node();
        this.layerRoot.order = 5;
        this.layerRoot.addTo(parent);

        this.audio.attachHost(this.layerRoot);
        this.menus.onUiSound = (kind: UiSoundKind) => {
            this.playMenuUiSound(kind);
        };
        this.menus.onAudioSettingsChanged = (inp: Input) => {
            this.audio.applyUserVolumes(inp.settings);
        };

        const additive = BlendFunc(BlendOp.SrcAlpha, BlendOp.One);

        this.bgDraw = DrawNode();
        this.bgDraw.order = 10;
        this.bgDraw.addTo(this.layerRoot);

        this.bgGlow = DrawNode();
        this.bgGlow.order = 15;
        this.bgGlow.blendFunc = additive;
        this.bgGlow.addTo(this.layerRoot);

        this.backdropArt = new AssetSlotHost(this.layerRoot, 12);
        this.dioramaBg = new DioramaLayerHost(this.layerRoot, 14);
        this.dioramaWorld = new DioramaLayerHost(this.layerRoot, 28);
        this.worldArt = new AssetSlotHost(this.layerRoot, 32);
        this.dioramaFg = new DioramaLayerHost(this.layerRoot, 34);

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

        this.uiMask = DrawNode();
        this.uiMask.order = 8;
        this.uiMask.addTo(this.uiLayer);

        this.texts = new TextPool(this.uiLayer, 10);

        // 合流点 M2：按渲染分层与依赖优先级统一注册 Wave 1 + Wave 2 全部 11 枚前端插件
        // 1. MingArtAuditPlugin（非八房明朝底图拦截 + 材质/灰度/红布校验；lowpoly/museum 态自动礼让）
        // 2. GateTransitionPlugin（风台 24s 转景舞台与遮幅，必须先于 CuffShotsPlugin）
        // 3. LowpolyWorldPlugin（Wave 2 fe-04 小满单人线四房低模舞台与前景，礼让 TowerEndingsPlugin）
        // 4. AfterimageArtifactPlugin（Wave 2 fe-06 时间穿梭器冷白/微金轨迹残影，位于背负叠层之下）
        // 5. CarryPosePlugin（牵手 / 蹲背攀爬 / 背负 / 工台放下叠层）
        // 6. PrologueIntroPlugin（共同序章 P01-P02 过场与 P04 墙根枪火）
        // 7. CuffShotsPlugin（同一道补线袖口 P03 / P05 / G05，叠加在风台遮幅之上）
        // 8. TowerEndingsPlugin（Wave 2 fe-05 北塔双结局同机位配对演出 F03 / M03）
        // 9. WellMuseumPlugin（Wave 2 fe-06 双通关后院深井与现代抗日主题博物馆 E01-E02）
        // 10. ReloadWheelPlugin（3×3 慢时连线换弹全速 UI 与水墨效果反馈）
        // 11. CraftBenchPlugin（第三段安全工台与首次试握动画）
        this.registerPlugin(new MingArtAuditPlugin());
        this.registerPlugin(new GateTransitionPlugin());
        this.registerPlugin(new LowpolyWorldPlugin());
        this.registerPlugin(new AfterimageArtifactPlugin());
        this.registerPlugin(new CarryPosePlugin());
        this.registerPlugin(new PrologueIntroPlugin());
        this.registerPlugin(new CuffShotsPlugin());
        this.registerPlugin(new TowerEndingsPlugin());
        this.registerPlugin(new WellMuseumPlugin(this.contract));
        this.registerPlugin(new ReloadWheelPlugin(this.contract));
        this.registerPlugin(new CraftBenchPlugin(this.contract));
    }

    /** 注册前端渲染插件（按 id 幂等覆盖并保持既有优先级槽位），供 Wave 1 / Wave 2 并行模块零冲突挂载 */
    registerPlugin(plugin: FeRenderPlugin): void {
        let i = 0;
        for (i = 0; i < this.plugins.length; i++) {
            if (this.plugins[i].id === plugin.id) {
                this.plugins[i] = plugin;
                this.syncRuntimeHooks();
                if (this.boundPlay !== undefined && plugin.onBindPlay !== undefined) {
                    plugin.onBindPlay(this.boundPlay, this.contract.peekSnapshot(this.boundPlay));
                }
                return;
            }
        }
        this.plugins.push(plugin);
        this.syncRuntimeHooks();
        if (this.boundPlay !== undefined && plugin.onBindPlay !== undefined) {
            plugin.onBindPlay(this.boundPlay, this.contract.peekSnapshot(this.boundPlay));
        }
    }

    /** 卸载指定 id 的渲染插件 */
    unregisterPlugin(id: string): void {
        let w = 0;
        let i = 0;
        for (i = 0; i < this.plugins.length; i++) {
            if (this.plugins[i].id !== id) {
                this.plugins[w] = this.plugins[i];
                w += 1;
            }
        }
        this.plugins.length = w;
        this.syncRuntimeHooks();
    }

    /** 按插件 id 查询当前已挂载实例 */
    getPlugin(id: string): FeRenderPlugin | undefined {
        let i = 0;
        for (i = 0; i < this.plugins.length; i++) {
            if (this.plugins[i].id === id) {
                return this.plugins[i];
            }
        }
        return undefined;
    }

    getPlugins(): readonly FeRenderPlugin[] {
        return this.plugins;
    }

    /**
     * 零侵入同步调试钩子：
     * app.ts 在构造 WatchFrontend 之后才初始化 package.loaded["watch.fe"]，
     * 此处惰性向已有表补挂 contract / audio / registerPlugin 与 M1 全部插件实例，避免修改 app.ts。
     */
    private syncRuntimeHooks(): void {
        const g = globalThis as unknown as { package?: { loaded?: Record<string, unknown> } };
        const loaded = g.package !== undefined ? g.package.loaded : undefined;
        if (loaded === undefined) {
            return;
        }
        const rawFe = loaded["watch.fe"];
        if (rawFe !== undefined && typeof rawFe === "object") {
            const watchFe = rawFe as Record<string, unknown>;
            if (watchFe["contract"] !== this.contract) {
                watchFe["contract"] = this.contract;
                watchFe["audio"] = this.audio;
                watchFe["soundscape"] = this.soundscape;
                watchFe["registerPlugin"] = (plugin: FeRenderPlugin) => this.registerPlugin(plugin);
                watchFe["unregisterPlugin"] = (id: string) => this.unregisterPlugin(id);
                watchFe["getPlugin"] = (id: string) => this.getPlugin(id);
            }
            watchFe["mingAudit"] = this.getPlugin("fe03-ming-audit");
            watchFe["gateTransition"] = this.getPlugin("fe-01-gate-transition");
            watchFe["lowpolyWorld"] = this.getPlugin("fe-04-child-lowpoly");
            watchFe["afterimageArtifact"] = this.getPlugin("fe-06-afterimage-artifact");
            watchFe["carryPose"] = this.getPlugin("fe-02-carry-pose");
            watchFe["prologue"] = this.getPlugin("fe03-prologue-intro");
            watchFe["cuffShots"] = this.getPlugin("fe-01-cuff-shots");
            watchFe["towerEndings"] = this.getPlugin("fe-05-tower-endings");
            watchFe["wellMuseum"] = this.getPlugin("fe-06-well-museum");
            watchFe["reloadWheel"] = this.getPlugin("fe-02-reload-wheel");
            watchFe["craftBench"] = this.getPlugin("fe-02-craft-bench");
        }
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
        this.syncRuntimeHooks();
        this.boundPlay = p;
        p.worldMapper = (sx: number, sy: number) => this.cam.screenToWorld(sx, sy);
        this.cam.snap(p, w, h);
        this.adapter.reset(p);
        this.contract.resetForRoom(p);
        this.audio.stopRoomTransient();
        this.soundscape.resetForRoom(p);
        this.actors.reset(p);
        this.occlusion.reset();
        this.vfx.reset();
        this.hud.reset(p);
        this.narrative.onEnterRoom(p.room.key);

        if (this.plugins.length > 0) {
            const initView = this.contract.peekSnapshot(p);
            let i = 0;
            for (i = 0; i < this.plugins.length; i++) {
                const pl = this.plugins[i];
                if (pl.onBindPlay !== undefined) {
                    pl.onBindPlay(p, initView);
                }
            }
        }
    }

    private clearAll(): void {
        this.bgDraw.clear();
        this.bgGlow.clear();
        this.fgDraw.clear();
        this.fgGlow.clear();
        this.uiDraw.clear();
        this.uiInkDraw.clear();
        this.uiGlow.clear();
        this.uiMask.clear();
        this.backdropArt.beginFrame();
        this.dioramaBg.beginFrame();
        this.dioramaWorld.beginFrame();
        this.dioramaFg.beginFrame();
        this.worldArt.beginFrame();
        this.uiArt.beginFrame();
        this.texts.beginFrame();
    }

    private finishFrame(): void {
        this.backdropArt.endFrame();
        this.dioramaBg.endFrame();
        this.dioramaWorld.endFrame();
        this.dioramaFg.endFrame();
        this.worldArt.endFrame();
        this.uiArt.endFrame();
        this.texts.endFrame();
    }

    /** 同步主舞台视口与偏移（横屏原点 0,0；竖屏自动抬升至上半屏 16:9 舞台）。 */
    setStagePlacement(vp: StageViewport): void {
        this.stageVp = vp;
        this.layerRoot.position = Vec2(vp.stageX, vp.stageY);
    }

    /** 底部轻量水墨提示条（供 Android 双击返回退出等系统提示）。 */
    showToast(text: string, duration: number = 1.8): void {
        this.toastText = text;
        this.toastTimer = duration;
    }

    getToastText(): string {
        return this.toastTimer > 0 ? this.toastText : "";
    }

    private drawToast(uiW: number): void {
        if (this.toastTimer <= 0 || this.toastText === "") {
            return;
        }
        const alpha = Math.min(1, this.toastTimer * 2.4);
        const cx = uiW * 0.5;
        const cy = 82 + this.stageVp.safeUi.bottom * 0.6;
        drawSilkVeil(this.uiDraw, this.uiArt, "fe_toast_veil", cx, cy, 340, 38, PALETTE.inkWarm, 0.86 * alpha, 9);
        this.texts.put("sm", this.toastText, cx, cy, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.4, 0.96 * alpha, 0.08);
    }

    /** 计算男主线三选一本领卡的舞台 UI 坐标矩形，供 TouchControls 同步直点热区。 */
    getStoryTalentBoxes(p: Play, w: number, h: number, touchMode: boolean): Rect.Type[] {
        const offers = p.getStoryTalentOffers();
        if (offers.length === 0) {
            return [];
        }
        const uiScale = Math.max(0.25, Math.min(w / 1280, h / 720));
        return this.hud.talentCardRects(w / uiScale, h / uiScale, offers.length, touchMode, this.stageVp.safeUi.top);
    }

    private playMenuUiSound(kind: UiSoundKind): void {
        if (kind === "hover") {
            this.audio.playUi("ui:hover", "assets/audio/ui/menu_hover.wav", 0.50, 0.045);
        } else if (kind === "confirm") {
            this.audio.playUi("ui:confirm", "assets/audio/ui/menu_confirm.wav", 0.72, 0.05);
        } else if (kind === "back") {
            this.audio.playUi("ui:back", "assets/audio/ui/menu_back.wav", 0.66, 0.05);
        } else if (kind === "start") {
            this.audio.playUi("ui:start", "assets/audio/ui/game_start.wav", 0.82, 0.08);
        } else if (kind === "pauseOpen") {
            this.audio.playUi("ui:pause_open", "assets/audio/ui/pause_open.wav", 0.68, 0.08);
        } else if (kind === "pauseClose") {
            this.audio.playUi("ui:pause_close", "assets/audio/ui/pause_close.wav", 0.66, 0.08);
        } else if (kind === "toggle") {
            this.audio.playUi("ui:toggle", "assets/audio/ui/setting_toggle.wav", 0.64, 0.04);
        }
    }

    /** 护送试炼肉鸽（mode 2）切换段落时重置试炼音频态 */
    resetTrialAudio(p: Play): void {
        this.adapter.reset(p);
        this.audio.stopRoomTransient();
        this.soundscape.resetForRoom(p);
    }

    /** 护送试炼肉鸽（mode 2）每帧消费事件队列与声景拟音 */
    syncTrialAudio(dt: number, p: Play, offerCount: number): void {
        const safeDt = Math.min(0.05, Math.max(0.001, dt));
        this.audio.setPaused(p.paused);
        this.audio.setCameraRef(p.player.x, 960);
        this.audio.update(safeDt);
        if (!p.paused) {
            const ev = this.adapter.sample(p);
            this.audio.ingestEvents(ev, p);
            this.soundscape.updateTrial(safeDt, p, this.audio, offerCount);
        }
    }

    /** 菜单态每帧更新与渲染 */
    renderMenu(dt: number, input: Input, w: number, h: number): MenuAction {
        this.syncRuntimeHooks();
        const safeDt = Math.min(0.05, Math.max(0, dt));
        if (this.toastTimer > 0) {
            this.toastTimer = Math.max(0, this.toastTimer - safeDt);
        }
        if (this.screen === "title" && this.boundPlay !== undefined) {
            this.audio.stopRoomTransient();
            this.boundPlay = undefined;
        }
        this.audio.update(safeDt);
        this.soundscape.updateMenu(this.screen, this.audio);
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
            this.stageVp.safeUi,
        );
        this.drawToast(w / uiScale);
        this.finishFrame();
        return act;
    }

    /** 局内试玩态：检测点击是否命中男主线护送段的三选一本领卡（仅消费真实指针点击，不误吃手柄右摇杆枪口准星） */
    tryPickTalentAtPointer(p: Play, input: Input, w: number, h: number): boolean {
        const offers = p.getStoryTalentOffers();
        if (offers.length === 0) {
            return false;
        }
        if (input.inputMode === "gamepad" && !input.uiPressed) {
            return false;
        }
        const useUiPtr = input.uiInside || input.uiPressed;
        const inside = useUiPtr ? input.uiInside : input.inside;
        if (!inside) {
            return false;
        }
        const uiScale = Math.max(0.25, Math.min(w / 1280, h / 720));
        const uiW = w / uiScale;
        const uiH = h / uiScale;
        const rawX = useUiPtr ? input.uiX : input.mx;
        const rawY = useUiPtr ? input.uiY : input.my;
        const pointer = Vec2(rawX / uiScale, rawY / uiScale);
        const boxes = this.hud.talentCardRects(uiW, uiH, offers.length, input.isTouchMode(), this.stageVp.safeUi.top);
        let i = 0;
        for (i = 0; i < boxes.length; i++) {
            if (boxes[i].containsPoint(pointer)) {
                return p.chooseTalent(i);
            }
        }
        return false;
    }

    /** 局内试玩态每帧更新与渲染（返回暂停菜单动作，非暂停时返回 none） */
    renderPlay(dt: number, p: Play, input: Input, w: number, h: number): MenuAction {
        this.syncRuntimeHooks();
        this.setVisible(true);
        if (this.boundPlay !== p) {
            this.bindPlay(p, w, h);
        }
        const safeDt = Math.min(0.05, Math.max(0.001, dt));
        if (this.toastTimer > 0) {
            this.toastTimer = Math.max(0, this.toastTimer - safeDt);
        }
        this.audio.setPaused(p.paused);
        this.audio.setCameraRef(this.cam.x, w / Math.max(0.25, this.cam.ppu));
        this.audio.update(safeDt);

        let ev: FrameEvents;
        let worldDt = 0;
        let uiDt = 0;

        if (!p.paused) {
            // 唯一 drainEvents() 消费入口 → 按 seq 顺序分发给 VFX 与分轨音频
            ev = this.adapter.sample(p);
            this.vfx.ingest(ev, p, this.cam);
            this.audio.ingestEvents(ev, p);
            const touch = input.getTouch();
            if (touch !== undefined) {
                if (ev.playerHit) {
                    touch.vibrate(0.036);
                } else if (ev.reloadSolved || ev.benchCrafted || ev.handJustTied || ev.cartJustDocked) {
                    touch.vibrate(0.024);
                } else if (ev.coverDeflect) {
                    touch.vibrate(0.018);
                } else if (ev.knockPulse) {
                    touch.vibrate(0.014);
                }
            }
        } else {
            // 暂停态不消费/不补播事件，并立即收净切场斜切幕布
            ev = this.adapter.emptyFrame(p);
            this.narrative.wipeT = 0;
        }

        const view = this.contract.sample(p, p.paused ? 0 : safeDt, input, ev);
        if (!p.paused) {
            const clampedScale = Math.max(0, Math.min(2, view.timeScale));
            uiDt = safeDt;
            worldDt = safeDt * clampedScale;
        }

        const uiScale = this.resizeInterface(w, h);
        const uiW = w / uiScale;
        const uiH = h / uiScale;

        const ctx: FePluginContext = {
            p,
            view,
            events: ev,
            input,
            cam: this.cam,
            audio: this.audio,
            assets: this.worldArt,
            backdropArt: this.backdropArt,
            worldArt: this.worldArt,
            uiArt: this.uiArt,
            uiMask: this.uiMask,
            dioramaBg: this.dioramaBg,
            dioramaWorld: this.dioramaWorld,
            dioramaFg: this.dioramaFg,
            texts: this.texts,
            worldDt,
            uiDt,
            w,
            h,
            uiW,
            uiH,
            uiScale,
            safeUi: this.stageVp.safeUi,
            paused: p.paused,
        };

        // 先执行插件 update（便于风台转景等插件在当帧设置 cam.setAnchorLock，避免首帧错位）
        let i = 0;
        for (i = 0; i < this.plugins.length; i++) {
            const pl = this.plugins[i];
            if (pl.update !== undefined) {
                pl.update(ctx);
            }
        }

        if (!p.paused) {
            this.time += worldDt;
            this.cam.update(worldDt, p, w, h);
            this.audio.setCameraRef(this.cam.x, w / Math.max(0.25, this.cam.ppu));
            this.soundscape.updatePlay(worldDt, p, view, this.audio);
            this.actors.update(worldDt, p);
            this.vfx.update(worldDt, themeOf(p.room.key).ambient);
            this.hud.update(safeDt, p);
            this.narrative.update(safeDt, p, ev, input.frameInteractPressed);
        } else {
            this.cam.update(0, p, w, h);
        }

        this.clearAll();

        // 1. 远景与中景视差舞台（可由插件接管）
        let backdropHandled = false;
        for (i = 0; i < this.plugins.length; i++) {
            const pl = this.plugins[i];
            if (pl.drawBackdrop !== undefined && pl.drawBackdrop(this.bgDraw, this.bgGlow, this.backdropArt, ctx)) {
                backdropHandled = true;
            }
        }
        if (!backdropHandled) {
            this.stage.drawBackdrop(this.bgDraw, this.bgGlow, this.backdropArt, p, this.cam, this.time);
        }

        // 2. 逻辑平面建筑与地面（可由插件接管；淡化吃 worldDt）
        let worldHandled = false;
        for (i = 0; i < this.plugins.length; i++) {
            const pl = this.plugins[i];
            if (pl.drawWorld !== undefined && pl.drawWorld(this.fgDraw, this.fgGlow, this.worldArt, ctx)) {
                worldHandled = true;
            }
        }
        if (!worldHandled) {
            this.stage.drawPlayableWorld(this.fgDraw, this.fgGlow, this.worldArt, p, this.cam, this.time, this.occlusion, worldDt);
        }

        // 3. 互动道具（可由插件接管）
        let propsHandled = false;
        for (i = 0; i < this.plugins.length; i++) {
            const pl = this.plugins[i];
            if (pl.drawPropsOverlay !== undefined && pl.drawPropsOverlay(this.fgDraw, this.fgGlow, this.worldArt, ctx)) {
                propsHandled = true;
            }
        }
        if (!propsHandled) {
            this.props.drawAll(this.fgDraw, this.fgGlow, this.worldArt, p, this.cam, this.time, this.occlusion, worldDt);
        }

        // 4. 关节剪影角色与插件角色叠层（博物馆态由 WellMuseumPlugin 全权绘制，防止暂停垂纱下透出明初序章精灵；背负态收净原生同伴孤儿脚影）
        if (view.visualMode !== "museum") {
            let pose: PartyPose | undefined;
            for (const pl of this.plugins) {
                if (pl.drawPartyPose !== undefined) {
                    pose = pl.drawPartyPose(this.fgDraw, this.fgGlow, this.worldArt, ctx);
                    if (pose !== undefined) break;
                }
            }
            this.actors.drawAll(this.fgDraw, this.fgGlow, this.worldArt, p, this.cam, pose);
        }
        for (i = 0; i < this.plugins.length; i++) {
            const pl = this.plugins[i];
            if (pl.drawActorsOverlay !== undefined) {
                pl.drawActorsOverlay(this.fgDraw, this.fgGlow, this.worldArt, ctx);
            }
        }

        // 5. 世界空间特效
        this.vfx.drawWorldVfx(this.fgGlow, this.worldArt, this.cam);

        // 6. 近景压边与暗角 + 屏幕环境粒子/受击红边（低模与现代博物馆自有前景压边，不叠绘像素暗块）
        if (view.visualMode === "pixel") {
            this.stage.drawForegroundFraming(this.fgDraw, w, h, p, this.cam);
        }
        this.vfx.drawScreenVfx(this.fgGlow, w, h, p.room.key);

        // 7. 水墨 HUD、旁白/过场插件、全速 UI 插件与暂停垂纱
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
                uiW,
                uiH,
                uiScale,
                view.assistHintsEnabled,
                () => {
                    this.contract.toggleAssistHints();
                },
                this.stageVp.safeUi,
            );
        } else {
            // 先判定过场插件（P01/P02/P03/P05/G01-G05 等）；过场接管时压隐 HUD 文本与常规准星，避免 TextPool 透穿黑屏与特写
            let cutsceneHandled = false;
            for (i = 0; i < this.plugins.length; i++) {
                const pl = this.plugins[i];
                if (pl.drawCutsceneOverlay !== undefined
                    && pl.drawCutsceneOverlay(this.uiDraw, this.uiInkDraw, this.uiArt, this.uiGlow, ctx)) {
                    cutsceneHandled = true;
                }
            }

            if (!cutsceneHandled) {
                const touchOverlayVisible = input.shouldShowTouchControls() && !this.stageVp.isPortrait;
                this.hud.draw(
                    this.uiDraw,
                    this.uiInkDraw,
                    this.uiArt,
                    this.uiGlow,
                    this.texts,
                    p,
                    this.cam,
                    this.vfx,
                    this.narrative.letterbox,
                    uiScale,
                    view.assistHintsEnabled,
                    true,
                    input.inputMode,
                    input.gamepadLayout,
                    this.stageVp.safeUi,
                    input.retryHoldProgress,
                    touchOverlayVisible,
                );
                this.narrative.draw(
                    this.uiDraw,
                    this.uiInkDraw,
                    this.uiGlow,
                    this.uiArt,
                    this.texts,
                    p,
                    uiW,
                    uiH,
                    view.assistHintsEnabled,
                    input.inputMode,
                    input.gamepadLayout,
                    this.stageVp.safeUi,
                );
            }

            let suppressReticle = cutsceneHandled || view.reloadSession.active || view.craftBench.active;
            for (i = 0; i < this.plugins.length; i++) {
                const pl = this.plugins[i];
                if (pl.drawFullSpeedUi !== undefined
                    && pl.drawFullSpeedUi(this.uiDraw, this.uiInkDraw, this.uiArt, this.uiGlow, ctx)) {
                    suppressReticle = true;
                }
            }
            if (!suppressReticle) {
                this.hud.drawReticleOverlay(
                    this.uiInkDraw,
                    this.uiArt,
                    this.uiGlow,
                    p,
                    this.cam,
                    this.vfx,
                    this.narrative.letterbox,
                    uiScale,
                    input.isTouchMode(),
                );
            }

            // 排演态显式标注（对齐 64fc06f 录屏标注要求，避免排演样片与正式玩法混淆）
            if (view.isRehearsal) {
                const badgeText = view.rehearsalTag !== "" ? ("排演 · " + view.rehearsalTag) : "排演模式";
                drawSilkVeil(this.uiDraw, this.uiArt, "rehearsal_tag_veil", uiW * 0.5, uiH - 22 - this.stageVp.safeUi.top, 168, 26, PALETTE.inkWarm, 0.74, 8);
                this.texts.put("xs", badgeText, uiW * 0.5, uiH - 22 - this.stageVp.safeUi.top, toColor(PALETTE.amberCore), 0.5, 0.5, TextAlign.Center, 1.2, 0.92, 0.08);
            }
        }

        this.drawToast(uiW);
        this.finishFrame();
        return action;
    }
}
