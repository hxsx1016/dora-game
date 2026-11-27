/**
 * 《向西守望》前端渲染插件协议（Phase 0 · feature/fe-00-foundation）。
 *
 * 零冲突并行隔离核心：
 * - Wave 1（fe-01 / fe-02 / fe-03）与 Wave 2（fe-04 / fe-05 / fe-06）的所有并行分支，
 *   只需在各自独占目录中实现 FeRenderPlugin 并通过 WatchFrontend.registerPlugin() 挂载；
 * - 无需反复编辑 frontend.ts / stage.ts / actors.ts / hud.ts / narrative.ts 等热点文件；
 * - 未注册任何插件时，WatchFrontend 100% 回退到既有像素水墨管线（零回归）。
 */

import { DrawNode } from "Dora";
import { Play } from "Script/watch/play";
import { Input } from "Script/watch/input";
import { SafeInsets } from "Script/watch/platform";
import { FrameEvents } from "Script/watch/fe/adapter";
import { AssetSlotHost } from "Script/watch/fe/assets";
import { AudioDirector } from "Script/watch/fe/audio";
import { CameraDirector } from "Script/watch/fe/camera";
import { DualRouteSnapshot } from "Script/watch/fe/contract";
import { TextPool } from "Script/watch/fe/ui/textpool";

export interface FePluginContext {
    p: Play;
    view: DualRouteSnapshot;
    events: FrameEvents;
    input: Input;
    cam: CameraDirector;
    audio: AudioDirector;
    /** 指向世界精灵槽宿主（与 worldArt 同引用，兼容施工书字段名） */
    assets: AssetSlotHost;
    backdropArt: AssetSlotHost;
    worldArt: AssetSlotHost;
    uiArt: AssetSlotHost;
    texts: TextPool;
    /** 世界表现层增量时间（暂停为 0；换弹慢时期间为 rawDt * timeScale） */
    worldDt: number;
    /** 全速 UI 增量时间（暂停为 0；换弹慢时期间保持 1x 全速） */
    uiDt: number;
    /** 当前视口物理宽/高 */
    w: number;
    h: number;
    /** 当前 UI 逻辑宽/高（等于 w / uiScale, h / uiScale） */
    uiW: number;
    uiH: number;
    uiScale: number;
    safeUi?: SafeInsets;
    paused: boolean;
}

/** 本帧姿态已画出的角色本体。 */
export interface PartyPose {
    player: boolean;
    partner: boolean;
}

export interface FeRenderPlugin {
    readonly id: string;
    /** 切房或重试绑定新 Play 实例时回调，用于清理上一房的临时渲染状态 */
    onBindPlay?(p: Play, view: DualRouteSnapshot): void;
    /**
     * 每帧逻辑与演出推进（在 CameraDirector.update 之前调用，便于插件当帧调用 cam.setAnchorLock 零延迟对齐）
     */
    update?(ctx: FePluginContext): void;
    /** 绘制远景与中景舞台；返回 true 时接管默认 StageRenderer.drawBackdrop */
    drawBackdrop?(
        bgDraw: DrawNode.Type,
        bgGlow: DrawNode.Type,
        backdropArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean;
    /** 绘制可玩世界与地面；返回 true 时接管默认 StageRenderer.drawPlayableWorld */
    drawWorld?(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean;
    /** 绘制互动道具层；返回 true 时接管默认 PropsRenderer.drawAll */
    drawPropsOverlay?(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): boolean;
    /** 在基础角色绘制前尝试放置姿态，缺少的角色由 ActorsRenderer 补画。 */
    drawPartyPose?(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): PartyPose | undefined;
    /** 在常规角色之上叠加绘制（背负姿态、脚底接触影、穿梭器残影等） */
    drawActorsOverlay?(
        fgDraw: DrawNode.Type,
        fgGlow: DrawNode.Type,
        worldArt: AssetSlotHost,
        ctx: FePluginContext,
    ): void;
    /**
     * 绘制过场与特写覆盖层（袖口三镜、序章 P01-P04、北塔双结局登记簿等）；
     * 返回 true 时压暗或接管默认 NarrativeRenderer.draw。
     */
    drawCutsceneOverlay?(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean;
    /**
     * 绘制全速 UI 覆盖层（3×3 换弹线盘、第三段安全工台等，不受 timeScale 拖慢）；
     * 返回 true 时同帧隐藏常规战斗/投瓶准星。
     */
    drawFullSpeedUi?(
        uiDraw: DrawNode.Type,
        uiInkDraw: DrawNode.Type,
        uiArt: AssetSlotHost,
        uiGlow: DrawNode.Type,
        ctx: FePluginContext,
    ): boolean;
}
