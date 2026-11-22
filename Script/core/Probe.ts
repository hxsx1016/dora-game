/**
 * D1 探针：中文标题 + 方向键方块 + 引擎内自检。
 *
 * 自检覆盖两件事：
 * 1. 多文件模块是否被打包进 init.lua（本文件与 game/levels.ts 的标记都要出现在日志里）；
 * 2. 两张关卡地图能否被 parseLevel 正确读取，三类坏图能否被拒绝。
 *
 * 所有结果写 Content.save 的 marker，外部用轮询读文件即可做引擎内验证。
 */
import { Color, Content, DrawNode, KeyName, Label, Node, Rect, TextAlign, Vec2, View } from "Dora";
import { describeLevel, parseLevel } from "Script/game/levels";

const FONT = "sarasa-mono-sc-regular";
const MARKER = "d1-probe.result";
const LOG = "probe.log";
const STEP = 32;

const logs: string[] = [];
let marker = "";

function log(text: string): void {
    logs.push(text);
    Content.save(LOG, logs.join("\n"));
}

function writeMarker(text: string): void {
    marker = text;
    Content.save(MARKER, marker);
}

/** 一次自检：跑好/坏输入，返回 "ok" 或错误摘要。 */
function checkParse(name: string, input: string, shouldPass: boolean): string {
    let detail = "";
    let passed = false;
    try {
        const level = parseLevel(name, input);
        detail = describeLevel(level);
        passed = shouldPass;
    } catch (error) {
        detail = "error:" + tostring(error);
        passed = shouldPass === false;
    }
    log("selftest " + name + (passed === true ? " PASS " : " FAIL ") + detail);
    return passed === true ? "ok" : "fail(" + detail + ")";
}

export class Probe {
    static mount(root: Node.Type): void {
        const w = View.size.width;
        const h = View.size.height;

        // 自检先行：即使 UI 出问题，marker 里也有结构化结论。
        const r1 = checkParse("level1", "aS.AE", true);
        const r2 = checkParse("level2", "baS.ABE", true);
        const r3 = checkParse("bad-width", "aS.AE\nS...", false);
        const r4 = checkParse("bad-char", "aX.AE", false);
        const r5 = checkParse("bad-start", "a.AE", false);

        // 首关初态摘要：D1 交付要求留下「一份首关初态」。
        let level1Text = "";
        try {
            level1Text = describeLevel(parseLevel("level1", "aS.AE"));
        } catch (error) {
            level1Text = "error:" + tostring(error);
        }

        const title = Label(FONT, 44, false);
        if (title !== undefined) {
            title.text = "借我六步 · D1 探针";
            title.color = Color(244, 239, 230, 255);
            title.alignment = TextAlign.Center;
            title.anchor = Vec2(0.5, 1);
            title.position = Vec2(w / 2, h - 48);
            root.addChild(title);
        }

        const hint = Label(FONT, 18, false);
        if (hint !== undefined) {
            hint.text = "方向键移动方块 · 每次一格 32px";
            hint.color = Color(158, 150, 140, 255);
            hint.alignment = TextAlign.Center;
            hint.anchor = Vec2(0.5, 1);
            hint.position = Vec2(w / 2, h - 108);
            root.addChild(hint);
        }

        const levelLine = Label(FONT, 18, false);
        if (levelLine !== undefined) {
            levelLine.text = "首关 aS.AE · " + level1Text;
            levelLine.color = Color(196, 186, 172, 255);
            levelLine.alignment = TextAlign.Center;
            levelLine.anchor = Vec2(0.5, 0);
            levelLine.position = Vec2(w / 2, 84);
            root.addChild(levelLine);
        }

        const status = Label(FONT, 18, false);
        if (status !== undefined) {
            status.color = Color(232, 197, 138, 255);
            status.alignment = TextAlign.Center;
            status.anchor = Vec2(0.5, 0);
            status.position = Vec2(w / 2, 40);
            root.addChild(status);
        }

        const box = DrawNode();
        root.addChild(box);

        let bx = w / 2;
        let by = h / 2;
        let count = 0;

        const draw = () => {
            box.clear();
            box.drawRect(Rect(bx - 24, by - 24, 48, 48), Color(232, 197, 138, 255));
            box.drawRect(Rect(bx - 24, by - 24, 48, 48), Color(14, 12, 20, 120), 2, Color(244, 239, 230, 255));
        };

        const refresh = () => {
            if (status !== undefined) {
                status.text = "按键 " + count + " 次 · 方块 (" + bx + ", " + by + ") · view " + w + "x" + h;
            }
            writeMarker("d1-probe|v2|title=借我六步·D1探针|level1=" + r1 + "|level2=" + r2
                + "|bad-width=" + r3 + "|bad-char=" + r4 + "|bad-start=" + r5
                + "|keys=" + count + "|box=" + bx + "," + by
                + "|view=" + w + "x" + h + "|level1=" + level1Text);
        };

        draw();
        log("boot: probe v2 mounted, view=" + w + "x" + h);
        log("selftest summary level1=" + r1 + " level2=" + r2 + " bad-width=" + r3
            + " bad-char=" + r4 + " bad-start=" + r5);
        refresh();

        const move = (key: KeyName) => {
            count++;
            if (key === KeyName.Left) {
                bx -= STEP;
            } else if (key === KeyName.Right) {
                bx += STEP;
            } else if (key === KeyName.Up) {
                by += STEP;
            } else if (key === KeyName.Down) {
                by -= STEP;
            }
            log("key " + key + " -> box (" + bx + "," + by + ") step=" + STEP + " count=" + count);
            draw();
            refresh();
        };

        root.onKeyDown((key: KeyName) => {
            move(key);
        });

        log("input hooked on root");
    }
}
