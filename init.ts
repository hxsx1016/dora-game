/**
 * 借我六步 — 入口装配。
 *
 * 只做三件事：建根节点、把原点对齐到屏幕左下角、交给 Probe 挂载。
 * 游戏逻辑与视图都不写在这里。
 */
import { Director, Node, Size, Vec2, View } from "Dora";
import { Probe } from "Script/core/Probe";

const W = View.size.width;
const H = View.size.height;

const root = Node();
root.size = Size(W, H);
root.anchor = Vec2(0, 0);
root.position = Vec2(-W / 2, -H / 2);
Director.ui.addChild(root);

Probe.mount(root);
