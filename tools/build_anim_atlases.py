#!/usr/bin/env python3
"""《向西守望》高帧角色动作与暗黑像素特效图集自动化构建管线。

用法:
    uv run --with pillow --with numpy python3 tools/build_anim_atlases.py

职责:
1. 从 art-source/anim_v2/ 读取全部 16 组品红底（#FF00FF）高帧动作/特效原画；
2. 采用基于通道差 m = min(R, B) - G 的边界漫水抠底 + 连通域杂点清理 + 边缘去溢色，
   输出零粉边、锐利像素轮廓的真透明单帧；
3. 按每个角色的「基准站姿像素缩放比」统一缩放全部状态帧（蹲伏/跳跃/滑铲/倒地不再错误拉伸变大），
   对齐统一脚底基线（anchorY = 0）与水平质量中心（anchorX = 0.5）；
4. 紧凑打包为 5 套 <= 2048x2048 的 Dora .png + .clip 图集：
   - assets/art/actors_zhoushu_anim.png/.clip
   - assets/art/actors_xiaoman_anim.png/.clip
   - assets/art/actors_duo_anim.png/.clip
   - assets/art/actors_enemies_anim.png/.clip
   - assets/art/vfx_ming_fx.png/.clip
5. 从角色原画与关节参数重建各 160 张跑步帧、96 张起停帧和 64 张滑铲。
6. 在 scratch 目录输出拼帧审验图，便于视觉逐帧质检。
"""

from __future__ import annotations

import subprocess
import sys
from collections import deque
from pathlib import Path
from xml.etree import ElementTree as XML

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "art-source" / "anim_v2"
CHAR_SRC = ROOT / "art-source" / "characters"
ART = ROOT / "assets" / "art"

GUTTER = 2
MAX_ATLAS_W = 2048


def split_grid(path: Path, cols: int, rows: int, inset: int = 3) -> list[Image.Image]:
    """按均匀网格裁切原画，并通过 inset 裁去可能残留在格界上的 1-2px 分割线。"""
    with Image.open(path) as im:
        rgb = im.convert("RGB")
        w, h = rgb.size
        cells: list[Image.Image] = []
        for r in range(rows):
            for c in range(cols):
                x0 = c * w // cols + inset
                y0 = r * h // rows + inset
                x1 = (c + 1) * w // cols - inset
                y1 = (r + 1) * h // rows - inset
                cells.append(rgb.crop((x0, y0, x1, y1)))
        return cells


def split_grid_valleys(
    path: Path,
    cols: int,
    rows: int,
    search_x: int = 48,
    search_y: int = 32,
    inset: int = 2,
) -> list[Image.Image]:
    """沿相邻格间最纯净品红谷底自动微调切缝，避免伸出肢体/投掷物被均分网格误切到相邻格。"""
    with Image.open(path) as im:
        rgb = im.convert("RGB")
        w, h = rgb.size
        arr = np.asarray(rgb, dtype=np.int16)
        fg_mask = (np.minimum(arr[:, :, 0], arr[:, :, 2]) - arr[:, :, 1]) <= 46

        row_bounds = [0]
        for r in range(1, rows):
            nom = r * h // rows
            lo = max(row_bounds[-1] + 24, nom - search_y)
            hi = min(h - 24, nom + search_y)
            row_fg = fg_mask[lo : hi + 1, :].sum(axis=1)
            # 优先选前景最少且最接近标称线的行
            best_off = min(range(len(row_fg)), key=lambda idx: (int(row_fg[idx]), abs(lo + idx - nom)))
            row_bounds.append(lo + best_off)
        row_bounds.append(h)

        cells: list[Image.Image] = []
        for r in range(rows):
            y0_raw = row_bounds[r]
            y1_raw = row_bounds[r + 1]
            col_bounds = [0]
            for c in range(1, cols):
                nom = c * w // cols
                lo = max(col_bounds[-1] + 24, nom - search_x)
                hi = min(w - 24, nom + search_x)
                col_fg = fg_mask[y0_raw:y1_raw, lo : hi + 1].sum(axis=0)
                best_off = min(range(len(col_fg)), key=lambda idx: (int(col_fg[idx]), abs(lo + idx - nom)))
                col_bounds.append(lo + best_off)
            col_bounds.append(w)

            for c in range(cols):
                x0 = col_bounds[c] + inset
                y0 = y0_raw + inset
                x1 = col_bounds[c + 1] - inset
                y1 = y1_raw - inset
                cells.append(rgb.crop((x0, y0, x1, y1)))
        return cells


