/**
 * 《向西守望》六轨音频导演与事件防重播控制器（升级版 · feature/audio-overhaul）。
 *
 * 架构职责与零回归保障：
 * 1. 保留既有 5 条世界逻辑音轨（voice / wind / water / ambience / sfx）与 getTrackList() 契约；
 * 2. 新增独立第 6 轨 BGM 总线（bgmBus）与双槽等功率交叉淡化（Equal-Power Crossfade）、setLoopPoint 与 setProtected；
 * 3. BGM 与场景扩展环境底噪（sceneAmbSlots / menuAmbSlot）独立于 activeLoops 托管，确保既有 verify-m2 等断言零回归；
 * 4. 实时 DSP：慢时换弹自动启用 bgmBus 低通滤波（8000Hz → 950Hz），低拱/暗渠/入柜启用风噪闷音低通（1100Hz），
 *    人声播放自动触发 BGM 平滑闪避（Sidechain Ducking）；
 * 5. 全 46 个 PlayEventName 完整接线，支持 2D 立体声像定位（AudioSource.pan）、武器/材质差异化与音高阶梯换弹；
 * 6. 支持主音量 / 音乐 / 音效 / 人声四通道用户音量倍率，实时联动 controls.txt 持久化配置。
 */

import { Audio, AudioBus, AudioFilter, AudioSource, Content, Node } from "Dora";
import { Play, PlayEvent } from "Script/watch/play";
import { ControlSettings } from "Script/watch/controls_config";
import { FrameEvents } from "Script/watch/fe/adapter";
import { isArtifactWeaponId } from "Script/watch/fe/renderer/afterimage_artifact";

export type AudioTrack = "voice" | "wind" | "water" | "ambience" | "sfx";

export interface AudioLogEntry {
    tick: number;
    seq: number;
    track: AudioTrack;
    cueId: string;
    dedupeKey: string;
    path: string;
    volume: number;
    looped: boolean;
    playedBackend: boolean;
}

export interface BgmLogEntry {
    id: string;
    path: string;
    looping: boolean;
    loopPoint: number;
    playedBackend: boolean;
}

export interface AudioPlayOpts {
    pan?: number;
    protected?: boolean;
    volumeJitter?: number;
}

export interface BgmPlayOpts {
    volume?: number;
    fadeIn?: number;
    fadeOut?: number;
    looping?: boolean;
    loopPoint?: number;
    restart?: boolean;
}

interface ActiveLoop {
    track: AudioTrack;
    path: string;
    volume: number;
    source: AudioSource.Type | undefined;
    handler: number | undefined;
}

interface BgmSlot {
    id: string;
    path: string;
    baseVolume: number;
    currentFade: number;
    looping: boolean;
    loopPoint: number;
    source: AudioSource.Type | undefined;
    handler: number | undefined;
}

const ALL_TRACKS: AudioTrack[] = ["voice", "wind", "water", "ambience", "sfx"];
const MAX_PLAY_LOG = 256;
const MAX_BGM_LOG = 64;
/** 空村铁盆段内 X（与 village_undertable.ts VILLAGE_BASIN_OFFSET_X = 548 保持单一真源对齐） */
const VILLAGE_BASIN_OFFSET_X = 548;
const VILLAGE_BASIN_HIT_RADIUS = 24;
const VILLAGE_SOFT_HIT_RADIUS = 34;

function clamp01(v: number): number {
    return Math.max(0, Math.min(1, v));
}

function clampPan(v: number): number {
    return Math.max(-0.85, Math.min(0.85, v));
}

/**
 * Dora SSR Lua 运行时中，AudioBus / AudioSource 为带 __call 元表的可调用表（type 为 "table" 而非 "function"）。
 * 统一以 isCallableCtor 判定，避免音轨总线与循环声源在实机下退化失效。
 */
function isCallableCtor(ctor: unknown): boolean {
    return ctor !== undefined && (typeof ctor === "function" || typeof ctor === "object");
}

function safeCreateBus(): AudioBus.Type | undefined {
    if (!isCallableCtor(AudioBus)) {
        return undefined;
    }
    try {
        return AudioBus();
    } catch {
        return undefined;
    }
}

function safeCreateSource(
    path: string,
    autoRemove: boolean,
    bus: AudioBus.Type | undefined,
): AudioSource.Type | undefined {
    if (!isCallableCtor(AudioSource)) {
        return undefined;
    }
    try {
        return AudioSource(path, autoRemove, bus);
    } catch {
        return undefined;
    }
}

function safeAudioPlay(path: string, loop: boolean): number {
    if (typeof Audio === "undefined" || typeof Audio.play !== "function") {
        return 0;
    }
    try {
        return Audio.play(path, loop);
    } catch {
        return 0;
    }
}

function safeSetLowpass(bus: AudioBus.Type | undefined, active: boolean, cutoffHz: number, fadeSec: number): void {
    if (bus === undefined) {
        return;
    }
    try {
        if (active) {
            bus.setFilter(0, AudioFilter.BiquadResonant);
            bus.setFilterParameter(0, 0, 1.0);
            bus.setFilterParameter(0, 1, 0);
            bus.setFilterParameter(0, 3, 1.2);
            bus.fadeFilterParameter(0, 2, cutoffHz, Math.max(0.02, fadeSec));
        } else {
            bus.fadeFilterParameter(0, 2, 7900, Math.max(0.02, fadeSec));
            bus.fadeFilterParameter(0, 0, 0.0, Math.max(0.02, fadeSec));
        }
    } catch {
        // 无声设备或后端不支持滤波时静默忽略
    }
}

function resolveExisting(preferred: string, fallback: string): string {
    if (preferred !== "" && Content.exist(preferred)) {
        return preferred;
    }
    return fallback;
}

export class AudioDirector {
    private hostNode: Node.Type | undefined;
    private buses: Record<AudioTrack, AudioBus.Type | undefined>;
    private bgmBus: AudioBus.Type | undefined;
    private trackVolumes: Record<AudioTrack, number>;
    private trackMuted: Record<AudioTrack, boolean>;
    private bgmVolume = 1;
    private bgmMuted = false;

    // 用户四通道音量设置（独立于内部场景轨道音量，便于即时同步与零回归测试）
    private userMasterVol = 1.0;
    private userBgmVol = 0.8;
    private userSfxVol = 0.9;
    private userVoiceVol = 1.0;

    private activeSources: AudioSource.Type[] = [];
    private activeHandlers: number[] = [];
    private activeLoops: Record<string, ActiveLoop> = {};
    private sceneAmbSlots: Record<string, ActiveLoop> = {};
    private menuAmbSlot: ActiveLoop | undefined;

    private bgmCurrent: BgmSlot | undefined;
    private bgmFading: BgmSlot | undefined;
    private bgmFadeTimer = 0;
    private bgmFadeDuration = 0;
    private bgmTargetDuck = 1.0;
    private bgmDuckGain = 1.0;
    private bgmVoiceDuckHold = 0;
    private bgmManualDuck = 1.0;
    private bgmMuffled = false;
    private spaceMuffled = false;
    private bgmLog: BgmLogEntry[] = [];

