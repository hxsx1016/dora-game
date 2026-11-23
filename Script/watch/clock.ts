/**
 * 固定步长累加器：把每一帧的真实时长切成 1/60 秒的整数倍。
 *
 * 为什么不能一帧一步：D2 的试玩层直接用渲染回调推进一个 STEP，显示器 120 Hz
 * 时游戏跑成两倍速、掉到 30 Hz 时整体变慢。这里把「真实经过的时间」存进累加器，
 * 只有凑够一整步才推进模拟；渲染仍按帧走，每帧最多画一次。
 *
 * 上限 MAX_STEPS 是防死亡螺旋：一次卡顿 0.5 秒不会让下一帧跑 30 步、再卡更久。
 * 超出的时间直接丢弃并计数，比逐帧追赶更稳。
 *
 * 与输入的分工见 input.ts：本文件只决定「这一步该不该跑」，边沿由输入层锁存。
 */

/** 模拟步长（秒）。说明文档里的「拍」等于这个步，60 拍 = 1 秒。 */
export const STEP = 1 / 60;

/** 单帧最多跑的模拟步数。 */
export const MAX_STEPS = 5;

/** 单帧时长上限（秒）。首帧或窗口拖动后可能给出很大的 dt，先截断。 */
const MAX_FRAME_DT = 0.25;

/** 浮点容差：1/120 + 1/120 与 1/60 只差 1e-18，不能让边界卡住。 */
const EPS = 1e-9;

export class StepClock {
    private acc = 0;
    private dropped = 0;

    /**
     * 推进一帧，返回本帧应执行的模拟步数（0 … maxSteps）。
     * 传入的是真实帧时长，不是固定值。
     */
    advance(frameDt: number, maxSteps: number = MAX_STEPS): number {
        if (!(frameDt > 0)) {
            return 0;
        }
        let dt = frameDt;
        if (dt > MAX_FRAME_DT) {
            dt = MAX_FRAME_DT;
        }
        this.acc += dt;
        let steps = 0;
        while (this.acc + EPS >= STEP && steps < maxSteps) {
            this.acc -= STEP;
            steps += 1;
        }
        if (this.acc + EPS >= STEP) {
            // 达到单帧上限：丢掉余量，避免下一帧继续追赶。
            this.acc = 0;
            this.dropped += 1;
        }
        return steps;
    }

    /** 清空累计。重试、切房间、暂停恢复时调用。 */
    reset(): void {
        this.acc = 0;
    }

    /** 还没凑满一步的余量（秒），HUD 与自测用。 */
    get pending(): number {
        return this.acc;
    }

    /** 因为单帧上限被丢弃的次数，自测用。 */
    get dropCount(): number {
        return this.dropped;
    }
}
