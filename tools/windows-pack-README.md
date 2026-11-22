# 守望 · Windows 试玩包（D2）

解压后双击 `Dora.exe` 即开始。首次运行 Windows 可能提示“已保护你的电脑”，
点「更多信息 → 仍要运行」。

## 操作

| 键 | 动作 |
| --- | --- |
| A / D | 左右移动 |
| 鼠标移动 | 准星（周戍瞄准 / 小满投瓶落点） |
| 鼠标左键 | 周戍点射 |
| Shift（按住） | 周戍贴掩体、小满慢走 |
| 空格 | 周戍翻滚 / 小满跳 |
| S 或 Ctrl（按住） | 蹲下（小满钻拱洞要蹲） |
| E | 交互（敲两下、拉车、检查点） |
| G | 切换灰盒查看（D1 的摆放图） |
| 1 / 2 | 检查站 / 城墙外 |
| R | 重来 |

## 这一版能玩什么

D2 的四段：输入、移动与镜头、周戍点射与柜台掩体、小满跳蹲与 E 交互。
拉车、护送、敌人还手还没接，按排期在 D3、D4。

## 已知限制

- 关卡还没有按六区地图加宽，仍是 D1 验收过的 1000 / 600 单位剖面。
- 未操控的一方只落地、不跟随。
- 帧率低于 60 时整体变慢（D3 换固定步累加器）。

## 内容来源

引擎 Dora SSR v1.10.2（Windows x64，D3D12 后端）官方发行包，
只保留运行必需：`Dora.exe`、`dora_godot.dll`、`wa.dll`、`Font/`、`Audio/`、
`Image/`、`Shader/`、`Script/Lib/`；删除了 `Doc/`、`www/`、`dora-wa/`、
`Script/Dev/`、`Script/Tools/`、`Script/Lib/Dora/` 与引擎自带的 `Script/init.yue`。

`Script/init.lua` 是本作的引导（先定资源搜索路径，再加载 `Script/main.lua`），
`Script/main.lua` 与 `Script/watch/*.lua` 由 `init.ts` 与 `Script/watch/*.ts` 编译而来。

引擎许可见 `LICENSES`。