    private dedupeSet: Record<string, boolean> = {};
    private playLog: AudioLogEntry[] = [];
    private uiCooldowns: Record<string, number> = {};
    private foleyCooldowns: Record<string, number> = {};
    private clockSec = 0;
    private jitterSeq = 0;
    private camCenterX = 0;
    private camSpanX = 1000;
    private paused = false;
    private worldPlaySpeed = 1;

    constructor() {
        this.buses = {
            voice: safeCreateBus(),
            wind: safeCreateBus(),
            water: safeCreateBus(),
            ambience: safeCreateBus(),
            sfx: safeCreateBus(),
        };
        this.bgmBus = safeCreateBus();
        this.trackVolumes = {
            voice: 1,
            wind: 1,
            water: 1,
            ambience: 1,
            sfx: 1,
        };
        this.trackMuted = {
            voice: false,
            wind: false,
            water: false,
            ambience: false,
            sfx: false,
        };
        this.syncAllBusGains();
    }

    /** 将音频宿主节点挂到场景树，供 AudioSource 节点托管生命周期 */
    attachHost(parent: Node.Type): void {
        if (this.hostNode !== undefined) {
            return;
        }
        const n = Node();
        n.order = -1;
        n.addTo(parent);
        this.hostNode = n;
    }

    /** 同步当前镜头世界中心与可视宽度，用于 2D 立体声像（pan）计算 */
    setCameraRef(centerX: number, worldSpanX: number): void {
        this.camCenterX = centerX;
        this.camSpanX = Math.max(240, worldSpanX);
    }

    /** 根据世界 X 坐标计算立体声像 pan ∈ [-0.85, 0.85] */
    panForWorldX(worldX: number): number {
        return clampPan((worldX - this.camCenterX) / (this.camSpanX * 0.48));
    }

    /** 应用 controls.txt 中的四通道用户音量并即时刷新全部总线 */
    applyUserVolumes(s: Pick<ControlSettings, "masterVol" | "bgmVol" | "sfxVol" | "voiceVol">): void {
        this.userMasterVol = clamp01(s.masterVol);
        this.userBgmVol = clamp01(s.bgmVol);
        this.userSfxVol = clamp01(s.sfxVol);
        this.userVoiceVol = clamp01(s.voiceVol);
        this.syncAllBusGains();
    }

    getUserVolumes(): { masterVol: number; bgmVol: number; sfxVol: number; voiceVol: number } {
        return {
            masterVol: this.userMasterVol,
            bgmVol: this.userBgmVol,
            sfxVol: this.userSfxVol,
            voiceVol: this.userVoiceVol,
        };
    }

    isPaused(): boolean {
        return this.paused;
    }

    getTrackVolume(track: AudioTrack): number {
        return this.trackVolumes[track];
    }

    setTrackVolume(track: AudioTrack, volume: number): void {
        const clamped = clamp01(volume);
        this.trackVolumes[track] = clamped;
        this.syncBusGain(track);
    }

    getBgmVolume(): number {
        return this.bgmVolume;
    }

    setBgmVolume(volume: number): void {
        this.bgmVolume = clamp01(volume);
        this.syncBgmBusGain();
    }

    isTrackMuted(track: AudioTrack): boolean {
        return this.trackMuted[track];
    }

    setTrackMuted(track: AudioTrack, muted: boolean): void {
        this.trackMuted[track] = muted;
        this.syncBusGain(track);
    }

    /** 是否已全局静音（所有 5 条世界逻辑音轨均静音） */
    isAllMuted(): boolean {
        let i = 0;
        for (i = 0; i < ALL_TRACKS.length; i++) {
            if (!this.trackMuted[ALL_TRACKS[i]]) {
                return false;
            }
        }
        return true;
    }

    /** 直接设定全局静音状态（供启动恢复持久化配置调用） */
    setAllMuted(muted: boolean): void {
        let i = 0;
        for (i = 0; i < ALL_TRACKS.length; i++) {
            this.setTrackMuted(ALL_TRACKS[i], muted);
        }
        this.bgmMuted = muted;
        this.syncBgmBusGain();
    }

    /** 一键切换全局静音（同步覆盖 5 条世界音轨与 BGM 总线） */
    toggleAllMuted(): boolean {
        const next = !this.isAllMuted();
        this.setAllMuted(next);
        return next;
    }

    /**
     * Web 浏览器首手势解锁后补同步循环音轨、场景环境与 BGM：
     * - 已在播放的循环音只同步音量，绝不重头播放。
     */
    unlockAndResyncAfterGesture(): void {
        this.syncAllBusGains();
        if (this.paused) {
            return;
        }
        this.resyncLoopMap(this.activeLoops);
        this.resyncLoopMap(this.sceneAmbSlots);
        if (this.menuAmbSlot !== undefined) {
            this.resyncSingleLoop(this.menuAmbSlot);
        }
        if (this.bgmCurrent !== undefined) {
            const slot = this.bgmCurrent;
            const stillPlaying = slot.source !== undefined && slot.source.playing;
            if (!stillPlaying && slot.handler === undefined && slot.path !== "" && Content.exist(slot.path)) {
                this.startBgmSlotSource(slot);
            } else {
                this.applyBgmSlotGain(slot);
            }
        }
    }

    private resyncLoopMap(map: Record<string, ActiveLoop>): void {
        for (const loopId in map) {
            this.resyncSingleLoop(map[loopId]);
        }
    }

    private resyncSingleLoop(entry: ActiveLoop): void {
        const bus = this.buses[entry.track];
        const trackGain = this.effectiveTrackGain(entry.track);
        const stillPlaying = entry.source !== undefined && entry.source.playing;
        if (stillPlaying || entry.handler !== undefined) {
            if (entry.source !== undefined) {
                entry.source.volume = bus !== undefined ? entry.volume : entry.volume * trackGain;
            }
            return;
        }
        if (entry.path !== "" && Content.exist(entry.path)) {
            const created = safeCreateSource(entry.path, false, bus);
            if (created !== undefined) {
                created.looping = true;
                created.volume = bus !== undefined ? entry.volume : entry.volume * trackGain;
                if (this.hostNode !== undefined) {
                    created.addTo(this.hostNode);
                }
                if (created.play()) {
                    entry.source = created;
                } else {
                    created.removeFromParent(true);
                }
            } else {
                const h = safeAudioPlay(entry.path, true);
                if (h > 0) {
                    entry.handler = h;
                }
            }
        }
    }

    /** 调整世界音轨播放速率（换弹慢时同步启用 BGM 低通压暗，保留 voice 清晰） */
    setWorldPlaySpeed(speed: number): void {
        const next = Math.max(0.25, Math.min(2.0, speed));
        const wantMuffle = next < 0.85;
        if (wantMuffle !== this.bgmMuffled) {
            this.bgmMuffled = wantMuffle;
            safeSetLowpass(this.bgmBus, wantMuffle, 950, wantMuffle ? 0.18 : 0.24);
        }
        if (Math.abs(next - this.worldPlaySpeed) < 0.001) {
            return;
        }
        this.worldPlaySpeed = next;
        const worldTracks: AudioTrack[] = ["wind", "water", "ambience", "sfx"];
        let i = 0;
        for (i = 0; i < worldTracks.length; i++) {
            const bus = this.buses[worldTracks[i]];
            if (bus !== undefined) {
                bus.playSpeed = next;
            }
        }
    }

