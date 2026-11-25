/**
 * 《向西守望》分轨音频与事件防重播控制器（Phase 0 · feature/fe-00-foundation）。
 *
 * 核心约束（对齐 00-foundation.md 与 64fc06f）：
 * 1. 支持 5 条逻辑音轨：voice / wind / water / ambience / sfx，独立增益与静音控制；
 * 2. 缺失容错：播放前统一用 Content.exist(path) 校验，资源未放入 assets/audio/ 时静默记录逻辑播放日志而不抛异常；
 * 3. 按事件序号/节拍去重：playOnce(dedupeKey, ...) 确保 0 步帧、暂停重绘、重复采样绝不重复触发同一声数数或敲门；
 * 4. 单帧多步事件逐条派发：ingestEvents() 消费 PlayAdapter.sample 唯一 drainEvents() 产出的有序 rawEvents，
 *    一帧补跑跨过两次事件时各响一次，读档/重试重建不补播旧事件；
 * 5. 暂停冻结与恢复续播：setPaused(paused) 冻结当前声源位置，恢复后从同一拍/同一位置续播；
 * 6. 提供可查询播放记录 getPlayLog()，便于自动化脚本断言「声音、字幕和手势各出现一次」。
 */

import { Audio, AudioBus, AudioSource, Content, Node } from "Dora";
import { Play, PlayEvent } from "Script/watch/play";
import { FrameEvents } from "Script/watch/fe/adapter";

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

interface ActiveLoop {
    track: AudioTrack;
    path: string;
    volume: number;
    source: AudioSource.Type | undefined;
}

const ALL_TRACKS: AudioTrack[] = ["voice", "wind", "water", "ambience", "sfx"];
const MAX_PLAY_LOG = 256;

function clamp01(v: number): number {
    return Math.max(0, Math.min(1, v));
}

function safeCreateBus(): AudioBus.Type | undefined {
    if (typeof AudioBus === "function") {
        return AudioBus();
    }
    return undefined;
}

export class AudioDirector {
    private hostNode: Node.Type | undefined;
    private buses: Record<AudioTrack, AudioBus.Type | undefined>;
    private trackVolumes: Record<AudioTrack, number>;
    private trackMuted: Record<AudioTrack, boolean>;
    private activeSources: AudioSource.Type[] = [];
    private activeHandlers: number[] = [];
    private activeLoops: Record<string, ActiveLoop> = {};
    private dedupeSet: Record<string, boolean> = {};
    private playLog: AudioLogEntry[] = [];
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

    isTrackMuted(track: AudioTrack): boolean {
        return this.trackMuted[track];
    }

    setTrackMuted(track: AudioTrack, muted: boolean): void {
        this.trackMuted[track] = muted;
        this.syncBusGain(track);
    }

