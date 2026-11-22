/**
 * 守望 — 入口装配。
 *
 * 只做三件事：建根节点、把原点对齐到屏幕左下角、交给灰盒查看器。
 * D1 挂的是 Script/watch/app.ts 的两张灰盒；D2 起换成正式的房间控制器。
 */
import { Director, Node, Size, Vec2, View } from "Dora";
import { start } from "Script/watch/app";

const W = View.size.width;
const H = View.size.height;

const root = Node();
root.size = Size(W, H);
root.anchor = Vec2(0, 0);
root.position = Vec2(-W / 2, -H / 2);
Director.ui.addChild(root);

start(root);
