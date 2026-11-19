// @preview-file on clear
import { App, Color, Director, DrawNode, KeyName, Label, Node, Vec2, View } from 'Dora';

// 月下山谷：纯绘制场景，无需额外图片资源。
const scene = Node();
scene.addTo(Director.entry);
const art = DrawNode();
art.addTo(scene);

const width = View.size.width;
const height = View.size.height;
const halfW = width / 2;
const halfH = height / 2;

// 夜空底色与月光。
art.drawPolygon([Vec2(-halfW, -halfH), Vec2(halfW, -halfH), Vec2(halfW, halfH), Vec2(-halfW, halfH)], Color(9, 15, 39, 255));
art.drawCircle(Vec2(halfW * 0.52, halfH * 0.48), 43, Color(255, 236, 184, 255));
art.drawCircle(Vec2(halfW * 0.52 - 12, halfH * 0.48 + 10), 43, Color(9, 15, 39, 255));

// 远山与近处山脊。
art.drawPolygon([
    Vec2(-halfW, -halfH * 0.12), Vec2(-halfW * 0.72, halfH * 0.30),
    Vec2(-halfW * 0.48, halfH * 0.02), Vec2(-halfW * 0.18, halfH * 0.42),
    Vec2(halfW * 0.08, halfH * 0.04), Vec2(halfW * 0.38, halfH * 0.34),
    Vec2(halfW * 0.68, -halfH * 0.01), Vec2(halfW, halfH * 0.22),
    Vec2(halfW, -halfH), Vec2(-halfW, -halfH),
], Color(28, 43, 76, 255));
art.drawPolygon([
    Vec2(-halfW, -halfH * 0.30), Vec2(-halfW * 0.66, halfH * 0.04),
    Vec2(-halfW * 0.36, -halfH * 0.20), Vec2(-halfW * 0.08, halfH * 0.12),
    Vec2(halfW * 0.20, -halfH * 0.18), Vec2(halfW * 0.55, halfH * 0.08),
    Vec2(halfW, -halfH * 0.24), Vec2(halfW, -halfH), Vec2(-halfW, -halfH),
], Color(17, 31, 59, 255));

// 湖面与月光倒影。
art.drawPolygon([Vec2(-halfW, -halfH), Vec2(halfW, -halfH), Vec2(halfW, -halfH * 0.30), Vec2(-halfW, -halfH * 0.30)], Color(12, 31, 55, 255));
art.drawSegment(Vec2(halfW * 0.30, -halfH * 0.42), Vec2(halfW * 0.76, -halfH * 0.42), 1.5, Color(223, 194, 135, 120));
art.drawSegment(Vec2(halfW * 0.38, -halfH * 0.50), Vec2(halfW * 0.68, -halfH * 0.50), 1, Color(223, 194, 135, 90));
art.drawSegment(Vec2(halfW * 0.25, -halfH * 0.58), Vec2(halfW * 0.79, -halfH * 0.58), 1, Color(223, 194, 135, 65));

const title = Label('sarasa-mono-sc-regular', 26);
if (title) {
    title.text = '月下山谷';
    title.position = Vec2(-halfW + 34, halfH - 48);
    title.anchor = Vec2(0, 0.5);
    title.color = Color(244, 226, 190, 255);
    title.addTo(scene);
}
const caption = Label('sarasa-mono-sc-regular', 14);
if (caption) {
    caption.text = 'MOONLIT VALLEY  ·  静听夜色';
    caption.position = Vec2(-halfW + 36, halfH - 73);
    caption.anchor = Vec2(0, 0.5);
    caption.color = Color(160, 180, 204, 255);
    caption.addTo(scene);
}

// 萤火沿各自轨迹轻轻漂动。
const fireflies = [
    { x: -0.72, y: -0.16, phase: 0.2 },
    { x: -0.30, y: -0.35, phase: 1.7 },
    { x: 0.04, y: -0.22, phase: 3.1 },
    { x: 0.70, y: -0.34, phase: 4.4 },
    { x: -0.84, y: 0.02, phase: 5.2 },
];
const lights = DrawNode();
lights.addTo(scene);
let elapsed = 0;
let dialog: Node.Type | undefined;