    /** 空间闷音滤效（暗渠 / 低拱 / 厨柜内压暗室外风噪，离出平滑恢复） */
    setSpaceMuffled(muffled: boolean): void {
        if (this.spaceMuffled === muffled) {
            return;
        }
        this.spaceMuffled = muffled;
        safeSetLowpass(this.buses.wind, muffled, 1100, 0.25);
        safeSetLowpass(this.buses.ambience, muffled, 1450, 0.25);
    }

    private effectiveTrackGain(track: AudioTrack): number {
        if (this.trackMuted[track]) {
            return 0;
        }
        const userCat = track === "voice" ? this.userVoiceVol : this.userSfxVol;
        return clamp01(this.trackVolumes[track] * this.userMasterVol * userCat);
    }

    private effectiveBgmGain(): number {
        if (this.bgmMuted) {
            return 0;
        }
        return clamp01(this.bgmVolume * this.bgmDuckGain * this.userMasterVol * this.userBgmVol);
    }

    private syncBusGain(track: AudioTrack): void {
        const bus = this.buses[track];
        const gain = this.effectiveTrackGain(track);
        if (bus !== undefined) {
            bus.volume = gain;
        }
        // 无独立 AudioBus 回退时同步更新活跃循环音量
        if (bus === undefined) {
            for (const id in this.activeLoops) {
                const e = this.activeLoops[id];
                if (e.track === track && e.source !== undefined) {
                    e.source.volume = e.volume * gain;
                }
            }
            for (const id in this.sceneAmbSlots) {
                const e = this.sceneAmbSlots[id];
                if (e.track === track && e.source !== undefined) {
                    e.source.volume = e.volume * gain;
                }
            }
            if (this.menuAmbSlot !== undefined && this.menuAmbSlot.track === track && this.menuAmbSlot.source !== undefined) {
                this.menuAmbSlot.source.volume = this.menuAmbSlot.volume * gain;
            }
        }
    }

    private syncBgmBusGain(): void {
        const gain = this.effectiveBgmGain();
        if (this.bgmBus !== undefined) {
            this.bgmBus.volume = gain;
        }
        if (this.bgmCurrent !== undefined) {
            this.applyBgmSlotGain(this.bgmCurrent);
        }
        if (this.bgmFading !== undefined) {
            this.applyBgmSlotGain(this.bgmFading);
        }
    }

    private syncAllBusGains(): void {
        let i = 0;
        for (i = 0; i < ALL_TRACKS.length; i++) {
            this.syncBusGain(ALL_TRACKS[i]);
        }
        this.syncBgmBusGain();
    }

    private applyBgmSlotGain(slot: BgmSlot): void {
        if (slot.source === undefined) {
            return;
        }
        const cueVol = clamp01(slot.baseVolume * slot.currentFade);
        slot.source.volume = this.bgmBus !== undefined ? cueVol : cueVol * this.effectiveBgmGain();
    }

    private startBgmSlotSource(slot: BgmSlot): boolean {
        if (slot.path === "" || !Content.exist(slot.path)) {
            return false;
        }
        const src = safeCreateSource(slot.path, false, this.bgmBus);
        if (src !== undefined) {
            src.looping = slot.looping;
            if (slot.looping && slot.loopPoint > 0.01) {
                try {
                    src.setLoopPoint(slot.loopPoint);
                } catch {
                    // 静默忽略不支持 setLoopPoint 的环境
                }
            }
            try {
                src.setProtected(true);
            } catch {
                // 静默忽略
            }
            slot.source = src;
            this.applyBgmSlotGain(slot);
            if (this.hostNode !== undefined) {
                src.addTo(this.hostNode);
            }
            const ok = src.play();
            if (ok) {
                return true;
            }
            src.removeFromParent(true);
            slot.source = undefined;
        }
        const h = safeAudioPlay(slot.path, slot.looping);
        if (h > 0) {
            slot.handler = h;
            return true;
        }
        return false;
    }

    private disposeBgmSlot(slot: BgmSlot | undefined, fadeSec: number = 0): void {
        if (slot === undefined) {
            return;
        }
        if (slot.source !== undefined) {
            try {
                slot.source.stop(fadeSec);
            } catch {
                // 忽略
            }
            slot.source.removeFromParent(true);
            slot.source = undefined;
        }
        if (slot.handler !== undefined && typeof Audio !== "undefined" && typeof Audio.stop === "function") {
            Audio.stop(slot.handler);
            slot.handler = undefined;
        }
    }

    /**
     * 播放或交叉淡化切换 BGM（独立于 activeLoops，不污染 gameplay playLog）：
     * - 同 id 且未指定 restart 时幂等更新目标音量，支持跨相邻房间无缝续播；
     * - 切曲采用双槽等功率交叉淡化（Equal-Power Crossfade）。
     */
    playBgm(id: string, path: string, opts?: BgmPlayOpts): boolean {
        const vol = clamp01(opts?.volume ?? 0.85);
        const fadeIn = Math.max(0, opts?.fadeIn ?? 1.4);
        const looping = opts?.looping ?? true;
        const loopPoint = Math.max(0, opts?.loopPoint ?? 0);
        const restart = opts?.restart === true;

        if (!restart && this.bgmCurrent !== undefined && this.bgmCurrent.id === id && this.bgmCurrent.path === path) {
            this.bgmCurrent.baseVolume = vol;
            this.applyBgmSlotGain(this.bgmCurrent);
            return false;
        }

        // 将前曲转入淡出槽
        if (this.bgmFading !== undefined) {
            this.disposeBgmSlot(this.bgmFading, 0);
            this.bgmFading = undefined;
        }
        if (this.bgmCurrent !== undefined) {
            if (fadeIn > 0.05) {
                this.bgmFading = this.bgmCurrent;
            } else {
                this.disposeBgmSlot(this.bgmCurrent, opts?.fadeOut ?? 0);
            }
            this.bgmCurrent = undefined;
        }

        const nextSlot: BgmSlot = {
            id,
            path,
            baseVolume: vol,
            currentFade: fadeIn > 0.05 ? 0.0 : 1.0,
            looping,
            loopPoint,
            source: undefined,
            handler: undefined,
        };
        const playedBackend = this.startBgmSlotSource(nextSlot);
        this.bgmCurrent = nextSlot;
        this.bgmFadeDuration = fadeIn;
        this.bgmFadeTimer = 0;

        this.bgmLog.push({ id, path, looping, loopPoint, playedBackend });
        if (this.bgmLog.length > MAX_BGM_LOG) {
            this.bgmLog.shift();
        }
        return true;
    }

    stopBgm(fadeSec: number = 1.0): void {
        if (this.bgmFading !== undefined) {
            this.disposeBgmSlot(this.bgmFading, 0);
            this.bgmFading = undefined;
        }
        if (this.bgmCurrent === undefined) {
            return;
        }
        if (fadeSec > 0.05) {
            this.bgmFading = this.bgmCurrent;
            this.bgmCurrent = undefined;
            this.bgmFadeDuration = fadeSec;
            this.bgmFadeTimer = 0;
        } else {
            this.disposeBgmSlot(this.bgmCurrent, 0);
            this.bgmCurrent = undefined;
            this.bgmFadeDuration = 0;
            this.bgmFadeTimer = 0;
        }
    }

