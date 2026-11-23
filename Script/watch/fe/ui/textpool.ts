/**
 * 零抖动 Label 对象池（按字号分桶，默认开启 SDF + 微弱暗描边，保证高对比度可读性）。
 *
 * 每帧开始调用 beginFrame()，渲染期间调用 put(...)，帧末调用 endFrame() 自动隐藏未复用标签，
 * 避免每帧新建/销毁节点造成的内存抖动与界面残影。
 */

import { Color, Label, Node, TextAlign, Vec2 } from "Dora";

const FONT = "sarasa-mono-sc-regular";

export type FontBucket = "xs" | "sm" | "md" | "lg" | "xl";

const BUCKET_SIZES: Record<FontBucket, number> = {
    xs: 14,
    sm: 17,
    md: 21,
    lg: 30,
    xl: 48,
};

const BUCKET_CAPS: Record<FontBucket, number> = {
    xs: 28,
    sm: 36,
    md: 24,
    lg: 12,
    xl: 4,
};

export class TextPool {
    private pools: Record<FontBucket, Label.Type[]>;
    private used: Record<FontBucket, number>;
    private container: Node.Type;

    constructor(parent: Node.Type, order: number) {
        this.container = Node();
        this.container.order = order;
        this.container.addTo(parent);
        this.pools = { xs: [], sm: [], md: [], lg: [], xl: [] };
        this.used = { xs: 0, sm: 0, md: 0, lg: 0, xl: 0 };

        this.allocBucket("xs");
        this.allocBucket("sm");
        this.allocBucket("md");
        this.allocBucket("lg");
        this.allocBucket("xl");
    }

    private allocBucket(bucket: FontBucket): void {
        const size = BUCKET_SIZES[bucket];
        const cap = BUCKET_CAPS[bucket];
        const list = this.pools[bucket];
        let i = 0;
        for (i = 0; i < cap; i++) {
            const lb = Label(FONT, size, true);
            if (lb !== undefined) {
                lb.outlineColor = Color(4, 7, 14, 210);
                lb.outlineWidth = 0.14;
                lb.visible = false;
                lb.addTo(this.container);
                list.push(lb);
            }
        }
    }

    beginFrame(): void {
        this.used.xs = 0;
        this.used.sm = 0;
        this.used.md = 0;
        this.used.lg = 0;
        this.used.xl = 0;
    }

    put(
        bucket: FontBucket,
        text: string,
        x: number,
        y: number,
        color: Color.Type,
        ax: number = 0,
        ay: number = 0.5,
        align: TextAlign = TextAlign.Left,
        spacing: number = 0,
        opacity: number = 1,
    ): void {
        if (text === "") {
            return;
        }
        const list = this.pools[bucket];
        const idx = this.used[bucket];
        if (idx >= list.length) {
            return;
        }
        this.used[bucket] = idx + 1;
        const lb = list[idx];
        lb.text = text;
        lb.color = color;
        lb.position = Vec2(Math.round(x), Math.round(y));
        lb.anchor = Vec2(ax, ay);
        lb.alignment = align;
        lb.spacing = spacing;
        lb.opacity = Math.max(0, Math.min(1, opacity));
        lb.visible = true;
    }

    endFrame(): void {
        this.hideRest("xs");
        this.hideRest("sm");
        this.hideRest("md");
        this.hideRest("lg");
        this.hideRest("xl");
    }

    hideAll(): void {
        this.beginFrame();
        this.endFrame();
    }

    private hideRest(bucket: FontBucket): void {
        const list = this.pools[bucket];
        let i = this.used[bucket];
        for (; i < list.length; i++) {
            list[i].visible = false;
        }
    }
}