const hint = Label('sarasa-mono-sc-regular', 14);
if (hint) {
    hint.text = 'Esc · 退出菜单';
    hint.position = Vec2(halfW - 28, -halfH + 28);
    hint.anchor = Vec2(1, 0.5);
    hint.color = Color(190, 204, 220, 255);
    hint.addTo(scene);
}

function closeDialog(): void {
    if (dialog) {
        dialog.removeFromParent();
        dialog = undefined;
    }
}

function openDialog(): void {
    if (dialog) return;
    const overlay = Node();
    overlay.addTo(Director.ui);
    dialog = overlay;
    const w = View.size.width;
    const h = View.size.height;
    // 整个弹窗按窗口大小缩放，保持文字和按钮的相对布局。
    const scale = Math.min(1, w / 480, h / 320);
    const shade = DrawNode();
    shade.drawPolygon([
        Vec2(-w / 2, -h / 2), Vec2(w / 2, -h / 2),
        Vec2(w / 2, h / 2), Vec2(-w / 2, h / 2),
    ], Color(3, 8, 20, 200));
    shade.addTo(overlay);
    const panel = Node();
    panel.scaleX = scale;
    panel.scaleY = scale;
    panel.addTo(overlay);
    const frame = DrawNode();
    frame.drawPolygon([
        Vec2(-216, -116), Vec2(216, -116), Vec2(216, 116), Vec2(-216, 116),
    ], Color(22, 36, 62, 255), 1, Color(113, 132, 160, 255));
    frame.drawSegment(Vec2(-184, 82), Vec2(-148, 82), 2, Color(244, 218, 161, 255));
    frame.addTo(panel);
    function text(value: string, size: number, y: number, color: Color.Type): void {
        const label = Label('sarasa-mono-sc-regular', size);
        if (!label) return;
        label.text = value;
        label.y = y;
        label.color = color;
        label.addTo(panel);
    }
    text('要离开月下山谷吗？', 24, 44, Color(248, 233, 204, 255));
    text('选择退出将结束当前游戏。', 16, 8, Color(179, 196, 216, 255));
    function button(value: string, x: number, primary: boolean, action: () => void): void {
        const hit = Node();
        hit.width = 168;
        hit.height = 44;
        hit.position = Vec2(x, -60);
        hit.swallowTouches = true;
        hit.addTo(panel);
        const face = DrawNode();
        face.addTo(hit);
        function paint(pressed: boolean): void {
            face.clear();
            const fill = primary
                ? (pressed ? Color(203, 177, 121, 255) : Color(244, 218, 161, 255))
                : (pressed ? Color(54, 75, 104, 255) : Color(35, 52, 79, 255));
            face.drawPolygon([Vec2(0, 0), Vec2(168, 0), Vec2(168, 44), Vec2(0, 44)], fill);
        }
        paint(false);
        const label = Label('sarasa-mono-sc-regular', 17);
        if (label) {
            label.text = value;
            label.position = Vec2(84, 22);
            label.color = primary ? Color(22, 36, 62, 255) : Color(227, 235, 246, 255);
            label.addTo(hit);
        }
        hit.onTapBegan(() => paint(true));
        hit.onTapEnded(() => paint(false));
        hit.onTapped(() => action());
    }
    button('继续游戏', -92, false, closeDialog);
    button('退出游戏', 92, true, () => App.shutdown());
}

scene.onKeyDown((key) => {
    if (key === KeyName.Escape) {
        if (dialog) closeDialog();
        else openDialog();
    }
});
scene.onCleanup(closeDialog);

scene.schedule((dt) => {
    if (dialog) return false;
    elapsed += dt;
    lights.clear();
    for (const fly of fireflies) {
        const x = fly.x * halfW + Math.sin(elapsed * 0.7 + fly.phase) * 12;
        const y = fly.y * halfH + Math.sin(elapsed * 1.1 + fly.phase) * 8;
        const pulse = 0.55 + 0.45 * Math.sin(elapsed * 2 + fly.phase);
        lights.drawCircle(Vec2(x, y), 3 + pulse * 2, Color(255, 218, 112, Math.floor(100 + pulse * 130)));
        lights.drawCircle(Vec2(x, y), 1.5, Color(255, 244, 180, 255));
    }
    return false;
});
