/**
 * 会话层：一个命令 → 一次 advance → 一次状态提交。
 *
 * 这一层只做三件事：
 * 1. 持有当前关卡与当前局面，保证「一个命令只推进一拍」；
 * 2. 把重走（Retry）与重录（Rerecord）的语义交给 turn.ts，不自己复制规则；
 * 3. 记录命令序号，输入层或动画层重复派发时用 seq 去重（第六步自动确认只触发一次）。
 */
import { Level } from "Script/game/levels";
import { Command, Result, State, advance, start } from "Script/game/turn";

export interface Session {
    level: Level;
    state: State;
    /** 已成功分发过的命令数（含被拒绝的命令）。 */
    seq: number;
    /** 最近一次结果，UI 用来决定提示与动画。 */
    last: Result;
}

export function createSession(level: Level): Session {
    const state = start(level);
    return { level: level, state: state, seq: 0, last: { state: state, outcome: "ok" } };
}

/**
 * 派发一个命令。若 expectedSeq 与当前 seq 不一致，说明是重复/过期的输入，
 * 直接返回上一次结果，不再推进局面（防止长按把第六步确认触发两次）。
 */
export function dispatch(session: Session, command: Command, expectedSeq?: number): Result {
    if (expectedSeq !== undefined && expectedSeq !== session.seq) {
        return session.last;
    }
    const result = advance(session.level, session.state, command);
    session.state = result.state;
    session.seq = session.seq + 1;
    session.last = result;
    return result;
}

/** 重新载入当前关卡（换关或整局重开）。 */
export function resetSession(session: Session): Session {
    return createSession(session.level);
}