    /** 场景主动压低或恢复 BGM（如数到 18–20 归零让白） */
    setBgmManualDuck(gain: number): void {
        this.bgmManualDuck = clamp01(gain);
    }

    /** 人声触发时自动压低 BGM，持续 holdSec 秒后平滑回升 */
    triggerVoiceDuck(holdSec: number = 1.6): void {
        if (holdSec > this.bgmVoiceDuckHold) {
            this.bgmVoiceDuckHold = holdSec;
        }
    }

    getCurrentBgmId(): string {
        return this.bgmCurrent !== undefined ? this.bgmCurrent.id : "";
    }

    getBgmLog(): readonly BgmLogEntry[] {
        return this.bgmLog;
    }

    /** 每渲染帧推进 BGM 等功率交叉淡化、人声闪避与内部冷却时钟 */
    update(dt: number): void {
        const safeDt = Math.min(0.1, Math.max(0, dt));
        this.clockSec += safeDt;
        if (this.paused) {
            return;
        }

        // 1. 等功率交叉淡化推进
        if (this.bgmFadeDuration > 0.01 && (this.bgmCurrent !== undefined || this.bgmFading !== undefined)) {
            this.bgmFadeTimer = Math.min(this.bgmFadeDuration, this.bgmFadeTimer + safeDt);
            const u = clamp01(this.bgmFadeTimer / this.bgmFadeDuration);
            const inGain = Math.sin(u * Math.PI * 0.5);
            const outGain = Math.cos(u * Math.PI * 0.5);
            if (this.bgmCurrent !== undefined) {
                this.bgmCurrent.currentFade = inGain;
                this.applyBgmSlotGain(this.bgmCurrent);
            }
            if (this.bgmFading !== undefined) {
                this.bgmFading.currentFade = outGain;
                this.applyBgmSlotGain(this.bgmFading);
                if (u >= 0.999) {
                    this.disposeBgmSlot(this.bgmFading, 0);
                    this.bgmFading = undefined;
                }
            }
            if (u >= 0.999) {
                this.bgmFadeDuration = 0;
            }
        }

        // 2. 人声自动闪避与场景手动让白平滑插值
        if (this.bgmVoiceDuckHold > 0) {
            this.bgmVoiceDuckHold = Math.max(0, this.bgmVoiceDuckHold - safeDt);
        }
        const voiceDuck = this.bgmVoiceDuckHold > 0 ? 0.48 : 1.0;
        this.bgmTargetDuck = Math.min(voiceDuck, this.bgmManualDuck);
        if (Math.abs(this.bgmTargetDuck - this.bgmDuckGain) > 0.002) {
            const speed = this.bgmTargetDuck < this.bgmDuckGain ? 7.5 : 2.2;
            this.bgmDuckGain += (this.bgmTargetDuck - this.bgmDuckGain) * Math.min(1, safeDt * speed);
            this.syncBgmBusGain();
        }
    }

    /**
     * 播放界面 UI 交互音（独立于 gameplay playLog，含防连发节流，暂停态亦可正常发声）
     */
    playUi(cueId: string, path: string, volume: number = 0.72, cooldownSec: number = 0.045): boolean {
        const prevAt = this.uiCooldowns[cueId] ?? -99;
        if (this.clockSec - prevAt < cooldownSec) {
            return false;
        }
        this.uiCooldowns[cueId] = this.clockSec;
        return this.playFireAndForget("sfx", path, volume, 0, false);
    }

    /**
     * 播放拟音 Foley（脚步/翻滚/跳跃/残影等，带微幅响度自然抖动与冷却节流，不污染事件测试 playLog）
     */
    playFoley(
        cueId: string,
        path: string,
        volume: number = 0.65,
        pan: number = 0,
        cooldownMs: number = 60,
    ): boolean {
        if (this.paused) {
            return false;
        }
        const prevAt = this.foleyCooldowns[cueId] ?? -99;
        if ((this.clockSec - prevAt) * 1000 < cooldownMs) {
            return false;
        }
        this.foleyCooldowns[cueId] = this.clockSec;
        this.jitterSeq = (this.jitterSeq + 1) % 7;
        const jitter = 0.94 + this.jitterSeq * 0.02;
        return this.playFireAndForget("sfx", path, clamp01(volume * jitter), pan, false);
    }

    private playFireAndForget(
        track: AudioTrack,
        path: string,
        volume: number,
        pan: number,
        isProtected: boolean,
    ): boolean {
        if (path === "" || !Content.exist(path)) {
            return false;
        }
        this.pruneStoppedSources();
        const cueVol = clamp01(volume);
        const bus = this.buses[track];
        const src = safeCreateSource(path, false, bus);
        if (src !== undefined) {
            src.volume = bus !== undefined ? cueVol : cueVol * this.effectiveTrackGain(track);
            src.looping = false;
            if (Math.abs(pan) > 0.01) {
                src.pan = clampPan(pan);
            }
            if (isProtected) {
                try {
                    src.setProtected(true);
                } catch {
                    // 忽略
                }
            }
            if (this.hostNode !== undefined) {
                src.addTo(this.hostNode);
            }
            if (src.play()) {
                this.activeSources.push(src);
                return true;
            }
            src.removeFromParent(true);
            return false;
        }
        const h = safeAudioPlay(path, false);
        if (h > 0) {
            this.activeHandlers.push(h);
            return true;
        }
        return false;
    }

    /**
     * 扩展场景环境循环（独立于 activeLoops，切房/回标题由 stopRoomTransient 自动清净）
     */
    setSceneAmbience(slotId: string, track: AudioTrack, path: string, volume: number): void {
        const prev = this.sceneAmbSlots[slotId];
        const clampedVol = clamp01(volume);
        const bus = this.buses[track];
        const trackGain = this.effectiveTrackGain(track);
        if (prev !== undefined && prev.path === path && prev.track === track) {
            prev.volume = clampedVol;
            if (prev.source !== undefined) {
                prev.source.volume = bus !== undefined ? clampedVol : clampedVol * trackGain;
            }
            return;
        }
        if (prev !== undefined) {
            this.stopSceneAmbience(slotId, 0.25);
        }
        let source: AudioSource.Type | undefined;
        let handler: number | undefined;
        if (path !== "" && Content.exist(path)) {
            const created = safeCreateSource(path, false, bus);
            if (created !== undefined) {
                created.looping = true;
                created.volume = bus !== undefined ? clampedVol : clampedVol * trackGain;
                if (this.hostNode !== undefined) {
                    created.addTo(this.hostNode);
                }
                if (created.play()) {
                    source = created;
                } else {
                    created.removeFromParent(true);
                }
            } else {
                const h = safeAudioPlay(path, true);
                if (h > 0) {
                    handler = h;
                }
            }
        }
        this.sceneAmbSlots[slotId] = { track, path, volume: clampedVol, source, handler };
    }

    stopSceneAmbience(slotId: string, fadeTime: number = 0.2): void {
        const entry = this.sceneAmbSlots[slotId];
        if (entry === undefined) {
            return;
        }
        if (entry.source !== undefined) {
            entry.source.stop(fadeTime);
            entry.source.removeFromParent(true);
        }
        if (entry.handler !== undefined && typeof Audio !== "undefined" && typeof Audio.stop === "function") {
            Audio.stop(entry.handler);
        }
        delete this.sceneAmbSlots[slotId];
    }

