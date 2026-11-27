# -*- coding: utf-8 -*-
"""小满线 3D 地图：从 LN2 逆向包的地图 JSON 生成结构网格（布局 + 材质槽，不含贴图）。

流程：
1. 读取 .cache/ln2/data/maps/<LEVEL>.json 的 actors；
2. 按每房选段窗口（走廊长轴 t、横轴 s、高度 h）筛出结构构件；
3. 过滤现代设备/杂物/敌人/AI/CLO 与地编资源；
4. 按类别映射成结构体块（墙/地面/台阶/门/窗/梁/桌/树/石/栏杆），
   执行分段（非均匀）坐标变换：长轴 t → 游戏 x、横轴 s → 游戏 depth（压缩）、源 Z → 游戏 height；
5. 叠加 rooms.ts 的玩法锚点（拱净高、桌下净空、塔门/桌位等），锚点物件单独标注；
6. 导出 4 个 GLB（Y-up，1 m = 1 glTF 单位 = 100 游戏单位）+ manifest.json（含每个目标物件的源 Actor 映射）。

贴图由前端接入：本脚本只输出 8 个中性色材质槽与稳定物件命名。

用法：
    /Applications/Blender.app/Contents/MacOS/Blender -b --python tools/build-xiaoman-map.py
"""

import json
import math
import os
import re

import bpy
import bmesh

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_DIR = os.path.join(ROOT, ".cache", "ln2", "data", "maps")
OUT_DIR = os.path.join(ROOT, "assets", "xiaoman3d")

# ---------------------------------------------------------------- 材质槽
MATERIALS = {
    "M_xm3d_stone":      ((0.56, 0.55, 0.52, 1.0), 0.82, 0.0),   # 灰砖 / 石阶 / 台面
    "M_xm3d_stone_dark": ((0.34, 0.34, 0.33, 1.0), 0.85, 0.0),   # 暗砖 / 墙根 / 阴影
    "M_xm3d_wood":       ((0.47, 0.38, 0.28, 1.0), 0.80, 0.0),   # 木梁 / 桌 / 门框
    "M_xm3d_wood_dark":  ((0.29, 0.24, 0.18, 1.0), 0.85, 0.0),   # 旧木 / 树皮 / 井沿
    "M_xm3d_plaster":    ((0.62, 0.60, 0.55, 1.0), 0.88, 0.0),   # 灰泥 / 院墙抹面
    "M_xm3d_earth":      ((0.40, 0.36, 0.30, 1.0), 0.90, 0.0),   # 土 / 软土 / 林地
    "M_xm3d_metal":      ((0.30, 0.31, 0.33, 1.0), 0.55, 0.35),  # 铁盆 / 门环 / 窗棂
    "M_xm3d_void":       ((0.13, 0.13, 0.14, 1.0), 0.95, 0.0),   # 后景 / 洞口内
}

# ---------------------------------------------------------------- 每房源段与映射
# axis: 走廊长轴（UE 平面轴）；t0/t1: 选段窗口（米）；s_ref: 横轴零点；k: 横轴→depth 压缩比
# game_w: 目标房宽（游戏单位）；h_ref: 地面参考高度（米）；max_items: 安全上限
ROOM_CFG = {
    "outside": dict(
        level="LVL_1_080_Facade", axis="Y", t0=76.0, t1=88.0,
        s_ref=-3.0, k=14.6, game_w=12.4, h_ref=-1.0, max_items=70,
        note="城外灰砖墙外面；窗距约 2.7 m、门洞约 1.0 m",
    ),
    "village": dict(
        level="LVL_2_010_SchoolCityAlley", axis="Y", t0=-249.0, t1=-243.0,
        s_ref=7.65, k=10.0, game_w=7.2, h_ref=0.0, max_items=60,
        note="村口院落；院墙 X≈7.65、店面门洞间距约 5.5 m",
    ),
    "forest": dict(
        level="LVL_1_090_ThrowTutorial", axis="Y", t0=-175.0, t1=-163.0,
        s_ref=0.0, k=7.3, game_w=16.0, h_ref=0.0, max_items=80,
        note="林地狭道；树 33、石 7+6+4、落叶 15+11",
    ),
    "tower": dict(
        level="LVL_2_040_AbandonedStairwell", axis="Y", t0=-300.0, t1=-288.0,
        s_ref=-24.0, k=7.3, game_w=7.2, h_ref=0.0, max_items=70,
        note="北塔内外；楼梯 59、踏步 16、墙 82、梁 81",
    ),
}

