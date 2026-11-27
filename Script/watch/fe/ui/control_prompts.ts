/**
 * 《向西守望》三模统一按键提示、世界标牌与「执器要诀」文案唯一真源。
 *
 * 职责：
 * - 消灭原 gamepad.ts / hud.ts / narrative.ts / menus.ts / tower_endings.ts 中四处散落的字符串替换；
 * - 保证键鼠（kbm）/ 手柄（gamepad，支持 xbox 与 nintendo 确认布局）/ 触屏（touch）三套提示完全统一；
 * - 提供共享的 deriveInteractActionMeta()，让 HUD 气泡与触控「交互」大钮保持完全一致的情境动词。
 */

import { inReachDepth } from "Script/watch/depth";
import { GATE_COUNT_END, Play } from "Script/watch/play";
import { GamepadLayout, InputMode } from "Script/watch/controls_config";
import { WorldPrompt } from "Script/watch/fe/adapter";

export type KeyActionId =
    | "interact"
    | "jump"
    | "crouch"
    | "cover"
    | "fire"
    | "aim"
    | "pause"
    | "retry"
    | "confirm"
    | "back"
    | "artifact";

export interface InteractActionMeta {
    label: string;
    subLabel?: string;
    urgent: boolean;
    progress: number;
    available: boolean;
}

/** 根据当前输入模式与手柄布局，返回统一按键微标文案。 */
export function keyTagFor(
    action: KeyActionId,
    mode: InputMode,
    layout: GamepadLayout = "xbox",
): string {
    if (mode === "gamepad") {
        const confirmBtn = layout === "nintendo" ? "B" : "A";
        const backBtn = layout === "nintendo" ? "A" : "B";
        if (action === "interact") return "Y / RB";
        if (action === "jump") return "A";
        if (action === "crouch") return "B";
        if (action === "cover") return "LT / LB";
        if (action === "fire") return "RT / X";
        if (action === "aim") return "RT / X";
        if (action === "pause") return "START";
        if (action === "retry") return "长按 BACK";
        if (action === "confirm") return confirmBtn;
        if (action === "back") return backBtn;
        return "L3";
    }
    if (mode === "touch") {
        if (action === "interact") return "点按";
        if (action === "jump") return "跳/滚";
        if (action === "crouch") return "蹲伏";
        if (action === "cover") return "掩体";
        if (action === "fire") return "开火";
        if (action === "aim") return "拖投瓶";
        if (action === "pause") return "暂歇";
        if (action === "retry") return "重试";
        if (action === "confirm") return "点选";
        if (action === "back") return "返回";
        return "穿梭";
    }
    if (action === "interact") return "E";
    if (action === "jump") return "SPACE";
    if (action === "crouch") return "CTRL";
    if (action === "cover") return "SHIFT";
    if (action === "fire") return "左键";
    if (action === "aim") return "F";
    if (action === "pause") return "ESC";
    if (action === "retry") return "R";
    if (action === "confirm") return "ENTER";
    if (action === "back") return "ESC";
    return "T";
}

/** 将世界提示的原始键鼠键帽文案转换为当前输入模式的对应键标。 */
export function adaptWorldKeyTag(
    rawKeyTag: string,
    mode: InputMode,
    _layout: GamepadLayout = "xbox",
): string {
    if (mode === "kbm") return rawKeyTag;
    if (mode === "gamepad") {
        if (rawKeyTag === "E") return "Y";
        if (rawKeyTag === "按住 E") return "按住 Y";
        if (rawKeyTag === "松开再按住 E") return "松开再按 Y";
        if (rawKeyTag === "按住 E + D") return "按住 Y + 右";
        if (rawKeyTag === "E 握柄 + D") return "Y 握柄 + 右";
        if (rawKeyTag === "F") return "RT / X";
        if (rawKeyTag === "按住 F") return "按住 RT";
        if (rawKeyTag === "松开 F") return "松开 RT";
        if (rawKeyTag === "按住 Ctrl") return "按住 B";
        if (rawKeyTag === "按住 Shift") return "按住 LT";
        if (rawKeyTag === "连线") return "摇杆/触屏连线";
        if (rawKeyTag === "→") return "右推摇杆";
        return rawKeyTag;
    }
    // touch
    if (rawKeyTag === "E") return "轻触";
    if (rawKeyTag === "按住 E") return "长按交互";
    if (rawKeyTag === "松开再按住 E") return "松开再长按";
    if (rawKeyTag === "按住 E + D" || rawKeyTag === "E 握柄 + D") return "点推车+摇杆";
    if (rawKeyTag === "F") return "开火";
    if (rawKeyTag === "按住 F") return "拖投瓶";
    if (rawKeyTag === "松开 F") return "松手投";
    if (rawKeyTag === "按住 Ctrl") return "点蹲伏";
    if (rawKeyTag === "按住 Shift") return "点掩体";
    if (rawKeyTag === "连线") return "一笔划连";
    return rawKeyTag;
}