def chroma_key_magenta(
    cell: Image.Image,
    keep_all_components: bool = False,
    keep_main_only: bool = False,
    min_component_px: int = 24,
    drop_top_right_detached: bool = False,
    bg_thresh: int = 34,
    inner_thresh: int = 62,
    dilate_thresh: int = 22,
) -> Image.Image:
    """针对明代写实色板与 JPEG 品红底的无损锐利抠底 + 去品红溢色。"""
    arr = np.asarray(cell.convert("RGB"), dtype=np.int16)
    h, w, _ = arr.shape
    r = arr[:, :, 0]
    g = arr[:, :, 1]
    b = arr[:, :, 2]

    # 品红特征量：明代所有色系（青灰、暗铁、旧锈红、褐木、肤色、暖金）均满足 min(R, B) - G <= 18
    m_score = np.minimum(r, b) - g

    # 1. 从四边漫水填充所有外部品红背景（容忍 JPEG 边缘压缩波动）
    bg = np.zeros((h, w), dtype=bool)
    cand_bg = m_score > bg_thresh
    q: deque[tuple[int, int]] = deque()
    for x in range(w):
        if cand_bg[0, x]:
            bg[0, x] = True
            q.append((0, x))
        if cand_bg[h - 1, x]:
            bg[h - 1, x] = True
            q.append((h - 1, x))
    for y in range(h):
        if cand_bg[y, 0] and not bg[y, 0]:
            bg[y, 0] = True
            q.append((y, 0))
        if cand_bg[y, w - 1] and not bg[y, w - 1]:
            bg[y, w - 1] = True
            q.append((y, w - 1))

    while q:
        cy, cx = q.popleft()
        for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
            if 0 <= ny < h and 0 <= nx < w and not bg[ny, nx] and cand_bg[ny, nx]:
                bg[ny, nx] = True
                q.append((ny, nx))

    # 2. 清除闭合孔洞（如腿间、臂下、盾牌与手之间、飘带缝隙的孤立品红区）
    inner_magenta = m_score > inner_thresh
    bg |= inner_magenta

    # 3. 剥离紧贴背景的 1px 半品红 JPEG 过渡像素
    bg_dilated = bg.copy()
    bg_dilated[1:, :] |= bg[:-1, :]
    bg_dilated[:-1, :] |= bg[1:, :]
    bg_dilated[:, 1:] |= bg[:, :-1]
    bg_dilated[:, :-1] |= bg[:, 1:]
    bg |= bg_dilated & (m_score > dilate_thresh)

    fg = ~bg

    # 4. 连通域去噪（保留主体与有效独立配件如飞起的斗笠/火花，滤除 JPEG 杂点）
    visited = np.zeros((h, w), dtype=bool)
    comps: list[tuple[int, int, int, int, int, list[tuple[int, int]]]] = []
    for y in range(h):
        for x in range(w):
            if fg[y, x] and not visited[y, x]:
                stack = [(y, x)]
                visited[y, x] = True
                pts: list[tuple[int, int]] = []
                min_x = max_x = x
                min_y = max_y = y
                while stack:
                    py, px = stack.pop()
                    pts.append((py, px))
                    if px < min_x: min_x = px
                    if px > max_x: max_x = px
                    if py < min_y: min_y = py
                    if py > max_y: max_y = py
                    for ny in range(max(0, py - 1), min(h, py + 2)):
                        for nx in range(max(0, px - 1), min(w, px + 2)):
                            if fg[ny, nx] and not visited[ny, nx]:
                                visited[ny, nx] = True
                                stack.append((ny, nx))
                comps.append((len(pts), min_x, min_y, max_x, max_y, pts))

    clean_fg = np.zeros((h, w), dtype=bool)
    if comps:
        comps.sort(key=lambda item: item[0], reverse=True)
        largest = comps[0][0]
        if keep_main_only:
            for py, px in comps[0][5]:
                clean_fg[py, px] = True
        else:
            for count, cx0, cy0, cx1, cy1, pts in comps:
                if drop_top_right_detached and count < largest * 0.15 and cx0 > w * 0.58 and cy1 < h * 0.55:
                    continue
                if keep_all_components:
                    if count >= max(3, min_component_px):
                        for py, px in pts:
                            clean_fg[py, px] = True
                else:
                    if count >= max(min_component_px, int(largest * 0.008)):
                        for py, px in pts:
                            clean_fg[py, px] = True

    # 5. 边缘去品红溢色（针对前景外圈 2px 抑制过高 R/B，保证深暗场景下轮廓绝对干净无粉边）
    edge1 = clean_fg & (
        (~np.pad(clean_fg, 1, constant_values=False)[:-2, 1:-1])
        | (~np.pad(clean_fg, 1, constant_values=False)[2:, 1:-1])
        | (~np.pad(clean_fg, 1, constant_values=False)[1:-1, :-2])
        | (~np.pad(clean_fg, 1, constant_values=False)[1:-1, 2:])
    )
    edge2 = clean_fg & (
        np.pad(edge1, 1, constant_values=False)[:-2, 1:-1]
        | np.pad(edge1, 1, constant_values=False)[2:, 1:-1]
        | np.pad(edge1, 1, constant_values=False)[1:-1, :-2]
        | np.pad(edge1, 1, constant_values=False)[1:-1, 2:]
    )
    edge_band = edge1 | edge2

    out = np.zeros((h, w, 4), dtype=np.uint8)
    out[:, :, 0] = arr[:, :, 0].astype(np.uint8)
    out[:, :, 1] = arr[:, :, 1].astype(np.uint8)
    out[:, :, 2] = arr[:, :, 2].astype(np.uint8)
    out[:, :, 3] = np.where(clean_fg, 255, 0).astype(np.uint8)

    # 在边界带抑制品红溢色：当 min(R, B) > G + 4 时压低溢色并适度柔化最外缘半透明
    spill_mask = edge_band & (m_score > 6)
    if np.any(spill_mask):
        ys, xs = np.where(spill_mask)
        for py, px in zip(ys, xs):
            rv, gv, bv = int(arr[py, px, 0]), int(arr[py, px, 1]), int(arr[py, px, 2])
            ms = min(rv, bv) - gv
            # 将品红背景贡献线性扣除（保持暗轮廓与暖红/青灰本色）
            reduce = int(ms * 0.88)
            out[py, px, 0] = max(0, rv - reduce)
            out[py, px, 2] = max(0, bv - reduce)
            if edge1[py, px] and ms > 26:
                out[py, px, 3] = max(90, 255 - (ms - 26) * 5)

    im = Image.fromarray(out, "RGBA")
    bbox = im.getbbox()
    if bbox is None:
        return Image.new("RGBA", (8, 8))
    return im.crop(bbox)