    /** 标题/选章菜单专属夜海环境底噪（独立于房间 activeLoops） */
    setMenuAmbience(path: string, volume: number): void {
        const clampedVol = clamp01(volume);
        const bus = this.buses.ambience;
        const trackGain = this.effectiveTrackGain("ambience");
        if (this.menuAmbSlot !== undefined && this.menuAmbSlot.path === path) {
            this.menuAmbSlot.volume = clampedVol;
            if (this.menuAmbSlot.source !== undefined) {
                this.menuAmbSlot.source.volume = bus !== undefined ? clampedVol : clampedVol * trackGain;
            }
            return;
        }
        this.stopMenuAmbience(0.2);
        let source: AudioSource.Type | undefined;
        let handler: number | undefined;
        if (path !== "" && Content.exist(path)) {
            const created = safeCreateSource(path, false, bus);
            if (created !== undefined) {
                created.looping = true;
                created.volume = bus !== undefined ? clampedVol : clampedVol * trackGain;
                if (this.hostNode !== undefined) {
                    created.addTo(this.hostNode);
                }
                if (created.play()) {
                    source = created;
                } else {
                    created.removeFromParent(true);
                }
            } else {
                const h = safeAudioPlay(path, true);
                if (h > 0) {
                    handler = h;
                }
            }
        }
        this.menuAmbSlot = { track: "ambience", path, volume: clampedVol, source, handler };
    }

    stopMenuAmbience(fadeTime: number = 0.25): void {
        const entry = this.menuAmbSlot;
        if (entry === undefined) {
            return;
        }
        if (entry.source !== undefined) {
            entry.source.stop(fadeTime);
            entry.source.removeFromParent(true);
        }
        if (entry.handler !== undefined && typeof Audio !== "undefined" && typeof Audio.stop === "function") {
            Audio.stop(entry.handler);
        }
        this.menuAmbSlot = undefined;
    }

    /**
     * 按去重键播放一次性音效/配音：
     * - 同一房间会话内命中相同 dedupeKey 时直接跳过，返回 false；
     * - 文件尚未放入 assets/audio/ 时静默记录逻辑日志（playedBackend = false）而不抛错；
     * - 支持可选 opts.pan 立体声像定位；voice 轨自动触发 BGM 闪避与声源保护。
     */
    playOnce(
        dedupeKey: string,
        track: AudioTrack,
        path: string,
        volume: number = 1,
        cueId: string = "",
        tick: number = 0,
        seq: number = -1,
        opts?: AudioPlayOpts,
    ): boolean {
        if (dedupeKey !== "" && this.dedupeSet[dedupeKey] === true) {
            return false;
        }
        if (dedupeKey !== "") {
            this.dedupeSet[dedupeKey] = true;
        }

        const cueVol = clamp01(volume);
        const trackGain = this.effectiveTrackGain(track);
        const effectiveVol = cueVol * trackGain;
        let playedBackend = false;

        if (track === "voice") {
            this.triggerVoiceDuck(1.8);
        }

        if (path !== "" && Content.exist(path)) {
            this.pruneStoppedSources();
            const bus = this.buses[track];
            const src = safeCreateSource(path, false, bus);
            if (src !== undefined) {
                src.volume = bus !== undefined ? cueVol : effectiveVol;
                src.looping = false;
                if (opts?.pan !== undefined && Math.abs(opts.pan) > 0.01) {
                    src.pan = clampPan(opts.pan);
                }
                if (track === "voice" || opts?.protected === true) {
                    try {
                        src.setProtected(true);
                    } catch {
                        // 忽略
                    }
                }
                if (this.hostNode !== undefined) {
                    src.addTo(this.hostNode);
                }
                playedBackend = src.play();
                if (playedBackend) {
                    this.activeSources.push(src);
                } else {
                    src.removeFromParent(true);
                }
            } else {
                const handler = safeAudioPlay(path, false);
                if (handler > 0) {
                    this.activeHandlers.push(handler);
                    playedBackend = true;
                }
            }
        }

        this.recordLog({
            tick,
            seq,
            track,
            cueId: cueId !== "" ? cueId : (dedupeKey !== "" ? dedupeKey : path),
            dedupeKey,
            path,
            volume: clamp01(volume),
            looped: false,
            playedBackend,
        });
        return true;
    }

    /** 启动或更新分轨循环环境音（如风声、外壕水声、室内底噪）；同 loopId+同路径幂等不重头播放 */
    playLoop(
        loopId: string,
        track: AudioTrack,
        path: string,
        volume: number = 1,
        tick: number = 0,
    ): boolean {
        const prev = this.activeLoops[loopId];
        const clampedVol = clamp01(volume);
        const bus = this.buses[track];
        const trackGain = this.effectiveTrackGain(track);
        if (prev !== undefined && prev.path === path && prev.track === track) {
            prev.volume = clampedVol;
            if (prev.source !== undefined) {
                prev.source.volume = bus !== undefined ? clampedVol : clampedVol * trackGain;
            }
            return false;
        }
        if (prev !== undefined) {
            this.stopLoop(loopId, 0);
        }

        let source: AudioSource.Type | undefined;
        let handler: number | undefined;
        let playedBackend = false;
        if (path !== "" && Content.exist(path)) {
            const created = safeCreateSource(path, false, bus);
            if (created !== undefined) {
                created.looping = true;
                created.volume = bus !== undefined ? clampedVol : clampedVol * trackGain;
                if (this.hostNode !== undefined) {
                    created.addTo(this.hostNode);
                }
                playedBackend = created.play();
                if (playedBackend) {
                    source = created;
                } else {
                    created.removeFromParent(true);
                }
            }
            if (!playedBackend) {
                const h = safeAudioPlay(path, true);
                if (h > 0) {
                    handler = h;
                    playedBackend = true;
                }
            }
        }

        this.activeLoops[loopId] = {
            track,
            path,
            volume: clampedVol,
            source,
            handler,
        };
        this.recordLog({
            tick,
            seq: -1,
            track,
            cueId: "loop:" + loopId,
            dedupeKey: "loop:" + loopId,
            path,
            volume: clampedVol,
            looped: true,
            playedBackend,
        });
        return true;
    }

    stopLoop(loopId: string, fadeTime: number = 0): void {
        const entry = this.activeLoops[loopId];
        if (entry === undefined) {
            return;
        }
        if (entry.source !== undefined) {
            entry.source.stop(fadeTime);
            entry.source.removeFromParent(true);
        }
        if (entry.handler !== undefined && typeof Audio !== "undefined" && typeof Audio.stop === "function") {
            Audio.stop(entry.handler);
        }
        delete this.activeLoops[loopId];
    }

    /** 暂停冻结全部正在播放的音轨与位置，恢复后从同一位置续播 */
    setPaused(paused: boolean): void {
        if (this.paused === paused) {
            return;
        }
        this.paused = paused;
        if (typeof Audio !== "undefined" && typeof Audio.setPauseAllCurrent === "function") {
            try {
                Audio.setPauseAllCurrent(paused);
            } catch {
                // 无声设备模式下静默忽略
            }
        }
    }