# ---------------------------------------------------------------- 类别规则
# 顺序敏感：先门/窗，再墙/地面/台阶/梁，再树/石/桌，最后通用。
KIND_RULES = [
    ("window", r"(Window|Balcony_Roof|Balcony|WindowFrame|FacadeWindow)"),
    ("door",   r"(Door|DoorFrame|Doorway|Storefront|Gate)"),
    ("stair",  r"(Stair|Step|StairCase|FacadeStairs|Stairwell)"),
    ("floor",  r"(Floor|Ground|ConcreteFloor|PlankFloor|GroundPlatform|Slab|Platform)"),
    ("wall",   r"(Wall|Facade|ThinBlock|CrackedBlock|Brick|Plaster|Partition|Panel)"),
    ("beam",   r"(Beam|BentBeam|Column|Post|Rail|Railing|Roof|CeilingFrame)"),
    ("table",  r"(Table|Bench|Desk|Shelf|Cabinet|Counter)"),
    ("litter", r"(Leaves|Leaf|Grass|Moss|Litter|Twig)"),
    ("tree",   r"(Tree|BeechTree|TreeBranch|Bush|Hedge|Stump)"),
    ("rock",   r"(Boulder|Rock|Rubble|Debris|Stone)"),
    ("metal",  r"(TinCan|MetalLamp|Bucket|Pot|Basin)"),
]
# 现代设备 / 杂物 / 敌人 / AI / 地编资源：删
DROP_RE = re.compile(
    r"(AirConditioner|PipeKit|Downpipe|CablePole|TVPerson|Monitor|Bathtub|BathTub|Toilet|"
    r"Greeble|WallSwitch|Socket|SignPost|Decal|SpotLight|Emitter|CLO_|DollhouseCamera|"
    r"PlayerProxy|EnemyProxy|Bully|Monster|Clothes|Laundry|Poster|Graffiti|Trash|Cigarette|"
    r"BloodSplat|StreamingVolume|TriggerBox|Nav_|Spline|Widget|HangingRag|Curtain|Rug|"
    r"Bed|Sofa|Chair|Fridge|Stove|Sink|Mirror|Clock|Carpet|Blanket|Pillow|Bottle|Shoe|Toy)", re.I)
DIM_RE = re.compile(r"(\d+)\s*[xX×]\s*(\d+)(?:\s*[xX×]\s*(\d+))?\s*(?:cm|CM)", re.I)

# ---------------------------------------------------------------- 几何批次
class RoomBatch:
    def __init__(self, room):
        self.room = room
        self.by_mat = {m: {"verts": [], "faces": []} for m in MATERIALS}
        self.items = []   # manifest（逻辑条目，GLB 实际按材质合并）
        self.boxes = 0
        self.anchor_seq = 0

    def _anchor_meta(self, kind, center, bounds):
        """锚点盒/圆柱没有源 Actor，也记一条逻辑条目；export_room 再标 anchor 与 rooms.ts 来源。"""
        self.anchor_seq += 1
        return {
            "room": self.room,
            "target": "%s_anchor_%03d" % (self.room, self.anchor_seq),
            "kind": "anchor",
            "anchor": False,
            "source": {"level": "rooms.ts", "name": "anchor"},
            "game": [round(center[0] * 100.0, 1), round(center[2] * 100.0, 1), round(center[1] * 100.0, 1)],
            "bounds": [[round(bounds[0][0], 3), round(bounds[0][2], 3), round(-bounds[1][1], 3)],
                       [round(bounds[1][0], 3), round(bounds[1][2], 3), round(-bounds[0][1], 3)]],
            "anchorTag": kind,
        }

    def _quad(self, mat, verts8, quads):
        b = self.by_mat[mat]
        base = len(b["verts"])
        b["verts"].extend(verts8)
        for q in quads:
            b["faces"].append(tuple(base + i for i in q))
        self.boxes += 1

    def box(self, mat, x0, x1, d0, d1, y0, y1, meta=None):
        """轴对齐实体盒；Blender X=游戏x/100、Y=depth/100、Z=height/100。

        顶点编号 bit0=x、bit1=depth、bit2=height；六个面全部朝外（外法线由 bmesh 复核）。
        """
        xs = (x0, x1); ds = (d0, d1); ys = (y0, y1)
        v = []
        for z in ys:
            for y in ds:
                for x in xs:
                    v.append((x, y, z))
        q = [
            (0, 2, 3, 1),  # -Z 底面
            (4, 5, 7, 6),  # +Z 顶面
            (0, 4, 6, 2),  # -X
            (1, 3, 7, 5),  # +X
            (0, 1, 5, 4),  # -Y
            (2, 6, 7, 3),  # +Y
        ]
        self._quad(mat, v, q)
        if meta is None:
            meta = self._anchor_meta("box", ((x0 + x1) / 2, (d0 + d1) / 2, (y0 + y1) / 2),
                                     ((x0, d0, y0), (x1, d1, y1)))
        meta["bounds"] = [[round(x0, 3), round(y0, 3), round(-d1, 3)],
                          [round(x1, 3), round(y1, 3), round(-d0, 3)]]
        self.items.append(meta)
        return meta

    def cyl(self, mat, cx, cd, r, y0, y1, seg=8, meta=None):
        """轴向圆柱：侧面四边 + 顶底三角扇封盖（中心点参与，非退化面）。"""
        b = self.by_mat[mat]
        base = len(b["verts"])
        for z in (y0, y1):
            for i in range(seg):
                a = 2 * math.pi * i / seg
                b["verts"].append((cx + r * math.cos(a), cd + r * math.sin(a), z))
        c_bot = len(b["verts"])
        b["verts"].append((cx, cd, y0))
        c_top = len(b["verts"])
        b["verts"].append((cx, cd, y1))
        for i in range(seg):
            j = (i + 1) % seg
            b["faces"].append((base + i, base + j, base + seg + j, base + seg + i))  # 侧面（外法线）
            b["faces"].append((c_top, base + seg + i, base + seg + j))                # 顶面 +Z
            b["faces"].append((c_bot, base + j, base + i))                            # 底面 -Z
        self.boxes += 1
        if meta is None:
            meta = self._anchor_meta("cyl", (cx, cd, (y0 + y1) / 2),
                                     ((cx - r, cd - r, y0), (cx + r, cd + r, y1)))
        meta["bounds"] = [[round(cx - r, 3), round(y0, 3), round(-(cd + r), 3)],
                          [round(cx + r, 3), round(y1, 3), round(-(cd - r), 3)]]
        self.items.append(meta)
        return meta