def torso_center_x(im: Image.Image) -> float:
    """取躯干腰胸带（高度 32%..66%）的水平质量中心，确保奔跑/举枪/伸臂时重心稳定不左右跳。"""
    alpha = np.asarray(im.getchannel("A"), dtype=np.float32)
    h, w = alpha.shape
    y0 = int(h * 0.30)
    y1 = max(y0 + 1, int(h * 0.68))
    band = alpha[y0:y1, :]
    col_mass = band.sum(axis=0)
    total = float(col_mass.sum())
    if total <= 1e-3:
        return w * 0.5
    xs = np.arange(w, dtype=np.float32)
    return float((xs * col_mass).sum() / total)


def normalize_character_cel(
    im: Image.Image,
    scale: float,
    canvas_h: int,
    center_ratio: float | None = None,
    foot_lift: int = 0,
    fixed_canvas_w: int | None = None,
) -> Image.Image:
    """按统一基准比例缩放角色帧，并对齐到底边基线与水平重心（anchorX=0.5, anchorY=0）。"""
    new_w = max(2, int(round(im.width * scale)))
    new_h = max(2, int(round(im.height * scale)))
    resized = im.resize((new_w, new_h), Image.Resampling.LANCZOS)

    # LANCZOS 缩放后轻度清理极低透明度半边，保持像素硬朗边缘
    ra = np.asarray(resized, dtype=np.uint8).copy()
    ra[:, :, 3] = np.where(ra[:, :, 3] < 96, 0, np.where(ra[:, :, 3] > 210, 255, ra[:, :, 3]))
    resized = Image.fromarray(ra, "RGBA")
    bbox = resized.getbbox()
    if bbox is not None:
        resized = resized.crop(bbox)

    cx = (resized.width * center_ratio) if center_ratio is not None else torso_center_x(resized)
    if fixed_canvas_w is not None:
        cw = fixed_canvas_w
    else:
        half = int(max(cx, resized.width - cx)) + 4
        cw = max(16, half * 2)
    ch = max(canvas_h, resized.height + foot_lift)
    canvas = Image.new("RGBA", (cw, ch))
    px = int(round(cw * 0.5 - cx))
    py = ch - resized.height - foot_lift
    canvas.alpha_composite(resized, (px, max(0, py)))
    return canvas