    /** 切房或重试时停止本房所有瞬时音、房间循环与扩展场景环境，清空本房去重表（保留 BGM 状态机跨房续播） */
    stopRoomTransient(): void {
        let i = 0;
        for (i = 0; i < this.activeSources.length; i++) {
            const src = this.activeSources[i];
            if (src.playing) {
                src.stop(0);
            }
            src.removeFromParent(true);
        }
        this.activeSources = [];

        if (typeof Audio !== "undefined" && typeof Audio.stop === "function") {
            for (i = 0; i < this.activeHandlers.length; i++) {
                Audio.stop(this.activeHandlers[i]);
            }
        }
        this.activeHandlers = [];

        const loopIds: string[] = [];
        for (const id in this.activeLoops) {
            loopIds.push(id);
        }
        for (i = 0; i < loopIds.length; i++) {
            this.stopLoop(loopIds[i], 0);
        }

        const ambIds: string[] = [];
        for (const id in this.sceneAmbSlots) {
            ambIds.push(id);
        }
        for (i = 0; i < ambIds.length; i++) {
            this.stopSceneAmbience(ambIds[i], 0);
        }

        this.dedupeSet = {};
        if (this.paused) {
            this.setPaused(false);
        }
        this.setWorldPlaySpeed(1);
        this.setSpaceMuffled(false);
        this.bgmManualDuck = 1.0;
        this.bgmVoiceDuckHold = 0;
    }

    /**
     * 按 seq 顺序消费 PlayAdapter.sample 唯一 drainEvents() 产出的事件队列：
     * - 一帧补跑跨过多次事件（如两次 knock）时各自带独立 (roomSessionId, tick, seq) 键各响一次；
     * - 0 步帧与暂停重绘传入空 rawEvents，绝不重播。
     */
    ingestEvents(ev: FrameEvents, p: Play): void {
        if (this.paused || ev.rawEvents.length === 0) {
            return;
        }
        let i = 0;
        for (i = 0; i < ev.rawEvents.length; i++) {
            this.dispatchSingleEvent(ev.rawEvents[i], ev.roomSessionId, ev.checkpoint, p);
        }
    }

    private panFromData(e: PlayEvent, fallbackX?: number): number {
        const x = typeof e.data.x === "number"
            ? e.data.x
            : (typeof e.data.enemyX === "number"
                ? e.data.enemyX
                : (typeof e.data.impactX === "number" ? e.data.impactX : fallbackX));
        return x !== undefined && x >= 0 ? this.panForWorldX(x) : 0;
    }