class AnchorBatch:
    """锚点按游戏语义写 depth（前负后正），导出时镜像到 GLB（z=-depth/100）；
    相机在 +Z 侧，所以正值 depth 落在远离相机的一侧。"""

    def __init__(self, inner):
        self.inner = inner

    def box(self, mat, x0, x1, d0, d1, y0, y1, meta=None):
        return self.inner.box(mat, x0, x1, -d1, -d0, y0, y1, meta)

    def cyl(self, mat, cx, cd, r, y0, y1, seg=8, meta=None):
        return self.inner.cyl(mat, cx, -cd, r, y0, y1, seg, meta)


def parse_size(mesh_path, scale):
    """从网格路径解析 cm 尺寸；无尺寸时按 scale 与类别默认。"""
    m = DIM_RE.search(mesh_path or "")
    if m:
        vals = [int(g) / 100.0 for g in m.groups() if g is not None]
        while len(vals) < 3:
            vals.append(min(vals) if vals else 1.0)
        return vals
    sc = scale or [1.0, 1.0, 1.0]
    return [abs(sc[0]) * 1.0, abs(sc[1]) * 1.0, abs(sc[2]) * 1.0]


def to_game(cfg, loc):
    """源 UE 米 → 游戏单位：长轴 t→x，横轴 s→depth（压缩），Z→height。"""
    x, y, z = loc
    t, s = (y, x) if cfg["axis"] == "Y" else (x, y)
    gx = (t - cfg["t0"]) / (cfg["t1"] - cfg["t0"]) * cfg["game_w"] * 100.0
    dep = (s - cfg["s_ref"]) * cfg["k"]
    hgt = (z - cfg["h_ref"]) * 100.0
    return gx, dep, hgt


def kind_of(name, mesh_path):
    text = (name or "") + " " + (mesh_path or "")
    for kind, pat in KIND_RULES:
        if re.search(pat, text, re.I):
            return kind
    return "other"


