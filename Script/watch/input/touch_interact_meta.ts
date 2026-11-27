/**
 * 《向西守望》触控情境交互大钮文案推导（仅安卓、掌机、Web 触控覆盖层引入）。
 *
 * Windows 发行包不引入、不打包本模块。
 */

import { inReachDepth } from "Script/watch/depth";
import { Play } from "Script/watch/play";
import { WorldPrompt } from "Script/watch/fe/adapter";
import { InteractActionMeta } from "Script/watch/target_types";

export function deriveInteractActionMeta(
    p: Play,
    prompt: WorldPrompt | undefined,
    cartNearby: boolean,
    cartLatched: boolean,
): InteractActionMeta {
    if (cartNearby) {
        if (cartLatched || p.gripping) {
            return { label: "松手", subLabel: "推车中", urgent: false, progress: 0, available: true };
        }
        return {
            label: p.room.key === "outside" ? "拉车" : "推车",
            subLabel: "点按锁定",
            urgent: true,
            progress: 0,
            available: true,
        };
    }

    if (p.phase === "gate-wait") {
        const prog = Math.max(0, Math.min(1, p.handTicks / Math.max(1, p.handNeedTicks)));
        return { label: "牵手", subLabel: "长按", urgent: true, progress: prog, available: true };
    }
    if (p.phase === "tower-desk") {
        const prog = Math.max(0, Math.min(1, p.deskHold / 36));
        return { label: "交物", subLabel: "长按", urgent: true, progress: prog, available: true };
    }
    if (p.craftT > 0) {
        return { label: "削楔", subLabel: "长按", urgent: true, progress: Math.min(1, p.craftT / 30), available: true };
    }

    if (prompt !== undefined) {
        const kt = prompt.keyTag;
        if (kt.indexOf("E") >= 0) {
            let short = "交互";
            if (prompt.label.indexOf("指南针") >= 0 || prompt.label.indexOf("针套") >= 0) short = "递物";
            else if (prompt.label.indexOf("安抚") >= 0) short = "安抚";
            else if (prompt.label.indexOf("守门") >= 0) short = "守门";
            else if (prompt.label.indexOf("送小满") >= 0) short = "送别";
            else if (prompt.label.indexOf("工台") >= 0) short = "工台";
            else if (prompt.label.indexOf("窗板") >= 0) short = "窗板";
            else if (prompt.label.indexOf("木帘") >= 0) short = "木帘";
            else if (prompt.label.indexOf("门锁") >= 0) short = "抬锁";
            else if (prompt.label.indexOf("瓶") >= 0) short = "拾瓶";
            else if (prompt.label.indexOf("收枪") >= 0) short = "收枪";
            else if (prompt.label.indexOf("灯") >= 0) short = "转灯";
            else if (prompt.label.indexOf("敲") >= 0) short = "轻敲";
            return {
                label: short,
                subLabel: kt.indexOf("按住") >= 0 ? "长按" : undefined,
                urgent: prompt.urgent,
                progress: prompt.progress ?? 0,
                available: true,
            };
        }
    }

    const nearWell = Math.abs(p.player.x - (p.ox + p.wellX)) <= 44
        && p.player.y < 20 && inReachDepth(p.player.depth, 0);
    if (p.room.key === "prologue" && p.phase === "prologue-wait" && nearWell
        && (p.wellOpen || (p.archive.artifactOwned && !p.archive.museumSeen))) {
        return {
            label: p.wellOpen ? "取器" : "入馆",
            urgent: true,
            progress: 0,
            available: true,
        };
    }

    if (!p.childMode && p.run.inventory.scrap > 0 && p.run.inventory.wedge < 3 && prompt === undefined) {
        return { label: "削楔", subLabel: "长按", urgent: false, progress: 0, available: true };
    }

    return { label: "交互", urgent: false, progress: 0, available: false };
}