def normalize_vfx_cel(im: Image.Image, target_max: int) -> Image.Image:
    """保持纵横比缩放特效精灵至清晰紧凑尺寸并去微弱半透杂边。"""
    scale = target_max / max(1, max(im.width, im.height))
    nw = max(4, int(round(im.width * scale)))
    nh = max(4, int(round(im.height * scale)))
    resized = im.resize((nw, nh), Image.Resampling.LANCZOS)
    ra = np.asarray(resized, dtype=np.uint8).copy()
    ra[:, :, 3] = np.where(ra[:, :, 3] < 48, 0, ra[:, :, 3])
    return Image.fromarray(ra, "RGBA")


def pack_clip_atlas(name: str, frames: dict[str, Image.Image], max_w: int = MAX_ATLAS_W) -> tuple[int, int]:
    """紧凑行打包 Dora .png + .clip 图集，严格确保宽/高 <= 2048。"""
    items = sorted(frames.items(), key=lambda kv: (-kv[1].height, kv[0]))
    x, y, row_h = GUTTER, GUTTER, 0
    placements: list[tuple[str, Image.Image, int, int]] = []
    used_w = 0
    for key, im in items:
        if x + im.width + GUTTER > max_w:
            x = GUTTER
            y += row_h + 2 * GUTTER
            row_h = 0
        placements.append((key, im, x, y))
        x += im.width + 2 * GUTTER
        used_w = max(used_w, x)
        row_h = max(row_h, im.height)

    atlas_w = min(max_w, max(64, used_w))
    atlas_h = max(64, y + row_h + GUTTER)
    if atlas_w > 2048 or atlas_h > 2048:
        raise RuntimeError(f"Atlas {name} exceeds 2048 limit: {atlas_w}x{atlas_h}")

    atlas = Image.new("RGBA", (atlas_w, atlas_h))
    manifest = XML.Element("A", A=f"{name}.png")
    for key, im, px, py in placements:
        atlas.alpha_composite(im, (px, py))
        XML.SubElement(manifest, "B", A=key, B=f"{px},{py},{im.width},{im.height}")

    atlas.save(ART / f"{name}.png", optimize=True)
    XML.indent(manifest, "  ")
    (ART / f"{name}.clip").write_text(XML.tostring(manifest, encoding="unicode") + "\n", encoding="utf-8")
    print(f"  [PACK] {name}.png ({atlas_w}x{atlas_h}, {len(placements)} frames, {(ART / f'{name}.png').stat().st_size // 1024}KB)")
    return atlas_w, atlas_h