def gen_item(batch, kind, gx, dep, hgt, size, meta, cfg):
    """源 Actor → 结构盒。gx/dep/hgt 为游戏单位，先转米再与米制尺寸相加。"""
    name = meta["target"]
    gx_m, d_m, h_m = gx / 100.0, dep / 100.0, hgt / 100.0
    L, W, H = size  # 米
    long = max(L, W, 0.40)
    thick = max(0.10, min(L, W) * 0.5) if min(L, W) > 0.05 else 0.16
    if kind == "blocking":
        top = min(2.4, max(0.20, H)) + h_m
        batch.box("M_xm3d_stone_dark",
                  gx_m - long / 2, gx_m + long / 2,
                  d_m - max(0.04, W / 2), d_m + max(0.04, W / 2),
                  max(0.0, h_m), max(0.02, top), meta)
    elif kind == "wall":
        h = max(1.60, min(2.80, H if H > 0.6 else 2.40))
        batch.box("M_xm3d_stone_dark",
                  gx_m - long / 2, gx_m + long / 2,
                  d_m - 0.18, d_m + 0.18,
                  max(0.0, h_m), max(0.0, h_m + h), meta)
    elif kind == "floor":
        batch.box("M_xm3d_earth",
                  gx_m - long / 2, gx_m + long / 2,
                  d_m - 0.70, d_m + 0.70,
                  max(0.0, h_m - 0.12), max(0.0, h_m), meta)
    elif kind == "stair":
        n = 3
        for i in range(n):
            x0 = gx_m - long / 2 + long * i / n
            x1 = gx_m - long / 2 + long * (i + 1) / n
            h1 = h_m + 0.192 * (i + 1)
            batch.box("M_xm3d_stone", x0, x1, d_m - 0.75, d_m + 0.75,
                      0.0, max(0.06, h1), dict(meta, part="step%d" % (i + 1)))
    elif kind == "door":
        batch.box("M_xm3d_wood_dark",
                  gx_m - 0.06, gx_m + 0.06, d_m - 0.55, d_m + 0.55,
                  max(0.0, h_m), max(0.02, h_m + 1.20), meta)
        batch.box("M_xm3d_void",
                  gx_m + 0.06, gx_m + 0.56, d_m - 0.50, d_m + 0.50,
                  max(0.0, h_m), max(0.02, h_m + 1.14), dict(meta, part="void"))
    elif kind == "window":
        batch.box("M_xm3d_void",
                  gx_m - long / 2, gx_m + long / 2, d_m - 0.10, d_m + 0.10,
                  max(0.0, h_m + 1.10), max(0.02, h_m + 1.90), meta)
        batch.box("M_xm3d_wood_dark",
                  gx_m - long / 2 - 0.04, gx_m + long / 2 + 0.04, d_m - 0.16, d_m + 0.16,
                  max(0.0, h_m + 1.90), max(0.02, h_m + 2.00), dict(meta, part="lintel"))
    elif kind == "beam":
        batch.box("M_xm3d_wood",
                  gx_m - long / 2, gx_m + long / 2, d_m - 0.14, d_m + 0.14,
                  max(0.0, h_m + 2.10), max(0.02, h_m + 2.40), meta)
    elif kind == "table":
        tw = min(1.12, max(0.60, long))
        batch.box("M_xm3d_wood",
                  gx_m - tw / 2, gx_m + tw / 2, d_m - 0.42, d_m + 0.42,
                  max(0.0, h_m + 0.44), max(0.02, h_m + 0.50), meta)
        for lx in (-0.5, 0.44):
            for ld in (-0.34, 0.26):
                batch.box("M_xm3d_wood_dark",
                          gx_m + lx - 0.04, gx_m + lx + 0.04,
                          d_m + ld - 0.04, d_m + ld + 0.04,
                          max(0.0, h_m), max(0.02, h_m + 0.44), dict(meta, part="leg"))
    elif kind == "litter":
        batch.box("M_xm3d_wood_dark",
                  gx_m - max(0.25, long / 3), gx_m + max(0.25, long / 3),
                  d_m - 0.22, d_m + 0.22, 0.0, 0.05, meta)
    elif kind == "tree":
        r = min(0.26, max(0.10, thick / 2))
        batch.cyl("M_xm3d_wood_dark", gx_m, d_m, r,
                  0.0, max(0.8, min(2.6, max(1.8, H))), 8, meta)
        batch.box("M_xm3d_wood_dark",
                  gx_m - 0.26, gx_m + 0.26, d_m - 0.26, d_m + 0.26,
                  max(0.0, h_m + 1.70), max(0.02, h_m + 2.50), dict(meta, part="crown"))
    elif kind == "rock":
        r = min(0.42, max(0.16, long / 4))
        batch.cyl("M_xm3d_stone", gx_m, d_m, r,
                  max(0.0, h_m), max(0.0, h_m + r * 0.9), 8, meta)
    elif kind == "metal":
        batch.cyl("M_xm3d_metal", gx_m, d_m, 0.18,
                  max(0.0, h_m), max(0.0, h_m + 0.12), 10, meta)
    else:
        batch.box("M_xm3d_stone",
                  gx_m - long / 2, gx_m + long / 2, d_m - thick / 2, d_m + thick / 2,
                  max(0.0, h_m), max(0.02, h_m + max(0.40, H)), meta)
    return name


