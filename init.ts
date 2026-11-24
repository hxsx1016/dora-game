/**
 * 守望 — 入口装配。
 *
 * 只做三件事：补资源搜索路径、建根节点、把原点对齐到屏幕左下角。
 * 补路径是为了发行版：Web IDE 会自动带上项目目录，独立 exe 不会，
 * 少了这两条 require("Script.watch.*") 就找不到文件。
 */
import { Content, Director, Node, Size, Vec2, View } from "Dora";
import { start } from "Script/watch/app";

function ensureSearchPath(path: string): void {
    let i = 0;
    for (i = 0; i < Content.searchPaths.length; i++) {
        if (Content.searchPaths[i] === path) {
            return;
        }
    }
    Content.addSearchPath(path);
}

ensureSearchPath(Content.assetPath + "/Script");
ensureSearchPath(Content.assetPath + "/Script/Lib");
ensureSearchPath(Content.assetPath);

const W = View.size.width;
const H = View.size.height;

const root = Node();
root.size = Size(W, H);
root.anchor = Vec2(0, 0);
root.position = Vec2(-W / 2, -H / 2);
Director.ui.addChild(root);

start(root, 2);