def make_pixel_leaf(variant: int) -> Image.Image:
    """生成 2 帧精致明代松叶/暗林飘叶像素精灵（无粗黑边，暗松青 + 浅玉青叶脉高光）。"""
    im = Image.new("RGBA", (14, 10), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    if variant == 0:
        d.polygon([(1, 6), (5, 2), (12, 3), (8, 7)], fill=(44, 82, 68, 255))
        d.line([(2, 6), (11, 3)], fill=(112, 152, 134, 255), width=1)
        d.point([(6, 3), (9, 4)], fill=(154, 188, 168, 255))
    else:
        d.polygon([(2, 2), (10, 3), (12, 8), (5, 7)], fill=(58, 96, 78, 255))
        d.line([(3, 3), (11, 7)], fill=(134, 172, 148, 255), width=1)
        d.point([(7, 4), (4, 5)], fill=(176, 206, 184, 255))
    return im


def main() -> None:
    print("=== 开始构建《向西守望》高帧动画与暗黑像素特效图集 ===")

    # ------------------------------------------------------------------ 1. 周戍全套高帧动作
    zs_idle_jump_raw = [chroma_key_magenta(c, keep_main_only=True) for c in split_grid_valleys(SRC / "zs_idle_jump_8f.jpg", 4, 2, inset=2)]
    zs_combat_raw = [chroma_key_magenta(c, keep_main_only=True) for c in split_grid_valleys(SRC / "zs_combat_8f.jpg", 4, 2, inset=3)]
    zs_slide_push_raw = [chroma_key_magenta(c, keep_main_only=True) for c in split_grid_valleys(SRC / "zs_slide_push_8f.jpg", 4, 2, inset=2)]

    # 基准缩放：站立高度 = 198px（严格对齐 actors-hd.clip 的 soldier_idle = 198px）
    zs_idle_scale = 198.0 / max(1, zs_idle_jump_raw[0].height)
    zs_combat_scale = 196.0 / max(1, zs_combat_raw[0].height)
    zs_slide_scale = 192.0 / max(1, zs_slide_push_raw[4].height)  # 以推车直立迈步为同图比例尺

    zs_frames: dict[str, Image.Image] = {}
    for i in range(4):
        zs_frames[f"zs_idle_{i}"] = normalize_character_cel(zs_idle_jump_raw[i], zs_idle_scale, 198)
    # 跳跃四帧：起跳蹲伏/上升/下落/落地缓冲（上升与下落略抬脚底留出凌空轻盈感）
    zs_frames["zs_jump_0"] = normalize_character_cel(zs_idle_jump_raw[4], zs_idle_scale, 198)
    zs_frames["zs_jump_1"] = normalize_character_cel(zs_idle_jump_raw[5], zs_idle_scale * 0.96, 198, foot_lift=6)
    zs_frames["zs_jump_2"] = normalize_character_cel(zs_idle_jump_raw[6], zs_idle_scale * 0.96, 198, foot_lift=4)
    zs_frames["zs_jump_3"] = normalize_character_cel(zs_idle_jump_raw[7], zs_idle_scale, 198)

    # 举枪射击 4 帧（中心偏左 0.34，避免枪管伸长导致人物身体左移）
    for i in range(4):
        zs_frames[f"zs_fire_{i}"] = normalize_character_cel(zs_combat_raw[i], zs_combat_scale, 198, center_ratio=0.33)
    # 掩体呼吸 2 帧 + 受击硬直/踉跄 2 帧
    zs_frames["zs_cover_0"] = normalize_character_cel(zs_combat_raw[4], zs_combat_scale, 198)
    zs_frames["zs_cover_1"] = normalize_character_cel(zs_combat_raw[5], zs_combat_scale, 198)
    zs_frames["zs_hit_0"] = normalize_character_cel(zs_combat_raw[6], zs_combat_scale, 198)
    zs_frames["zs_hit_1"] = normalize_character_cel(zs_combat_raw[7], zs_combat_scale, 198)

    # 推板车 4 帧发力步态
    for i in range(4):
        zs_frames[f"zs_push_{i}"] = normalize_character_cel(zs_slide_push_raw[4 + i], zs_slide_scale, 198)
    # 滑铲 4 帧重制原画
    zs_slide_cels: list[Image.Image] = []
    for i in range(4):
        scel = normalize_character_cel(zs_slide_push_raw[i], zs_slide_scale * 1.02, 198, fixed_canvas_w=300)
        zs_slide_cels.append(scel)
        zs_frames[f"zs_slide_{i}"] = normalize_character_cel(zs_slide_push_raw[i], zs_slide_scale * 1.02, 198)

    pack_clip_atlas("actors_zhoushu_anim", zs_frames)

    # ------------------------------------------------------------------ 3. 小满全套高帧动作
    xm_idle_jump_raw = [chroma_key_magenta(c, keep_main_only=True) for c in split_grid_valleys(SRC / "xm_idle_jump_8f.jpg", 4, 2, inset=2)]
    xm_stealth_cells = split_grid_valleys(SRC / "xm_stealth_action_8f.jpg", 4, 2, inset=2)
    xm_stealth_raw = [
        chroma_key_magenta(c, keep_main_only=True)
        for c in xm_stealth_cells
    ]

    xm_idle_scale = 144.0 / max(1, xm_idle_jump_raw[0].height)
    xm_stealth_scale = 142.0 / max(1, xm_stealth_raw[4].height)  # R2C1 站姿拉车作为基准尺

    xm_frames: dict[str, Image.Image] = {}
    for i in range(4):
        xm_frames[f"xm_idle_{i}"] = normalize_character_cel(xm_idle_jump_raw[i], xm_idle_scale, 144)
    xm_frames["xm_jump_0"] = normalize_character_cel(xm_idle_jump_raw[4], xm_idle_scale, 144)
    xm_frames["xm_jump_1"] = normalize_character_cel(xm_idle_jump_raw[5], xm_idle_scale * 0.96, 144, foot_lift=6)
    xm_frames["xm_jump_2"] = normalize_character_cel(xm_idle_jump_raw[6], xm_idle_scale * 0.96, 144, foot_lift=4)
    xm_frames["xm_jump_3"] = normalize_character_cel(xm_idle_jump_raw[7], xm_idle_scale, 144)

    for i in range(4):
        xm_frames[f"xm_crawl_{i}"] = normalize_character_cel(xm_stealth_raw[i], xm_stealth_scale, 144)
    xm_frames["xm_pull_mid"] = normalize_character_cel(xm_stealth_raw[4], xm_stealth_scale, 144)
    xm_frames["xm_throw_rel"] = normalize_character_cel(xm_stealth_raw[5], xm_stealth_scale, 144)
    xm_frames["xm_fear_b"] = normalize_character_cel(xm_stealth_raw[6], xm_stealth_scale, 144)
    xm_frames["xm_peek_b"] = normalize_character_cel(xm_stealth_raw[7], xm_stealth_scale, 144)

    pack_clip_atlas("actors_xiaoman_anim", xm_frames)

    # ------------------------------------------------------------------ 4. 兄妹合体全高帧（正统精像素风）
    duo_run_raw = [chroma_key_magenta(c) for c in split_grid(SRC / "duo_carry_run_8f.jpg", 4, 2, inset=4)]
    duo_idle_fire_raw = [chroma_key_magenta(c) for c in split_grid(SRC / "duo_carry_idle_fire_8f.jpg", 4, 2, inset=4)]
    duo_hand_mount_raw = [chroma_key_magenta(c) for c in split_grid(SRC / "duo_hand_mount_8f.jpg", 4, 2, inset=4)]

    duo_run_scale = 206.0 / max(1, duo_run_raw[0].height)
    duo_idle_scale = 208.0 / max(1, duo_idle_fire_raw[0].height)
    duo_hand_scale = 200.0 / max(1, duo_hand_mount_raw[0].height)
    duo_mount_scale = 208.0 / max(1, duo_hand_mount_raw[7].height)  # R2C4 站稳高度作为基准

    duo_frames: dict[str, Image.Image] = {}
    duo_run_bounce = (0, 0, 1, 3, 0, 0, 1, 3)
    for i, foot_lift in enumerate(duo_run_bounce):
        duo_frames[f"duo_carry_run_{i}"] = normalize_character_cel(duo_run_raw[i], duo_run_scale, 210, foot_lift=foot_lift)
    for i in range(4):
        duo_frames[f"duo_carry_idle_{i}"] = normalize_character_cel(duo_idle_fire_raw[i], duo_idle_scale, 210)
        duo_frames[f"duo_carry_fire_{i}"] = normalize_character_cel(duo_idle_fire_raw[4 + i], duo_idle_scale, 210, center_ratio=0.38)
        duo_frames[f"duo_hand_walk_{i}"] = normalize_character_cel(duo_hand_mount_raw[i], duo_hand_scale, 204, center_ratio=0.28)
        duo_frames[f"duo_mount_{i}"] = normalize_character_cel(duo_hand_mount_raw[4 + i], duo_mount_scale, 210)

    pack_clip_atlas("actors_duo_anim", duo_frames)

    # ------------------------------------------------------------------ 5. 敌兵、精英倭寇、拾荒者、猎犬、北塔守卒
    gunner_raw = [chroma_key_magenta(c) for c in split_grid(SRC / "enemy_gunner_8f.jpg", 4, 2, inset=4)]
    elites_raw = [chroma_key_magenta(c) for c in split_grid(SRC / "enemy_elites_12f.jpg", 4, 3, inset=4)]
    scav_dog_raw = [chroma_key_magenta(c) for c in split_grid(SRC / "scavenger_dog_8f.jpg", 4, 2, inset=4)]
    guard_raw = [chroma_key_magenta(c) for c in split_grid(SRC / "tower_guard_anim_8f.jpg", 4, 2, inset=4)]

    gun_scale = 192.0 / max(1, gunner_raw[0].height)
    gun_aim_scale = 192.0 / max(1, gunner_raw[4].height)
    gun_fire_scale = 192.0 / max(1, gunner_raw[5].height)
    shd_scale = 188.0 / max(1, elites_raw[0].height)
    brk_scale = 192.0 / max(1, elites_raw[4].height)
    ldr_scale = 196.0 / max(1, elites_raw[8].height)
    scav_scale = 184.0 / max(1, scav_dog_raw[0].height)
    dog_scale = 88.0 / max(1, scav_dog_raw[5].height)  # 以警觉立耳为基准高度
    guard_scale = 190.0 / max(1, guard_raw[0].height)

    enemy_frames: dict[str, Image.Image] = {
        # 普通倭寇火器手：站姿、举铳和开火的帽顶对齐，切换时不突然矮一截。
        "en_gun_idle_0": normalize_character_cel(gunner_raw[0], gun_scale, 196),
        "en_gun_idle_1": normalize_character_cel(gunner_raw[1], gun_scale, 196),
        "en_gun_walk_0": normalize_character_cel(gunner_raw[2], gun_scale, 196),
        "en_gun_walk_1": normalize_character_cel(gunner_raw[3], gun_scale, 196),
        "en_gun_aim": normalize_character_cel(gunner_raw[4], gun_aim_scale, 196, center_ratio=0.36),
        "en_gun_fire": normalize_character_cel(gunner_raw[5], gun_fire_scale, 196, center_ratio=0.38),
        "en_gun_hit": normalize_character_cel(gunner_raw[6], gun_scale, 196),
        "en_gun_down": normalize_character_cel(gunner_raw[7], gun_scale, 196),
        # 精英 1：藤盾手
        "en_shd_idle": normalize_character_cel(elites_raw[0], shd_scale, 196),
        "en_shd_walk_0": normalize_character_cel(elites_raw[1], shd_scale, 196),
        "en_shd_bash": normalize_character_cel(elites_raw[2], shd_scale, 196),
        "en_shd_hit": normalize_character_cel(elites_raw[3], shd_scale, 196),
        # 精英 2：破障斧手
        "en_brk_walk": normalize_character_cel(elites_raw[4], brk_scale, 200),
        "en_brk_windup": normalize_character_cel(elites_raw[5], brk_scale, 200),
        "en_brk_cleave": normalize_character_cel(elites_raw[6], brk_scale, 200, center_ratio=0.42),
        "en_brk_hit": normalize_character_cel(elites_raw[7], brk_scale, 200),
        # 精英 3：朱缨头领
        "en_ldr_idle": normalize_character_cel(elites_raw[8], ldr_scale, 200),
        "en_ldr_walk": normalize_character_cel(elites_raw[9], ldr_scale, 200),
        "en_ldr_aim": normalize_character_cel(elites_raw[10], ldr_scale, 200, center_ratio=0.38),
        "en_ldr_hit": normalize_character_cel(elites_raw[11], ldr_scale, 200),
        # 村口高清拾荒者
        "scav_walk_0": normalize_character_cel(scav_dog_raw[0], scav_scale, 190),
        "scav_walk_1": normalize_character_cel(scav_dog_raw[1], scav_scale, 190),
        "scav_turn": normalize_character_cel(scav_dog_raw[2], scav_scale, 190),
        "scav_run": normalize_character_cel(scav_dog_raw[3], scav_scale, 190),
        # 森林高清猎犬
        "dog_walk": normalize_character_cel(scav_dog_raw[4], dog_scale, 92),
        "dog_alert": normalize_character_cel(scav_dog_raw[5], dog_scale, 92),
        "dog_run_0": normalize_character_cel(scav_dog_raw[6], dog_scale, 92, foot_lift=4),
        "dog_run_1": normalize_character_cel(scav_dog_raw[7], dog_scale, 92),
        # 北塔值夜守卒（提灯 4 帧 + 登记 4 帧）
        "guard_lantern_0": normalize_character_cel(guard_raw[0], guard_scale, 194, center_ratio=0.38),
        "guard_lantern_1": normalize_character_cel(guard_raw[1], guard_scale, 194, center_ratio=0.38),
        "guard_lantern_2": normalize_character_cel(guard_raw[2], guard_scale, 194, center_ratio=0.38),
        "guard_lantern_3": normalize_character_cel(guard_raw[3], guard_scale, 194, center_ratio=0.38),
        "guard_write_0": normalize_character_cel(guard_raw[4], guard_scale, 194, center_ratio=0.44),
        "guard_write_1": normalize_character_cel(guard_raw[5], guard_scale, 194, center_ratio=0.44),
        "guard_write_2": normalize_character_cel(guard_raw[6], guard_scale, 194, center_ratio=0.44),
        "guard_write_3": normalize_character_cel(guard_raw[7], guard_scale, 194, center_ratio=0.44),
    }
    pack_clip_atlas("actors_enemies_anim", enemy_frames)

    # ------------------------------------------------------------------ 6. 暗黑像素多帧战斗 & 场景 VFX 图集
    combat_vfx_cells = split_grid_valleys(SRC / "vfx_combat_pixel_12f.jpg", 4, 3, inset=2)
    combat_vfx_raw = [
        chroma_key_magenta(
            c,
            keep_all_components=True,
            min_component_px=3,
            bg_thresh=66 if idx == 7 else 34,
            inner_thresh=84 if idx == 7 else 62,
            dilate_thresh=54 if idx == 7 else 22,
        )
        for idx, c in enumerate(combat_vfx_cells)
    ]
    scene_vfx_cells = split_grid_valleys(SRC / "vfx_scene_alive_12f.jpg", 4, 3, inset=2)
    scene_vfx_raw = [
        chroma_key_magenta(
            c,
            keep_all_components=True,
            min_component_px=3,
            bg_thresh=68 if idx in (6, 7) else 34,
            inner_thresh=86 if idx in (6, 7) else 62,
            dilate_thresh=56 if idx in (6, 7) else 22,
        )
        for idx, c in enumerate(scene_vfx_cells)
    ]

    vfx_frames: dict[str, Image.Image] = {
        "muzzle_0": normalize_vfx_cel(combat_vfx_raw[0], 112),
        "muzzle_1": normalize_vfx_cel(combat_vfx_raw[1], 136),
        "muzzle_2": normalize_vfx_cel(combat_vfx_raw[2], 128),
        "muzzle_3": normalize_vfx_cel(combat_vfx_raw[3], 116),
        "smoke_0": normalize_vfx_cel(combat_vfx_raw[4], 108),
        "smoke_1": normalize_vfx_cel(combat_vfx_raw[5], 128),
        "smoke_2": normalize_vfx_cel(combat_vfx_raw[6], 132),
        "smoke_3": normalize_vfx_cel(combat_vfx_raw[7], 118),
        "hit_spark_0": normalize_vfx_cel(combat_vfx_raw[8], 116),
        "debris_0": normalize_vfx_cel(combat_vfx_raw[9], 124),
        "dust_0": normalize_vfx_cel(combat_vfx_raw[10], 108),
        "dust_1": normalize_vfx_cel(combat_vfx_raw[11], 128),
        "flame_0": normalize_vfx_cel(scene_vfx_raw[0], 96),
        "flame_1": normalize_vfx_cel(scene_vfx_raw[1], 96),
        "flame_2": normalize_vfx_cel(scene_vfx_raw[2], 96),
        "flame_3": normalize_vfx_cel(scene_vfx_raw[3], 96),
        "lantern_flame_0": normalize_vfx_cel(scene_vfx_raw[4], 68),
        "lantern_flame_1": normalize_vfx_cel(scene_vfx_raw[5], 68),
        "rain_splash_0": normalize_vfx_cel(scene_vfx_raw[6], 64),
        "rain_splash_1": normalize_vfx_cel(scene_vfx_raw[7], 68),
        "flag_red_0": normalize_vfx_cel(scene_vfx_raw[8], 108),
        "flag_red_1": normalize_vfx_cel(scene_vfx_raw[9], 108),
        "flag_red_2": normalize_vfx_cel(scene_vfx_raw[10], 108),
        "flag_red_3": normalize_vfx_cel(scene_vfx_raw[11], 108),
        "leaf_0": make_pixel_leaf(0),
        "leaf_1": make_pixel_leaf(1),
    }
    pack_clip_atlas("vfx_ming_fx", vfx_frames)

    subprocess.run([sys.executable, str(CHAR_SRC / "build.py")], check=True)
    print("=== 全部图集构建完成！ ===")


if __name__ == "__main__":
    main()