KIND_PRIORITY = {"blocking": 0, "door": 1, "window": 2, "table": 3, "tree": 4,
                 "rock": 5, "metal": 6, "wall": 7, "beam": 8, "stair": 9, "floor": 10, "other": 11}


def derive_refs(cfg, actors):
    """用窗口内地面/楼梯高度与横向中位数自适应 s_ref / h_ref。"""
    win = []
    for a in actors:
        if (a.get("cls") or "") not in ("StaticMeshActor", "GrabbableLedgeActor", "BP_BlockingPlane_C"):
            continue
        loc = a.get("loc") or [0, 0, 0]
        x, y, z = loc[0] / 100.0, loc[1] / 100.0, loc[2] / 100.0
        t, s = (y, x) if cfg["axis"] == "Y" else (x, y)
        if not (cfg["t0"] <= t <= cfg["t1"]):
            continue
        kind = kind_of(a.get("name") or "", (a.get("meshes") or [""])[0])
        win.append((s, z, kind))
    if not win:
        return
    zs = sorted(z for _, z, _ in win)
    base = zs[max(0, int(len(zs) * 0.10))]
    ss = sorted(s for s, _, _ in win)
    cfg["h_ref"] = round(base, 2)
    cfg["h_top"] = round(base + 3.2, 2)      # 只取近地一层（房高 2.2–2.4 m）
    cfg["s_ref"] = round(ss[len(ss) // 2], 2)
    cfg["_win"] = len(win)


def load_level(cfg):
    path = os.path.join(SRC_DIR, cfg["level"] + ".json")
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)["actors"]


def filter_actors(cfg, actors):
    """按窗口与类别筛选源 Actor，返回 [(actor, kind, gx, dep, hgt, size)]。

    - BP_BlockingPlane_C：用 FarCornerWidget 生成真实阻挡线（窗口按范围相交判定）；
    - StaticMeshActor/GrabbableLedgeActor：按名称/网格叶名映射结构构件。
    """
    out = []
    for a in actors:
        cls = a.get("cls") or ""
        name = a.get("name") or ""
        meshes = a.get("meshes") or []
        mesh = meshes[0] if meshes else ""
        if cls not in ("StaticMeshActor", "GrabbableLedgeActor", "BP_BlockingPlane_C"):
            continue
        if cls != "BP_BlockingPlane_C" and (DROP_RE.search(name) or DROP_RE.search(mesh)):
            continue
        loc = a.get("loc") or [0, 0, 0]
        x, y, z = loc[0] / 100.0, loc[1] / 100.0, loc[2] / 100.0

        if cls == "BP_BlockingPlane_C":
            far = a.get("FarCornerWidget") or [0, 0, 0]
            fx, fy, fz = far[0] / 100.0, far[1] / 100.0, far[2] / 100.0
            # 有旋转时先对 far corner 施加 yaw，再裁剪
            rot = a.get("rot")
            if rot and len(rot) >= 2:
                yaw = math.radians(rot[1])  # [Pitch, Yaw, Roll]
                fx, fy = (fx * math.cos(yaw) - fy * math.sin(yaw),
                          fx * math.sin(yaw) + fy * math.cos(yaw))
            t, t2 = (y, y + fy) if cfg["axis"] == "Y" else (x, x + fx)
            s = x if cfg["axis"] == "Y" else y
            s2 = (x + fx) if cfg["axis"] == "Y" else (y + fy)
            tlo, thi = sorted([t, t2])
            if thi < cfg["t0"] or tlo > cfg["t1"]:
                continue
            if abs((s + s2) / 2 - cfg["s_ref"]) > 22.0:
                continue
            ga = to_game(cfg, (x, y, z))
            gb = to_game(cfg, (x + fx, y + fy, z + fz))
            x0, x1 = sorted([ga[0], gb[0]])
            d0, d1 = sorted([ga[1], gb[1]])
            y0, y1 = sorted([ga[2], gb[2]])
            x0 = max(-30.0, x0); x1 = min(cfg["game_w"] * 100.0 + 30.0, x1)
            if x1 - x0 < 10.0:
                continue
            mid_d = (d0 + d1) / 2
            if mid_d <= 0:
                continue           # 靠近镜头的阻挡面会挡角色，只保留后景
            d0, d1 = 50.0, min(260.0, mid_d + 8.0)
            out.append((a, "blocking", (x0 + x1) / 2, (d0 + d1) / 2,
                        y0,
                        [max(0.2, (x1 - x0) / 100.0), max(0.08, (d1 - d0) / 100.0), max(0.2, (y1 - y0) / 100.0)]))
            continue

        t, s = (y, x) if cfg["axis"] == "Y" else (x, y)
        if not (cfg["t0"] <= t <= cfg["t1"]):
            continue
        if abs(s - cfg["s_ref"]) > 16.0:
            continue
        kind = kind_of(name, mesh)
        if kind == "other":
            continue
        # 门/窗代表立面开洞的水平位置，不随层高裁剪；贴到地面/窗台高度带
        if kind not in ("door", "window") and (z < cfg["h_ref"] - 0.5 or z > cfg["h_top"]):
            continue
        gx, dep, hgt = to_game(cfg, (x, y, z))
        if kind == "window":
            hgt = 90.0
        elif kind == "door":
            hgt = 0.0
        if gx < -120 or gx > cfg["game_w"] * 100 + 120:
            continue
        if kind in ("wall", "tree", "table", "beam", "rock", "door", "window", "litter"):
            dep = 58.0   # 后景：远离 +Z 相机（glTF z=-depth/100 落在负 z）
        dep = max(-260.0, min(260.0, dep))
        size = parse_size(mesh, a.get("scale"))
        out.append((a, kind, gx, dep, hgt, size))
    out.sort(key=lambda it: (KIND_PRIORITY.get(it[1], 10), it[2]))
    return out[:cfg["max_items"]]



def anchors_outside(b):
    """城外：下层贯通通路 + 架高台面 + 低拱（rooms.ts arch y:0 h:44）。"""
    b.box("M_xm3d_earth", 0.0, 12.4, -2.4, 2.4, -0.10, 0.0)
    b.box("M_xm3d_stone", 0.0, 0.40, -0.90, 0.90, 0.0, 0.96)          # 街口左墙
    for i in range(5):  # 石阶 56–128 五级到 0.96
        x0 = 0.56 + i * 0.144
        x1 = 0.56 + (i + 1) * 0.144 if i < 4 else 1.28
        b.box("M_xm3d_stone", x0, x1, -0.75, 0.75, 0.0, 0.192 * (i + 1))
    # 台面 128–512：顶板 0.84–0.96，下层贯通；支柱在可走带 depth 外
    b.box("M_xm3d_stone", 1.28, 5.12, -0.60, 1.55, 0.84, 0.96)
    for px in (1.36, 2.10, 2.86, 3.62, 4.38, 4.96):
        b.box("M_xm3d_stone_dark", px, px + 0.16, 1.19, 1.35, 0.0, 0.84)
    # 低拱在下层：净高 0.44（楣底 0.44、顶 0.56），拱脚 y0–0.56 且放 depth 两侧
    b.box("M_xm3d_stone_dark", 2.80, 2.92, 0.55, 0.95, 0.0, 0.56)
    b.box("M_xm3d_stone_dark", 3.48, 3.60, 0.55, 0.95, 0.0, 0.56)
    b.box("M_xm3d_stone", 2.80, 3.60, 0.10, 0.95, 0.44, 0.56)
    # 城墙 512–600：y0.96 以上，下面 0–0.96 贯通（不加热断端板）
    b.box("M_xm3d_stone", 5.12, 6.00, -1.20, 1.20, 0.96, 2.30)
    # 墙根阶 700–820 到 0.64；平台 820–940 顶 0.64
    for x0, x1, h in [(7.00, 7.40, 0.16), (7.40, 7.80, 0.32), (7.80, 8.10, 0.48), (8.10, 8.20, 0.64)]:
        b.box("M_xm3d_stone", x0, x1, -0.75, 0.75, 0.0, h)
    b.box("M_xm3d_stone", 8.20, 9.40, -1.30, 1.30, 0.0, 0.64)
    b.box("M_xm3d_stone_dark", 12.00, 12.40, -1.10, 1.10, 0.0, 1.40)


def anchors_village(b):
    b.box("M_xm3d_earth", 0.0, 7.2, -2.0, 2.0, -0.10, 0.0)
    b.box("M_xm3d_earth", 2.72, 3.04, -0.5, 0.5, -0.06, -0.02)      # 软土
    b.box("M_xm3d_stone", 6.08, 7.20, -0.9, 0.9, 0.0, 0.02)         # 砖地
    b.box("M_xm3d_wood", 3.04, 4.16, -0.42, 0.42, 0.44, 0.50)        # 桌面 44
    for lx in (3.10, 4.02):
        for ld in (-0.34, 0.26):
            b.box("M_xm3d_wood_dark", lx, lx + 0.08, ld, ld + 0.08, 0.0, 0.44)
    b.box("M_xm3d_wood_dark", 0.90, 1.12, -0.30, 0.30, 0.0, 0.42)    # 瓶架
    b.box("M_xm3d_wood", 0.90, 1.12, -0.32, 0.32, 0.44, 0.46)
    b.cyl("M_xm3d_metal", 5.48, 0.18, 0.19, 0.0, 0.10, 10)           # 铁盆
    for a, c in ((0.0, 3.4), (4.4, 6.4)):
        b.box("M_xm3d_plaster", a, c, 1.05, 1.35, 0.0, 2.20)
        b.box("M_xm3d_stone_dark", a, c, 1.03, 1.37, 0.0, 0.28)
    b.box("M_xm3d_plaster", 0.0, 0.30, -1.35, 1.35, 0.0, 2.20)
    b.box("M_xm3d_plaster", 7.00, 7.20, -1.35, 1.35, 0.0, 2.20)
    b.box("M_xm3d_wood_dark", 6.40, 7.20, 1.00, 1.40, 1.20, 1.36)


def anchors_forest(b):
    b.box("M_xm3d_earth", 0.0, 16.0, -2.2, 2.2, -0.12, 0.0)
    b.cyl("M_xm3d_wood_dark", 3.02, -0.10, 0.16, 0.0, 0.44, 8)
    b.cyl("M_xm3d_wood_dark", 3.78, 0.10, 0.16, 0.0, 0.44, 8)
    b.box("M_xm3d_wood_dark", 3.00, 3.80, -0.30, 0.30, 0.44, 0.54)
    b.box("M_xm3d_stone_dark", 7.00, 7.90, -0.50, 0.50, -0.10, -0.02)
    b.box("M_xm3d_stone", 6.92, 7.00, -0.55, 0.55, -0.06, 0.06)
    b.box("M_xm3d_stone", 7.90, 7.98, -0.55, 0.55, -0.06, 0.06)
    b.box("M_xm3d_earth", 5.20, 6.40, -0.90, 0.90, 0.0, 0.22)
    b.box("M_xm3d_stone", 9.80, 11.00, -0.90, 0.90, 0.0, 0.22)
    b.box("M_xm3d_metal", 11.50, 12.60, -1.10, 1.10, -0.10, -0.02)
    b.box("M_xm3d_stone_dark", 11.40, 11.52, -1.15, 1.15, -0.10, 0.10)
    b.box("M_xm3d_stone_dark", 12.58, 12.70, -1.15, 1.15, -0.10, 0.12)
    b.box("M_xm3d_void", 14.5, 16.0, 1.55, 2.10, 0.0, 2.40)


def anchors_tower(b):
    b.box("M_xm3d_stone", 0.0, 7.2, -1.9, 1.9, -0.10, 0.0)
    b.box("M_xm3d_stone_dark", 1.80, 4.00, -1.20, 1.20, 0.0, 2.20)
    b.box("M_xm3d_stone", 4.00, 4.90, -1.10, 1.10, 1.10, 1.40)
    b.box("M_xm3d_wood_dark", 4.30, 4.36, -0.55, 0.55, 0.0, 1.20)
    b.box("M_xm3d_wood_dark", 4.64, 4.70, -0.55, 0.55, 0.0, 1.20)
    b.box("M_xm3d_wood", 4.30, 4.70, -0.55, 0.55, 1.14, 1.24)
    # 门洞 4.36–4.64 留空（动态门在运行时，开门后真空通行）
    b.box("M_xm3d_stone_dark", 7.00, 7.20, -1.20, 1.20, 0.0, 2.20)
    b.box("M_xm3d_stone_dark", 4.90, 7.20, 1.20, 1.55, 0.0, 1.80)
    b.box("M_xm3d_wood", 5.60, 6.50, -0.42, 0.42, 0.27, 0.32)         # 值夜桌：collider 高 32
    for lx in (5.66, 6.34):
        for ld in (-0.32, 0.24):
            b.box("M_xm3d_wood_dark", lx, lx + 0.08, ld, ld + 0.08, 0.0, 0.27)
    b.box("M_xm3d_void", 6.60, 7.00, 1.15, 1.25, 1.10, 1.80)        # 西窗
    b.box("M_xm3d_wood_dark", 6.58, 7.02, 1.12, 1.28, 1.04, 1.12)
    b.box("M_xm3d_wood_dark", 6.78, 6.82, 1.13, 1.27, 1.10, 1.80)
    b.box("M_xm3d_wood_dark", 6.60, 7.00, 1.13, 1.27, 1.42, 1.46)
    for i in range(6):
        x0 = 4.95 + i * 0.26
        b.box("M_xm3d_stone", x0, x0 + 0.26, 1.40, 2.00, 0.0, 0.18 + i * 0.18)


ANCHORS = {"outside": anchors_outside, "village": anchors_village,
           "forest": anchors_forest, "tower": anchors_tower}


# ---------------------------------------------------------------- 导出
def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def make_material(name):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    color, rough, metal = MATERIALS[name]
    nodes = mat.node_tree.nodes
    bsdf = next((n for n in nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf is None:
        bsdf = nodes.new("ShaderNodeBsdfPrincipled")
        out = next((n for n in nodes if n.type == "OUTPUT_MATERIAL"), None)
        if out is None:
            out = nodes.new("ShaderNodeOutputMaterial")
        mat.node_tree.links.new(bsdf.outputs[0], out.inputs[0])
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    mat.diffuse_color = color
    return mat


def build_object(name, batch):
    mesh = bpy.data.meshes.new(name + "_mesh")
    mesh.from_pydata(batch["verts"], [], batch["faces"])
    mesh.validate()
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    # 统一外法线
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    mesh.update()
    mesh.calc_loop_triangles()
    return obj, len(mesh.loop_triangles)


def export_room(room, cfg):
    clear_scene()
    actors = load_level(cfg)
    derive_refs(cfg, actors)
    cfg = dict(cfg)  # 不污染 ROOM_CFG 原始值
    batch = RoomBatch(room)
    picked = filter_actors(cfg, actors)
    blocking = sum(1 for it in picked if it[1] == "blocking")
    for i, (a, kind, gx, dep, hgt, size) in enumerate(picked):
        meta = {
            "room": room, "target": "%s_%s_%03d" % (room, kind, i + 1), "kind": kind,
            "anchor": False,
            "source": {
                "level": cfg["level"], "name": a.get("name") or "",
                "cls": a.get("cls") or "", "mesh": (a.get("meshes") or [""])[0],
                "srcUe": [round(v / 100.0, 3) for v in (a.get("loc") or [0, 0, 0])],
            },
            "game": [round(gx, 1), round(hgt, 1), round(dep, 1)],
        }
        gen_item(batch, kind, gx, dep, hgt, size, meta, cfg)
    # 玩法锚点（以 rooms.ts 为准，单独标注）
    base = len(batch.items)
    ANCHORS[room](batch)
    for it in batch.items[base:]:
        it["anchor"] = True
        it["source"] = {"level": "rooms.ts", "name": it["target"]}

    objs = []
    tris = 0
    used = []
    for mat_name in MATERIALS:
        b = batch.by_mat[mat_name]
        if not b["verts"]:
            continue
        obj, t = build_object(room + "_" + mat_name.replace("M_xm3d_", ""), b)
        obj.data.materials.append(make_material(mat_name))
        objs.append(obj)
        used.append(mat_name)
        tris += t
    bpy.ops.object.select_all(action="SELECT")
    path = os.path.join(OUT_DIR, room + ".glb")
    bpy.ops.export_scene.gltf(
        filepath=path, export_format="GLB", export_yup=True, export_apply=True,
        use_selection=True, export_cameras=False, export_lights=False, export_extras=True,
    )
    print("[xm3d] %-7s src=%d blocking=%d boxes=%d tris=%d mats=%d size=%dB"
          % (room, len(picked), blocking, batch.boxes, tris, len(used), os.path.getsize(path)))
    return {
        "room": room, "level": cfg["level"], "window_m": [cfg["t0"], cfg["t1"]],
        "blocking_planes": blocking, "source_total": cfg.get("_win", 0),
        "game_width": cfg["game_w"], "depth_scale": cfg["k"], "h_ref": cfg["h_ref"], "h_top": cfg.get("h_top"),
        "source_actors": len(picked), "boxes": batch.boxes, "triangles": tris,
        "materials": used, "bytes": os.path.getsize(path),
        "items": batch.items,
    }


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    rooms = []
    for room, cfg in ROOM_CFG.items():
        rooms.append(export_room(room, cfg))
    meta = {
        "generator": "tools/build-xiaoman-map.py",
        "unit": "1 glTF unit = 1 m = 100 game units",
        "coordinate": {
            "gltf_x": "gameX/100", "gltf_y": "height/100", "gltf_z": "-depth/100",
            "y_up": True, "walk_band_depth": [-0.44, 0.44],
        },
        "materials": {k: {"baseColor": list(v[0]), "roughness": v[1], "metallic": v[2]}
                      for k, v in MATERIALS.items()},
        "rooms": rooms,
    }
    with open(os.path.join(OUT_DIR, "manifest.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)
    print("[xm3d] manifest ->", os.path.join(OUT_DIR, "manifest.json"))


main()