/** 将开启「按键辅助」时的叙事/HUD 提示句中的键鼠键名替换为当前输入模式键名。 */
export function adaptHintSentence(
    text: string,
    mode: InputMode,
    layout: GamepadLayout = "xbox",
): string {
    if (mode === "kbm" || text === "") return text;
    if (mode === "gamepad") {
        const backBtn = layout === "nintendo" ? "A" : "B";
        return text
            .split("[SHIFT]").join("[LT/LB]")
            .split("[CTRL]").join("[B]")
            .split("[E]+[D]").join("[Y]+右推")
            .split("[E]").join("[Y]")
            .split("[F]").join("[RT/X]")
            .split("[SPACE]").join("[A]")
            .split("[W/S]").join("左摇杆上下")
            .split("[A/D]").join("左摇杆左右")
            .split("[W]").join("左摇杆向上")
            .split("[S]").join("左摇杆向下")
            .split("[ESC]").join("[START]")
            .split("[R]").join("长按 [BACK]")
            .split("鼠标瞄准，左键发射火铳").join("右摇杆瞄准，按 [RT/X] 发射火铳")
            .split("左键先手击倒").join("按 [RT/X] 先手击倒")
            .split("左键发射火铳").join("按 [RT/X] 发射火铳")
            .split("左键发铳").join("按 [RT/X] 发铳")
            .split("按 E 再次启程").join("按 Y 再次启程")
            .split("Esc 暂歇").join("START 暂歇")
            .split("返回").join("按 " + backBtn + " 返回");
    }
    // touch
    return text
        .split("按住 [E]+[D]").join("点按推/拉车并推摇杆")
        .split("[E]+[D]").join("推/拉车并推摇杆")
        .split("速按 [CTRL]").join("点按「蹲伏」")
        .split("按住 [CTRL]").join("点按「蹲伏」")
        .split("按 [CTRL]").join("点按「蹲伏」")
        .split("[CTRL]").join("「蹲伏」")
        .split("按住 [SHIFT]").join("点按「轻步/掩体」")
        .split("[SHIFT]").join("「轻步/掩体」")
        .split("按住 [F]").join("按住「投瓶」拖拽")
        .split("[F]").join("「投瓶」")
        .split("按 [E]").join("点按「交互」")
        .split("[E]").join("「交互」")
        .split("按 [ESC]").join("轻触右上「暂歇」")
        .split("[ESC]").join("右上「暂歇」")
        .split("按 [SPACE]").join("点按「翻滚/跳跃」")
        .split("[SPACE]").join("「翻滚/跳跃」")
        .split("按 [R]").join("在暂歇菜单重试")
        .split("[A/D]").join("左下摇杆")
        .split("[W/S]").join("摇杆上下")
        .split("[W]").join("摇杆向上")
        .split("[S]").join("摇杆向下")
        .split("鼠标瞄准，左键发射火铳").join("点屏或拖「开火」发射火铳")
        .split("左键先手击倒").join("点屏或「开火」先手击倒")
        .split("左键发射火铳").join("点屏或「开火」发射火铳")
        .split("左键发铳").join("点屏或「开火」发铳")
        .split("左键").join("点屏或「开火」")
        .split("鼠标").join("触屏")
        .split("按 E 再次启程").join("轻触屏幕再次启程")
        .split("Esc 暂歇").join("轻触右上暂歇");
}

