/**
 * 零抖动宋明风雅双字体 Label 对象池：
 * - 正文/界面桶（xs/sm/md/lg/xl）：霞鹜新致宋（LXGW Neo ZhiSong，SIL OFL 1.1），横细竖挺、清秀雕版明体；
 * - 标题/章名/孤印/数数大字桶（seal/sealLg/banner/title）：龙藏体（Long Cang，SIL OFL 1.1），瘦劲婉转行书；
 * - 外部字体缺失时自动回退至引擎内置 sarasa-mono-sc-regular，保证零崩溃。
 */

import { Color, Content, Label, Node, TextAlign, Vec2 } from "Dora";

const FONT_FALLBACK = "sarasa-mono-sc-regular";
const FONT_BODY_PATH = "assets/font/lxgw-neo-zhisong.ttf";
const FONT_CALLI_PATH = "assets/font/longcang-brush.ttf";

const DEFAULT_OUTLINE = Color(8, 10, 15, 200);

export type FontBucket = "xs" | "sm" | "md" | "lg" | "xl" | "seal" | "sealLg" | "banner" | "title";

const BUCKET_SIZES: Record<FontBucket, number> = {
    xs: 15,
    sm: 18,
    md: 21,
    lg: 28,
    xl: 44,
    seal: 15,
    sealLg: 19,
    banner: 42,
    title: 68,
};

const BUCKET_CAPS: Record<FontBucket, number> = {
    xs: 44,
    sm: 44,
    md: 28,
    lg: 14,
    xl: 6,
    seal: 16,
    sealLg: 8,
    banner: 8,
    title: 10,
};

const CALLI_BUCKETS: Record<FontBucket, boolean> = {
    xs: false,
    sm: false,
    md: false,
    lg: false,
    xl: false,
    seal: true,
    sealLg: true,
    banner: true,
    title: true,
};

function resolveFont(useCalli: boolean): string {
    if (useCalli && Content.exist(FONT_CALLI_PATH)) {
        return FONT_CALLI_PATH;
    }
    if (Content.exist(FONT_BODY_PATH)) {
        return FONT_BODY_PATH;
    }
    return FONT_FALLBACK;
}

export class TextPool {
    private pools: Record<FontBucket, Label.Type[]>;
    private used: Record<FontBucket, number>;
    private container: Node.Type;

    constructor(parent: Node.Type, order: number) {
        this.container = Node();
        this.container.order = order;
        this.container.addTo(parent);
        this.pools = {
            xs: [], sm: [], md: [], lg: [], xl: [],
            seal: [], sealLg: [], banner: [], title: [],
        };
        this.used = {
            xs: 0, sm: 0, md: 0, lg: 0, xl: 0,
            seal: 0, sealLg: 0, banner: 0, title: 0,
        };

        this.allocBucket("xs");
        this.allocBucket("sm");
        this.allocBucket("md");
        this.allocBucket("lg");
        this.allocBucket("xl");
        this.allocBucket("seal");
        this.allocBucket("sealLg");
        this.allocBucket("banner");
        this.allocBucket("title");
    }

    private allocBucket(bucket: FontBucket): void {
        const size = BUCKET_SIZES[bucket];
        const cap = BUCKET_CAPS[bucket];
        const font = resolveFont(CALLI_BUCKETS[bucket]);
        const list = this.pools[bucket];
        let i = 0;
        for (i = 0; i < cap; i++) {
            let lb = Label(font, size, true);
            if (lb === undefined && font !== FONT_FALLBACK) {
                lb = Label(FONT_FALLBACK, size, true);
            }
            if (lb !== undefined) {
                lb.outlineColor = DEFAULT_OUTLINE;
                lb.outlineWidth = 0.13;
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
        this.used.seal = 0;
        this.used.sealLg = 0;
        this.used.banner = 0;
        this.used.title = 0;
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
        outlineWidth: number = 0.13,
        outlineColor?: Color.Type,
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
        lb.outlineWidth = outlineWidth;
        if (outlineColor !== undefined) {
            lb.outlineColor = outlineColor;
        } else if (outlineWidth <= 0) {
            lb.outlineColor = Color(0, 0, 0, 0);
        } else {
            lb.outlineColor = DEFAULT_OUTLINE;
        }
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
        this.hideRest("seal");
        this.hideRest("sealLg");
        this.hideRest("banner");
        this.hideRest("title");
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