    private dispatchSingleEvent(
        e: PlayEvent,
        roomSessionId: number,
        checkpoint: number,
        p: Play,
    ): void {
        const key = "r" + roomSessionId + ":cp" + checkpoint + ":t" + e.tick + ":s" + e.seq + ":" + e.name;
        const name = e.name as string;

        if (name === "knock") {
            const roomTag = typeof e.data.room === "string" ? e.data.room : p.room.key;
            const countNum = typeof e.data.count === "number" ? e.data.count : 1;
            const vol = countNum >= 2 ? 0.94 : 0.86;
            this.playOnce(
                key,
                "sfx",
                "assets/audio/sfx/knock.wav",
                vol,
                "knock:" + roomTag + ":" + countNum,
                e.tick,
                e.seq,
                { pan: this.panFromData(e, p.player.x) },
            );
            return;
        }
        if (name === "shotResolved") {
            const hit = e.data.hit === true;
            const weapon = p.equippedWeapon;
            let shotPath = "assets/audio/combat/shot.wav";
            if (weapon === "guide_lantern_gun") {
                shotPath = resolveExisting("assets/audio/combat/shot_lantern_gun.wav", shotPath);
            } else if (weapon === "echo_gun") {
                shotPath = resolveExisting("assets/audio/combat/shot_echo_gun.wav", shotPath);
            } else if (isArtifactWeaponId(weapon)) {
                shotPath = resolveExisting("assets/audio/combat/shot_time_shuttler.wav", shotPath);
            }
            this.playOnce(
                key,
                "sfx",
                shotPath,
                0.86,
                hit ? "shot:hit" : "shot:fire",
                e.tick,
                e.seq,
                { pan: this.panForWorldX(p.player.x) * 0.4 },
            );
            if (hit) {
                const enemyPan = this.panFromData(e);
                if (e.data.shield === true) {
                    const shieldPath = resolveExisting("assets/audio/combat/cover_block_shield.wav", "assets/audio/combat/cover_block.wav");
                    this.playOnce(key + ":shield", "sfx", shieldPath, 0.84, "cover:shield", e.tick, e.seq, { pan: enemyPan });
                } else {
                    const downPath = "assets/audio/combat/enemy_down.wav";
                    if (Content.exist(downPath)) {
                        this.playOnce(key + ":down", "sfx", downPath, 0.78, "combat:enemy_down", e.tick, e.seq, { pan: enemyPan });
                    }
                }
            }
            return;
        }
        if (name === "trialShot") {
            this.playOnce(key, "sfx", "assets/audio/combat/shot.wav", 0.85, "trial:shot", e.tick, e.seq);
            return;
        }
        if (name === "coverBlocked") {
            const ent = typeof e.data.entity === "string" ? e.data.entity : "";
            let blockPath = "assets/audio/combat/cover_block.wav";
            if (ent.indexOf("盾") >= 0) {
                blockPath = resolveExisting("assets/audio/combat/cover_block_shield.wav", blockPath);
            } else if (ent.indexOf("木") >= 0 || ent.indexOf("柜") >= 0 || ent.indexOf("帘") >= 0 || ent.indexOf("板") >= 0) {
                blockPath = resolveExisting("assets/audio/combat/cover_block_wood.wav", blockPath);
            } else if (ent !== "") {
                blockPath = resolveExisting("assets/audio/combat/cover_block_stone.wav", blockPath);
            }
            const pan = this.panFromData(e);
            this.playOnce(key, "sfx", blockPath, 0.85, "cover:blocked", e.tick, e.seq, { pan });
            if (typeof e.data.enemyX === "number" && Content.exist("assets/audio/combat/shot_enemy.wav")) {
                this.playOnce(key + ":eshot", "sfx", "assets/audio/combat/shot_enemy.wav", 0.56, "combat:shot_enemy", e.tick, e.seq, { pan });
            }
            return;
        }
        if (name === "actorHit" || name === "gateFailed") {
            const pan = this.panFromData(e);
            this.playOnce(key, "sfx", "assets/audio/combat/actor_hit.wav", 0.9, "actor:hit", e.tick, e.seq, { pan: pan * 0.4 });
            if (name === "actorHit" && typeof e.data.enemyX === "number" && Content.exist("assets/audio/combat/shot_enemy.wav")) {
                this.playOnce(key + ":eshot", "sfx", "assets/audio/combat/shot_enemy.wav", 0.62, "combat:shot_enemy", e.tick, e.seq, { pan });
            }
            if (name === "gateFailed" && Content.exist("assets/audio/combat/campaign_failed.wav")) {
                this.playOnce(key + ":fail", "sfx", "assets/audio/combat/campaign_failed.wav", 0.86, "combat:gate_failed", e.tick, e.seq);
            }
            return;
        }
        if (name === "campaignFailed") {
            this.playOnce(key, "sfx", resolveExisting("assets/audio/combat/campaign_failed.wav", "assets/audio/combat/actor_hit.wav"), 0.88, "combat:campaign_failed", e.tick, e.seq);
            return;
        }
        if (name === "gateRestart") {
            this.playOnce(key, "sfx", "assets/audio/combat/gate_winch_start.wav", 0.82, "gate:winch_restart", e.tick, e.seq);
            return;
        }
        if (name === "bottleThrown") {
            this.playOnce(key, "sfx", "assets/audio/foley/bottle_throw.wav", 0.78, "bottle:thrown", e.tick, e.seq, { pan: this.panForWorldX(p.player.x) });
            return;
        }
        if (name === "bottleLanded") {
            let surface = "brick";
            const landX = typeof e.data.x === "number" ? e.data.x : p.bottleLandX;
            if (typeof e.data.surface === "string") {
                surface = e.data.surface;
            } else if (p.room.key === "village") {
                if (Math.abs(landX - (p.ox + VILLAGE_BASIN_OFFSET_X)) <= VILLAGE_BASIN_HIT_RADIUS) {
                    surface = "iron";
                } else if (p.room.softX !== undefined && Math.abs(landX - p.room.softX) <= VILLAGE_SOFT_HIT_RADIUS) {
                    surface = "soft";
                }
            }
            const path = surface === "iron"
                ? "assets/audio/child/bottle_iron.wav"
                : (surface === "soft" ? "assets/audio/child/bottle_soft.wav" : "assets/audio/child/bottle_brick.wav");
            this.playOnce(key, "sfx", path, 0.9, "bottle:" + surface, e.tick, e.seq, { pan: this.panForWorldX(landX) });
            return;
        }
        if (name === "cartDocked") {
            this.playOnce(key, "sfx", "assets/audio/child/cart_dock.wav", 0.88, "cart:docked", e.tick, e.seq, { pan: this.panFromData(e, p.cartAxle) });
            return;
        }
        if (name === "fearChanged") {
            const fear = typeof e.data.fear === "number" ? e.data.fear : 0;
            if (fear >= 3) {
                this.playOnce(key, "sfx", "assets/audio/foley/fear_freeze.wav", 0.84, "escort:fear_freeze", e.tick, e.seq);
            } else if (e.data.exposed === true) {
                this.playOnce(key, "sfx", "assets/audio/foley/fear_gasp.wav", 0.78, "escort:fear_gasp", e.tick, e.seq);
            }
            return;
        }
        if (name === "pickup") {
            const kind = typeof e.data.kind === "string" ? e.data.kind : "gear";
            let pickPath = "assets/audio/interact/pickup_gear.wav";
            if (kind === "bell") {
                pickPath = "assets/audio/interact/pickup_bell.wav";
            } else if (kind === "wood" || kind === "scrap" || kind === "wedge") {
                pickPath = "assets/audio/interact/pickup_wood.wav";
            }
            this.playOnce(key, "sfx", pickPath, 0.80, "interact:pickup:" + kind, e.tick, e.seq, { pan: this.panFromData(e) });
            return;
        }
        if (name === "pickupRejected") {
            this.playOnce(key, "sfx", "assets/audio/interact/pickup_rejected.wav", 0.68, "interact:pickup_rejected", e.tick, e.seq);
            return;
        }
        if (name === "craftStart") {
            this.playOnce(key, "sfx", "assets/audio/interact/wedge_craft_loop.wav", 0.72, "craft:start", e.tick, e.seq);
            return;
        }
        if (name === "craftDone" || name === "benchCraft") {
            const recipeTag = typeof e.data.recipeId === "string"
                ? (":" + e.data.recipeId)
                : (typeof e.data.weapon === "string" ? (":" + e.data.weapon) : "");
            this.playOnce(key, "sfx", "assets/audio/combat/craft_done.wav", 0.88, "craft:done" + recipeTag, e.tick, e.seq);
            return;
        }
        if (name === "benchOpen") {
            this.playOnce(key, "sfx", "assets/audio/interact/bench_open.wav", 0.76, "bench:open", e.tick, e.seq);
            return;
        }
        if (name === "benchClose") {
            this.playOnce(key, "sfx", "assets/audio/interact/bench_close.wav", 0.70, "bench:close", e.tick, e.seq);
            return;
        }
        if (name === "benchEquip") {
            this.playOnce(key, "sfx", "assets/audio/interact/bench_equip.wav", 0.80, "bench:equip", e.tick, e.seq);
            return;
        }
        if (name === "benchRejected") {
            const recipeTag = typeof e.data.recipeId === "string" ? (":" + e.data.recipeId) : "";
            this.playOnce(key, "sfx", "assets/audio/combat/craft_insufficient.wav", 0.76, "craft:insufficient" + recipeTag, e.tick, e.seq);
            return;
        }
        if (name === "propBroken") {
            const phase = typeof e.data.phase === "string" ? e.data.phase : "broken";
            const propPath = phase === "crack" ? "assets/audio/combat/prop_crack.wav" : "assets/audio/combat/prop_break.wav";
            this.playOnce(key, "sfx", propPath, 0.84, "combat:prop_" + phase, e.tick, e.seq, { pan: this.panFromData(e) });
            return;
        }
        if (name === "interactUsed") {
            const kind = typeof e.data.kind === "string" ? e.data.kind : "";
            let path = "";
            if (kind === "wedge") path = "assets/audio/interact/wedge_place.wav";
            else if (kind === "ammo") path = "assets/audio/interact/ammo_quickload.wav";
            else if (kind === "shield") path = "assets/audio/interact/shield_deploy.wav";
            else if (kind === "pass") path = "assets/audio/interact/pass_signal.wav";
            else if (kind === "open_board") path = "assets/audio/interact/window_board_drop.wav";
            else if (kind === "lower_curtain") path = "assets/audio/interact/curtain_lower.wav";
            else if (kind === "raise_latch") path = "assets/audio/interact/latch_raise.wav";
            if (path !== "") {
                this.playOnce(key, "sfx", path, 0.86, "interact:" + kind, e.tick, e.seq, { pan: this.panFromData(e) });
            }
            return;
        }
        if (name === "roomChange") {
            this.playOnce(key, "sfx", "assets/audio/ui/chapter_banner.wav", 0.62, "ui:room_change", e.tick, e.seq);
            return;
        }
        if (name === "objectiveDone" || name === "segmentDone") {
            this.playOnce(key, "sfx", "assets/audio/ui/segment_clear.wav", 0.74, "ui:" + name, e.tick, e.seq);
            return;
        }
        if (name === "handHeld") {
            this.playOnce(key, "sfx", "assets/audio/gate/reunion_hold.wav", 0.9, "gate:hand_held", e.tick, e.seq);
            return;
        }
        if (name === "handRelease") {
            this.playOnce(key, "sfx", "assets/audio/gate/reunion_release.wav", 0.7, "gate:hand_release", e.tick, e.seq);
            return;
        }
        if (name === "carryStart") {
            this.playOnce(key, "sfx", "assets/audio/combat/carry_start.wav", 0.82, "combat:carry_start", e.tick, e.seq);
            return;
        }
        if (name === "reloadOpen") {
            this.playOnce(key, "sfx", "assets/audio/combat/reload_open.wav", 0.8, "reload:open", e.tick, e.seq);
            return;
        }
        if (name === "reloadNode") {
            const nodeTag = typeof e.data.node === "number" ? ("" + e.data.node) : "0";
            const plen = typeof e.data.pathLength === "number" ? Math.max(1, Math.min(6, Math.floor(e.data.pathLength))) : 1;
            const nodePath = resolveExisting("assets/audio/combat/reload_node_" + plen + ".wav", "assets/audio/combat/reload_node.wav");
            this.playOnce(key, "sfx", nodePath, 0.78, "reload:node:" + nodeTag, e.tick, e.seq);
            return;
        }
        if (name === "reloadInvalid") {
            this.playOnce(key, "sfx", "assets/audio/combat/reload_invalid.wav", 0.72, "reload:invalid", e.tick, e.seq);
            return;
        }
        if (name === "reloadSolved") {
            const eff = typeof e.data.effect === "string" ? e.data.effect : "push";
            this.playOnce(key, "sfx", "assets/audio/combat/reload_solved.wav", 0.9, "reload:solved:" + eff, e.tick, e.seq);
            return;
        }
        if (name === "reloadTimeout") {
            this.playOnce(key, "sfx", "assets/audio/combat/reload_timeout.wav", 0.78, "reload:timeout", e.tick, e.seq);
            return;
        }
        if (name === "reloadApplied") {
            const eff = typeof e.data.effect === "string" ? e.data.effect : "push";
            const fxPath = eff === "echo"
                ? "assets/audio/combat/reload_fx_echo.wav"
                : (eff === "light" ? "assets/audio/combat/reload_fx_light.wav" : "assets/audio/combat/reload_fx_push.wav");
            this.playOnce(key, "sfx", fxPath, 0.84, "reload:applied:" + eff, e.tick, e.seq, { pan: this.panFromData(e) });
            return;
        }
        if (name === "artifactFound") {
            this.playOnce(key, "sfx", "assets/audio/museum/artifact_pickup.wav", 0.88, "museum:artifact_found", e.tick, e.seq);
            return;
        }
        if (name === "museumStep") {
            const step = typeof e.data.step === "string" ? e.data.step : "";
            const cnt = typeof e.data.count === "number" ? e.data.count : 1;
            if (step === "cabinet") {
                this.playOnce(key, "sfx", "assets/audio/museum/weapon_holster.wav", 0.78, "museum:step:cabinet", e.tick, e.seq);
            } else if (step === "hall") {
                this.playOnce(key, "sfx", "assets/audio/museum/child_steps_echo.wav", 0.76, "museum:step:hall", e.tick, e.seq);
            } else if (step === "lamp") {
                this.playOnce(key, "sfx", "assets/audio/museum/lamp_turn.wav", 0.82, "museum:step:lamp", e.tick, e.seq);
            } else if (step === "knock") {
                const knockPath = cnt >= 2
                    ? "assets/audio/museum/knock_cabinet_second.wav"
                    : "assets/audio/museum/knock_hall_first.wav";
                this.playOnce(key, "sfx", knockPath, 0.90, "museum:step:knock:" + cnt, e.tick, e.seq);
            }
            return;
        }
        if (name === "museumDone") {
            this.playOnce(key, "voice", "assets/audio/museum/line_dawn.wav", 0.88, "museum:done", e.tick, e.seq);
            return;
        }
        if (name === "storyBeat") {
            const beat = typeof e.data.beat === "string" ? e.data.beat : "";
            const pan = this.panFromData(e);
            if (beat === "red_cart") {
                this.playOnce(key, "sfx", "assets/audio/child/cart_dock.wav", 0.84, "story:red_cart", e.tick, e.seq, { pan });
            } else if (beat === "red_cart_memory") {
                this.playOnce(key, "sfx", "assets/audio/child/sewing_memory.wav", 0.86, "story:red_cart_memory", e.tick, e.seq);
            } else if (beat === "footstep_near") {
                const pNear = resolveExisting("assets/audio/foley/step_scavenger_1.wav", "assets/audio/museum/hall_footstep.wav");
                this.playOnce(key, "sfx", pNear, 0.76, "story:footstep_near", e.tick, e.seq, { pan });
            } else if (beat === "footstep_far") {
                const pFar = resolveExisting("assets/audio/foley/step_scavenger_2.wav", "assets/audio/museum/hall_footstep.wav");
                this.playOnce(key, "sfx", pFar, 0.36, "story:footstep_far", e.tick, e.seq, { pan });
            } else if (beat === "ditch" || beat === "path_burrow") {
                this.playOnce(key, "sfx", "assets/audio/child/twig_snap.wav", 0.76, "story:" + beat, e.tick, e.seq, { pan });
            } else if (beat === "path_ditch") {
                this.playOnce(key, "sfx", "assets/audio/child/dog_step.wav", 0.78, "story:path_ditch", e.tick, e.seq, { pan });
            } else if (beat === "water_lantern") {
                this.playOnce(key, "sfx", "assets/audio/tower/lamp_move.wav", 0.74, "story:water_lantern", e.tick, e.seq);
            } else if (beat === "tower_door") {
                this.playOnce(key, "sfx", "assets/audio/tower/door_open.wav", 0.78, "story:tower_door", e.tick, e.seq);
            } else if (beat === "tower_threshold") {
                const pStep = resolveExisting("assets/audio/foley/step_child_stone_1.wav", "assets/audio/museum/hall_footstep.wav");
                this.playOnce(key, "sfx", pStep, 0.68, "story:tower_threshold", e.tick, e.seq);
            } else if (beat === "tower_handover") {
                this.playOnce(key, "sfx", "assets/audio/tower/needle_case_place.wav", 0.86, "story:tower_handover", e.tick, e.seq);
            } else if (beat === "talent_picked") {
                const pTal = resolveExisting("assets/audio/ui/talent_pick.wav", "assets/audio/combat/reload_solved.wav");
                this.playOnce(key, "sfx", pTal, 0.82, "story:talent_picked", e.tick, e.seq);
            }
        }
    }

    hasPlayed(dedupeKey: string): boolean {
        return this.dedupeSet[dedupeKey] === true;
    }

    getPlayLog(): readonly AudioLogEntry[] {
        return this.playLog;
    }

    getLastEntry(): AudioLogEntry | undefined {
        if (this.playLog.length === 0) {
            return undefined;
        }
        return this.playLog[this.playLog.length - 1];
    }

    clearPlayLog(): void {
        this.playLog = [];
    }

    getTrackList(): readonly AudioTrack[] {
        return ALL_TRACKS;
    }

    private pruneStoppedSources(): void {
        let w = 0;
        let i = 0;
        for (i = 0; i < this.activeSources.length; i++) {
            const src = this.activeSources[i];
            if (src.playing) {
                this.activeSources[w] = src;
                w += 1;
            } else {
                src.removeFromParent(true);
            }
        }
        this.activeSources.length = w;
    }

    private recordLog(entry: AudioLogEntry): void {
        this.playLog.push(entry);
        if (this.playLog.length > MAX_PLAY_LOG) {
            this.playLog.shift();
        }
    }
}