    /** 调整世界音轨播放速率（如换弹慢时同步微调环境音速，保留 voice 清晰） */
    setWorldPlaySpeed(speed: number): void {
        const next = Math.max(0.25, Math.min(2.0, speed));
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

    private syncBusGain(track: AudioTrack): void {
        const bus = this.buses[track];
        if (bus !== undefined) {
            bus.volume = this.trackMuted[track] ? 0 : this.trackVolumes[track];
        }
    }

    /**
     * 按去重键播放一次性音效/配音：
     * - 同一房间会话内命中相同 dedupeKey 时直接跳过，返回 false；
     * - 文件尚未放入 assets/audio/ 时静默记录逻辑日志（playedBackend = false）而不抛错。
     */
    playOnce(
        dedupeKey: string,
        track: AudioTrack,
        path: string,
        volume: number = 1,
        cueId: string = "",
        tick: number = 0,
        seq: number = -1,
    ): boolean {
        if (dedupeKey !== "" && this.dedupeSet[dedupeKey] === true) {
            return false;
        }
        if (dedupeKey !== "") {
            this.dedupeSet[dedupeKey] = true;
        }

        const effectiveVol = clamp01(volume) * (this.trackMuted[track] ? 0 : this.trackVolumes[track]);
        let playedBackend = false;

        if (path !== "" && Content.exist(path)) {
            this.pruneStoppedSources();
            const bus = this.buses[track];
            const src = typeof AudioSource === "function" ? AudioSource(path, false, bus) : undefined;
            if (src !== undefined) {
                src.volume = effectiveVol;
                src.looping = false;
                if (this.hostNode !== undefined) {
                    src.addTo(this.hostNode);
                }
                playedBackend = src.play();
                if (playedBackend) {
                    this.activeSources.push(src);
                } else {
                    src.removeFromParent(true);
                }
            } else if (typeof Audio !== "undefined" && typeof Audio.play === "function") {
                const handler = Audio.play(path, false);
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
        if (prev !== undefined && prev.path === path && prev.track === track) {
            prev.volume = clampedVol;
            if (prev.source !== undefined) {
                prev.source.volume = clampedVol * (this.trackMuted[track] ? 0 : this.trackVolumes[track]);
            }
            return false;
        }
        if (prev !== undefined) {
            this.stopLoop(loopId, 0);
        }

        let source: AudioSource.Type | undefined;
        let playedBackend = false;
        if (path !== "" && Content.exist(path)) {
            const bus = this.buses[track];
            const created = typeof AudioSource === "function" ? AudioSource(path, false, bus) : undefined;
            if (created !== undefined) {
                created.looping = true;
                created.volume = clampedVol * (this.trackMuted[track] ? 0 : this.trackVolumes[track]);
                if (this.hostNode !== undefined) {
                    created.addTo(this.hostNode);
                }
                playedBackend = created.play();
                source = created;
            }
        }

        this.activeLoops[loopId] = {
            track,
            path,
            volume: clampedVol,
            source,
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
        delete this.activeLoops[loopId];
    }

    /** 暂停冻结全部正在播放的音轨与位置，恢复后从同一位置续播 */
    setPaused(paused: boolean): void {
        if (this.paused === paused) {
            return;
        }
        this.paused = paused;
        if (typeof Audio !== "undefined" && typeof Audio.setPauseAllCurrent === "function") {
            Audio.setPauseAllCurrent(paused);
        }
    }

    /** 切房或重试时停止本房所有瞬时音与循环音，清空本房去重表 */
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

        this.dedupeSet = {};
        if (this.paused) {
            this.setPaused(false);
        }
        this.setWorldPlaySpeed(1);
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

    private dispatchSingleEvent(
        e: PlayEvent,
        roomSessionId: number,
        checkpoint: number,
        p: Play,
    ): void {
        const key = "r" + roomSessionId + ":cp" + checkpoint + ":t" + e.tick + ":s" + e.seq + ":" + e.name;
        if (e.name === "knock") {
            const roomTag = typeof e.data.room === "string" ? e.data.room : p.room.key;
            const countTag = typeof e.data.count === "number" ? ("" + e.data.count) : "1";
            this.playOnce(key, "sfx", "assets/audio/sfx/knock.wav", 0.9, "knock:" + roomTag + ":" + countTag, e.tick, e.seq);
            return;
        }
        if (e.name === "shotResolved") {
            const hit = e.data.hit === true;
            this.playOnce(key, "sfx", "assets/audio/combat/shot.wav", 0.85, hit ? "shot:hit" : "shot:fire", e.tick, e.seq);
            return;
        }
        if (e.name === "coverBlocked") {
            this.playOnce(key, "sfx", "assets/audio/combat/cover_block.wav", 0.85, "cover:blocked", e.tick, e.seq);
            return;
        }
        if (e.name === "actorHit" || e.name === "gateFailed") {
            this.playOnce(key, "sfx", "assets/audio/combat/actor_hit.wav", 0.9, "actor:hit", e.tick, e.seq);
            return;
        }
        if (e.name === "bottleLanded") {
            const surface = typeof e.data.surface === "string" ? e.data.surface : "brick";
            const path = surface === "iron"
                ? "assets/audio/child/bottle_iron.wav"
                : (surface === "soft" ? "assets/audio/child/bottle_soft.wav" : "assets/audio/child/bottle_brick.wav");
            this.playOnce(key, "sfx", path, 0.9, "bottle:" + surface, e.tick, e.seq);
            return;
        }
        if (e.name === "cartDocked") {
            this.playOnce(key, "sfx", "assets/audio/child/cart_dock.wav", 0.88, "cart:docked", e.tick, e.seq);
            return;
        }
        if (e.name === "craftDone" || (e.name as string) === "benchCraft") {
            const recipeTag = typeof e.data.recipeId === "string"
                ? (":" + e.data.recipeId)
                : (typeof e.data.weapon === "string" ? (":" + e.data.weapon) : "");
            this.playOnce(key, "sfx", "assets/audio/combat/craft_done.wav", 0.88, "craft:done" + recipeTag, e.tick, e.seq);
            return;
        }
        // 兼容 A单 / B1 / B2 后端新增事件（story-b1-carry / story-b2-escort）：按事件名动态派发，零侵入 PlayEventName 静态联合
        const name = e.name as string;
        if (name === "benchRejected") {
            const recipeTag = typeof e.data.recipeId === "string" ? (":" + e.data.recipeId) : "";
            this.playOnce(key, "sfx", "assets/audio/combat/craft_insufficient.wav", 0.76, "craft:insufficient" + recipeTag, e.tick, e.seq);
        } else if (name === "handHeld") {
            this.playOnce(key, "sfx", "assets/audio/gate/reunion_hold.wav", 0.9, "gate:hand_held", e.tick, e.seq);
        } else if (name === "handRelease") {
            this.playOnce(key, "sfx", "assets/audio/gate/reunion_release.wav", 0.7, "gate:hand_release", e.tick, e.seq);
        } else if (name === "carryStart") {
            this.playOnce(key, "sfx", "assets/audio/combat/carry_start.wav", 0.82, "combat:carry_start", e.tick, e.seq);
        } else if (name === "reloadOpen") {
            this.playOnce(key, "sfx", "assets/audio/combat/reload_open.wav", 0.8, "reload:open", e.tick, e.seq);
        } else if (name === "reloadNode") {
            const nodeTag = typeof e.data.node === "number" ? ("" + e.data.node) : "0";
            this.playOnce(key, "sfx", "assets/audio/combat/reload_node.wav", 0.78, "reload:node:" + nodeTag, e.tick, e.seq);
        } else if (name === "reloadInvalid") {
            this.playOnce(key, "sfx", "assets/audio/combat/reload_invalid.wav", 0.72, "reload:invalid", e.tick, e.seq);
        } else if (name === "reloadSolved") {
            const eff = typeof e.data.effect === "string" ? e.data.effect : "push";
            this.playOnce(key, "sfx", "assets/audio/combat/reload_solved.wav", 0.9, "reload:solved:" + eff, e.tick, e.seq);
        } else if (name === "reloadTimeout") {
            this.playOnce(key, "sfx", "assets/audio/combat/reload_timeout.wav", 0.78, "reload:timeout", e.tick, e.seq);
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