/** 「执器要诀」三页统一键位对照表（周戍 / 小满，覆盖键鼠、手柄、触屏全部主流操控）。 */
export function controlsGuideRows(tab: InputMode): {
    subtitle: string;
    soldierRows: [string, string][];
    childRows: [string, string][];
} {
    if (tab === "gamepad") {
        return {
            subtitle: "手柄操作说明 · 全平台通用",
            soldierRows: [
                ["左摇杆 / 十字键", "左右、前后纵深移动"],
                ["右摇杆 + RT / X", "360° 瞄准与发射火铳（含轻磁吸）"],
                ["按住 LT / LB", "贴靠柜台 / 街垒挡下铅丸"],
                ["A 键", "平地翻滚 / 靠近矮柜翻越"],
                ["Y / RB 键", "递物 / 轻敲安抚 / 按住推车"],
                ["摇杆直推 / 触屏", "慢时连线换弹 · B 键清空重画"],
            ],
            childRows: [
                ["左摇杆轻推", "内圈轻步慢走（LT/LB 亦可）"],
                ["B 键", "蹲伏隐蔽 · 穿低拱与桌底"],
                ["A 键", "跳跃攀上石阶与矮台"],
                ["Y / RB 键", "拾瓶 / 敲塔门 / 握柄拉车"],
                ["RT/X 按住→松开", "右摇杆调落点投瓶 · B 取消"],
                ["START / BACK", "暂歇 / 长按重试 · L3 切神器"],
            ],
        };
    }
    if (tab === "touch") {
        return {
            subtitle: "触屏操作说明 · 横屏全屏 / 竖屏掌机台",
            soldierRows: [
                ["左水墨摇杆", "全向走位与里外道切线"],
                ["点屏 / 开火钮", "直点射击或拖住开火钮 360° 精瞄"],
                ["掩体开关", "轻点贴靠掩体，再点或翻滚离掩"],
                ["翻滚 / 翻越", "平地翻滚，贴近矮柜自动翻越"],
                ["交互 / 推车", "点推车自动锁握柄，长按牵手交物"],
                ["换弹九宫格", "单指一笔滑连至右上，点重画清空"],
            ],
            childRows: [
                ["摇杆内圈 / 轻步", "轻推内圈或点轻步压低脚步声"],
                ["蹲伏开关", "点按蹲下钻桌穿拱，点跳顺滑起身"],
                ["跳跃钮", "攀上石阶、红布车与矮台"],
                ["投瓶拖瞄", "按住投瓶拖向砖地，拖回取消圈放弃"],
                ["交互 / 拉车", "拾瓶、敲塔门、点拉车锁定握柄"],
                ["右上暂歇 / 竖屏", "顶栏随时暂歇，竖屏自动展掌机台"],
            ],
        };
    }
    return {
        subtitle: "键鼠操作说明 · 全平台通用",
        soldierRows: [
            ["WASD / 方向键", "左右、前后自由移动"],
            ["鼠标 + 左键", "瞄准与发射火铳"],
            ["按住 SHIFT", "贴靠柜台 / 街垒挡下铅丸"],
            ["SPACE", "平地翻滚 / 靠近矮柜翻越"],
            ["E", "递物 / 轻敲安抚 / 按住+D 推车"],
            ["ESC / R / T", "暂歇菜单 / 重试检查点 / 切神器"],
        ],
        childRows: [
            ["A / D · ← / →", "左右潜行"],
            ["按住 SHIFT", "轻步慢走（压低脚步声）"],
            ["按住 S / CTRL", "蹲伏隐蔽 · 穿低拱与桌底"],
            ["SPACE", "跳跃攀上石阶与矮台"],
            ["E", "拾瓶 / 敲塔门 / 按住+D 拉车"],
            ["F 按住→松开", "瞄准砖地，投瓶引开拾荒者"],
        ],
    };
}

/** 判断当前房间阶段是否处于电影过场阻塞期（需隐藏战斗虚拟按钮）。 */
export function isCutsceneBlockingPlay(p: Play): boolean {
    const rk = p.room.key;
    const ph = p.phase;
    if (rk === "prologue"
        && (ph === "prologue-wake" || ph === "prologue-shadow" || ph === "prologue-hide"
            || ph === "prologue-give" || ph === "prologue-well")) {
        return true;
    }
    if (rk === "gate") {
        if (ph === "gate-hand") return true;
        if (ph === "gate-count" && p.countTick < GATE_COUNT_END) return true;
    }
    if (rk === "tower" && (ph === "tower-knock" || ph === "tower-given" || ph === "tower-end")) {
        return true;
    }
    if (rk === "museum" && ph === "museum-knock") {
        return true;
    }
    return false;
}

/** 推导情境交互按钮文案与长按进度（供触控大钮与引导共用）。 */
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
