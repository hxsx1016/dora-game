/**
 * D1 探针：中文标题 + 方向键方块 + 引擎内自检。
 *
 * 自检覆盖两件事：
 * 1. 多文件模块是否被打包进 init.lua（本文件与 game/levels.ts 的标记都要出现在日志里）；
 * 2. 两张关卡地图能否被 parseLevel 正确读取，三类坏图能否被拒绝。
 *
 * 所有结果写 Content.save 的 marker，外部用轮询读文件即可做引擎内验证。
 */
import { Color, Content, DrawNode, KeyName, Label, Node, Rect, Size, TextAlign, Vec2, View } from "Dora";
import { describeLevel, loadLevel, parseLevel } from "Script/game/levels";
import { Command, Result, State, advance, echoAt, playback, shownGroups, start } from "Script/game/turn";
import { Session, createSession, dispatch } from "Script/game/session";

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

/** 依次送命令，返回最后一个结果；每一步写日志。 */
function runSeq(level: ReturnType<typeof loadLevel>, commands: Command[]): Result {
    let state: State = start(level);
    let result: Result = { state: state, outcome: "ok" };
    for (let i = 0; i < commands.length; i++) {
        const command = commands[i];
        result = advance(level, state, command);
        state = result.state;
        log("d2 step " + (i + 1) + " " + command + " -> " + result.outcome
            + " body=" + state.body.x + "," + state.body.y + " ticks=" + state.ticks);
    }
    return result;
}

/** T12：录 LL、确认、走 RR，第二个右移应被 A 门挡住并返回原状态对象。 */
function checkT12(): string {
    const level = loadLevel("level2");
    const before = runSeq(level, ["L", "L", "Confirm", "R"]);
    const after = advance(level, before.state, "R");
    const echo = echoAt(level, after.state, after.state.ticks);
    const sameObject = after.state === before.state;
    const ok = after.outcome === "closed_A" && sameObject
        && after.state.body.x === 3 && after.state.body.y === 0
        && echo !== undefined && echo.x === 1 && echo.y === 0
        && after.state.ticks === 1
        && shownGroups(level, after.state) === "A";
    log("d2 T12 outcome=" + after.outcome + " same=" + tostring(sameObject)
        + " body=" + after.state.body.x + "," + after.state.body.y + " ticks=" + after.state.ticks
        + " open=" + shownGroups(level, after.state));
    return (ok ? "ok" : "fail") + "(closed_A,same=" + tostring(sameObject) + ",open=" + shownGroups(level, after.state) + ")";
}

/** T15：录 WLL、确认、走 RRRR，第四拍通关，只有 B 门开启。 */
function checkT15(): string {
    const level = loadLevel("level2");
    const result = runSeq(level, ["W", "L", "L", "Confirm", "R", "R", "R", "R"]);
    const echo = echoAt(level, result.state, result.state.ticks);
    const ok = result.outcome === "won"
        && result.state.body.x === 6 && result.state.body.y === 0
        && echo !== undefined && echo.x === 0 && echo.y === 0
        && result.state.ticks === 4
        && shownGroups(level, result.state) === "B";
    log("d2 T15 outcome=" + result.outcome + " body=" + result.state.body.x + "," + result.state.body.y
        + " ticks=" + result.state.ticks + " open=" + shownGroups(level, result.state));
    return (ok ? "ok" : "fail") + "(won,open=" + shownGroups(level, result.state) + ")";
}

/** 用会话层跑一串命令，返回最后一个结果。 */
function runSession(session: Session, commands: Command[]): Result {
    let result = session.last;
    for (let i = 0; i < commands.length; i++) {
        result = dispatch(session, commands[i]);
        log("d2 session step " + (i + 1) + " " + commands[i] + " -> " + result.outcome
            + " phase=" + session.state.phase + " body=" + session.state.body.x + "," + session.state.body.y
            + " path=" + session.state.path.length + " ticks=" + session.state.ticks);
    }
    return result;
}

/** T04：第一关连续 W×6，第六步应只自动确认一次，落点取路径末项。 */
function checkT04(): string {
    const session = createSession(loadLevel("level1"));
    const result = runSession(session, ["W", "W", "W", "W", "W", "W"]);
    const echo = echoAt(loadLevel("level1"), result.state, 0);
    const ok = result.outcome === "auto_confirmed"
        && result.state.phase === "PLAY"
        && result.state.path.length === 6
        && result.state.ticks === 0
        && result.state.body.x === 1 && result.state.body.y === 0
        && echo !== undefined && echo.x === 1 && echo.y === 0;
    return (ok ? "ok" : "fail") + "(auto_confirmed,path=" + result.state.path.length + ",phase=" + result.state.phase + ")";
}

/** T19 + T20：重走保留路径，第二次四拍通关。 */
function checkT19T20(): string {
    const session = createSession(loadLevel("level2"));
    runSession(session, ["W", "L", "L", "Confirm", "W", "R", "R"]);
    const retried = runSession(session, ["Retry"]);
    const retryOk = retried.outcome === "retried"
        && retried.state.phase === "PLAY"
        && retried.state.path.length === 3
        && retried.state.ticks === 0
        && retried.state.body.x === 2 && retried.state.body.y === 0;
    const won = runSession(session, ["R", "R", "R", "R"]);
    const echo = echoAt(session.level, won.state, won.state.ticks);
    const wonOk = won.outcome === "won"
        && won.state.body.x === 6 && won.state.body.y === 0
        && echo !== undefined && echo.x === 0 && echo.y === 0
        && won.state.ticks === 4
        && shownGroups(session.level, won.state) === "B";
    const ok = retryOk && wonOk;
    return (ok ? "ok" : "fail") + "(retried=" + tostring(retryOk) + ",won=" + tostring(wonOk) + ")";
}

/** T21 + T22：重录清空路径，回起点，之后从 REC 重新记录。 */
function checkT21T22(): string {
    const session = createSession(loadLevel("level2"));
    runSession(session, ["W", "L", "L", "Confirm", "R", "R"]);
    const rerecorded = runSession(session, ["Rerecord"]);
    const reOk = rerecorded.outcome === "rerecorded"
        && rerecorded.state.phase === "REC"
        && rerecorded.state.path.length === 0
        && rerecorded.state.body.x === 2 && rerecorded.state.body.y === 0;
    const after = runSession(session, ["L"]);
    const ok = after.outcome === "ok"
        && after.state.phase === "REC"
        && after.state.path.length === 1
        && after.state.body.x === 1 && after.state.body.y === 0;
    return ((reOk && ok) ? "ok" : "fail") + "(rerecorded=" + tostring(reOk) + ",rel=" + tostring(ok) + ")";
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

        const t12 = checkT12();
        const t15 = checkT15();
        const t04 = checkT04();
        const t19 = checkT19T20();
        const t21 = checkT21T22();

        // 首关初态摘要：D1 交付要求留下「一份首关初态」。
        let level1Text = "";
        try {
            level1Text = describeLevel(parseLevel("level1", "aS.AE"));
        } catch (error) {
            level1Text = "error:" + tostring(error);
        }

        const title = Label(FONT, 44, false);
        if (title !== undefined) {
            title.text = "借我六步 · D2 回合规则";
            title.color = Color(244, 239, 230, 255);
            title.alignment = TextAlign.Center;
            title.anchor = Vec2(0.5, 1);
            root.addChild(title);
        }

        const hint = Label(FONT, 18, false);
        if (hint !== undefined) {
            hint.text = "方向键移动方块 · 每次一格 32px · 随窗口重排";
            hint.color = Color(158, 150, 140, 255);
            hint.alignment = TextAlign.Center;
            hint.anchor = Vec2(0.5, 1);
            root.addChild(hint);
        }

        const levelLine = Label(FONT, 18, false);
        if (levelLine !== undefined) {
            levelLine.text = "首关 aS.AE · " + level1Text;
            levelLine.color = Color(196, 186, 172, 255);
            levelLine.alignment = TextAlign.Center;
            levelLine.anchor = Vec2(0.5, 0);
            root.addChild(levelLine);
        }

        const status = Label(FONT, 18, false);
        if (status !== undefined) {
            status.color = Color(232, 197, 138, 255);
            status.alignment = TextAlign.Center;
            status.anchor = Vec2(0.5, 0);
            root.addChild(status);
        }

        const box = DrawNode();
        root.addChild(box);

        // 布局基准：View.size 会随窗口变化，启动后每帧比对一次，变了就整体重排。
        let vw = w;
        let vh = h;
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
                status.text = "按键 " + count + " 次 · 方块 (" + bx + ", " + by + ") · view " + vw + "x" + vh;
            }
            writeMarker("d1-probe|v3|title=借我六步·D2回合规则|level1=" + r1 + "|level2=" + r2
                + "|bad-width=" + r3 + "|bad-char=" + r4 + "|bad-start=" + r5
                + "|keys=" + count + "|box=" + bx + "," + by
                + "|view=" + vw + "x" + vh + "|level1=" + level1Text
                + "|t12=" + t12 + "|t15=" + t15
                + "|t04=" + t04 + "|t19=" + t19 + "|t21=" + t21);
        };

        // 所有位置都由当前尺寸推导；resize 时整块重排，不保留旧坐标。
        const layout = (nw: number, nh: number) => {
            vw = nw;
            vh = nh;
            root.size = Size(nw, nh);
            root.position = Vec2(-nw / 2, -nh / 2);
            if (title !== undefined) {
                title.position = Vec2(nw / 2, nh - 200);
            }
            if (hint !== undefined) {
                hint.position = Vec2(nw / 2, nh - 260);
            }
            if (levelLine !== undefined) {
                levelLine.position = Vec2(nw / 2, 244);
            }
            if (status !== undefined) {
                status.position = Vec2(nw / 2, 200);
            }
            bx = nw / 2;
            by = nh / 2;
            draw();
            refresh();
        };

        layout(w, h);
        log("boot: probe v3 mounted, view=" + w + "x" + h);
        log("selftest summary level1=" + r1 + " level2=" + r2 + " bad-width=" + r3
            + " bad-char=" + r4 + " bad-start=" + r5 + " t12=" + t12 + " t15=" + t15
            + " t04=" + t04 + " t19=" + t19 + " t21=" + t21);

        root.schedule((dt: number) => {
            const nw = View.size.width;
            const nh = View.size.height;
            if (nw !== vw || nh !== vh) {
                log("resize " + vw + "x" + vh + " -> " + nw + "x" + nh);
                layout(nw, nh);
            }
            return false;
        });

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
