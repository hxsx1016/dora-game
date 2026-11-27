#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build dark-realistic 3D NPCs and interactive dynamic props for Xiaoman's 4 rooms.

Outputs under assets/xiaoman3d/:
  - scavenger.glb  (village dark hunched patrol NPC with readable boots + lantern + animations)
  - dog.glb        (forest dark hunting hound with alert ears + glowing eyes + animations)
  - guard.glb      (north tower watchman with lantern / writing animations)
  - cart.glb       (outside Ming timber maintenance cart with rotating wheels + fixed left red cloth)
  - bottle.glb     (village coarse terracotta bottle)
  - basin.glb      (village hammered iron washbasin with cool moonlight rim)
  - door.glb       (north tower hinged heavy timber door with iron ring knockers)
  - lantern.glb    (warm Ming paper lantern with glowing core)
  - ledger.glb     (north tower watch desk open rice-paper register book + inkstone)
  - pouch.glb      (needle cloth pouch + brass compass + folded paper note for desk handover)
"""

import math
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(SCRIPT_DIR)
sys.path.insert(0, SCRIPT_DIR)

from glb_voxel_lib import (
    GlbBuilder,
    PaletteAtlas,
    VoxelGrid,
    build_box_primitive,
    clamp_u8,
    encode_png_rgba,
    euler_deg_to_quat,
    hex_rgb,
    resolve_deferred_uvs,
)

OUT_DIR = os.path.join(ROOT, "assets", "xiaoman3d")


def q(rx=0.0, ry=0.0, rz=0.0):
    return euler_deg_to_quat(rx, ry, rz)


def export_voxel_rig(filename: str, parts: dict, hierarchy: list, anims_fn,
                     mat_specs: dict, generator: str = "tools/build-xiaoman-props.py"):
    """Generic helper: builds palette atlas (2-pass UV safe), meshes, node tree, animations, and writes GLB."""
    atlas = PaletteAtlas(cell_px=4)
    part_prims = {k: g.build_primitives_deferred(atlas, bake_ao=True) for k, g in parts.items()}
    resolve_deferred_uvs(part_prims, atlas)

    glb = GlbBuilder(generator=generator)
    sampler = glb.add_sampler(mag=9728, min_f=9728, wrap_s=33071, wrap_t=33071)
    tex_pal = glb.add_png_texture(atlas.to_png(), sampler, name=filename + "_pal")

    mat_map = {}
    for mtag, spec in mat_specs.items():
        mat_map[mtag] = glb.add_material(
            spec["name"],
            base_color=spec.get("baseColor", (1.0, 1.0, 1.0, 1.0)),
            metallic=spec.get("metallic", 0.0),
            roughness=spec.get("roughness", 0.85),
            base_tex=tex_pal,
            emissive_tex=tex_pal if spec.get("emissive") else None,
            emissive_factor=spec.get("emissive"),
        )

    meshes = {}
    tris = 0
    for k, by_mat in part_prims.items():
        plist = [(prim, mat_map[mtag]) for mtag, prim in by_mat.items()]
        for prim, _ in plist:
            tris += len(prim["indices"]) // 3
        meshes[k] = glb.add_mesh("mesh_" + k, plist)

    nodes = {}
    for nname, mesh_key, trans, parent_name in hierarchy:
        parent_idx = nodes[parent_name] if parent_name is not None else None
        mesh_idx = meshes[mesh_key] if mesh_key is not None else None
        nodes[nname] = glb.add_node(nname, mesh=mesh_idx, translation=trans, parent=parent_idx)

    if anims_fn is not None:
        for aname, tracks in anims_fn(nodes):
            glb.add_animation(aname, tracks)

    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, filename)
    nb = glb.save(path)
    print(f"[prop3d] {filename:<15s} {nb:6d}B  {tris:4d} tris  mats={len(mat_map)} anims={len(glb.animations)}")


# ==================================================================== 1. Scavenger (Village)

def build_scavenger():
    vs = 0.030  # ~28 voxels tall = 0.84 m (matches scavenger.h = 82)
    COAT     = hex_rgb("#262422")
    COAT_SH  = hex_rgb("#191716")
    COAT_RIM = hex_rgb("#3F3B36")
    SACK     = hex_rgb("#4A3F32")
    SKIN_DK  = hex_rgb("#685446")
    BOOT     = hex_rgb("#2C221A")
    BOOT_RIM = hex_rgb("#786552")  # readable shoe rim & toe under table shadow!
    EYE_DIM  = hex_rgb("#E8A448")

    def g(ox, oy, oz): return VoxelGrid(vs, (ox * vs, oy * vs, oz * vs))

    torso = g(-3.5, 0.0, -2.5)
    torso.fill(0, 6, 0, 9, 0, 4, COAT)
    torso.paint_box(0, 6, 0, 1, 0, 4, COAT_SH)
    torso.paint_box(1, 5, 8, 9, 1, 3, COAT_RIM)
    # Cloth bundle slung on back (-Z)
    torso.fill(1, 5, 2, 7, -2, -1, SACK)
    torso.paint_box(1, 5, 6, 7, -2, -1, COAT_RIM)

    head = g(-2.5, 0.0, -2.5)
    head.fill(0, 4, 0, 4, 0, 4, COAT)
    head.paint_box(1, 3, 1, 3, 4, 4, SKIN_DK)
    head.set(1, 2, 4, EYE_DIM, "glow")
    head.set(3, 2, 4, EYE_DIM, "glow")
    head.paint_box(0, 4, 4, 4, 0, 4, COAT_RIM)  # hood rim

    arm_l = g(-1.0, -8.0, -1.0)
    arm_l.fill(0, 1, 1, 7, 0, 1, COAT)
    arm_l.fill(0, 1, 0, 0, 0, 1, SKIN_DK)

    arm_r = g(-1.0, -8.0, -1.0)
    arm_r.fill(0, 1, 1, 7, 0, 1, COAT)
    arm_r.fill(0, 1, 0, 0, 0, 1, SKIN_DK)

    def make_leg():
        lg = g(-1.5, -12.0, -1.5)
        lg.fill(0, 2, 3, 11, 0, 2, COAT_SH)
        lg.fill(0, 2, 0, 2, 0, 3, BOOT)        # prominent heavy boot extending +Z toe!
        lg.paint_box(0, 2, 0, 0, 0, 3, BOOT_RIM)  # bright sole rim for under-table shoe readability!
        lg.set(1, 1, 3, BOOT_RIM)              # toe tip highlight
        return lg

    parts = {"torso": torso, "head": head, "arm_L": arm_l, "arm_R": arm_r,
             "leg_L": make_leg(), "leg_R": make_leg()}
    hierarchy = [
        ("root", None, (0, 0, 0), None),
        ("pelvis", None, (0, 12.0 * vs, 0), "root"),
        ("torso", "torso", (0, 0, 0), "pelvis"),
        ("head", "head", (0, 9.6 * vs, 0.8 * vs), "torso"),
        ("arm_L", "arm_L", (-4.2 * vs, 8.2 * vs, 0), "torso"),
        ("arm_R", "arm_R", (4.2 * vs, 8.2 * vs, 0), "torso"),
        ("leg_L", "leg_L", (-1.8 * vs, 0, 0), "pelvis"),
        ("leg_R", "leg_R", (1.8 * vs, 0, 0), "pelvis"),
    ]

    def make_anims(nodes):
        out = []
        def clip(name, dur, n, fn):
            ts = [dur * i / (n - 1) for i in range(n)]
            mp = {}
            for i in range(n):
                for k, v in fn(i / (n - 1)).items():
                    mp.setdefault(k, []).append(v)
            out.append((name, [(nodes[nk], p, ts, vs_) for (nk, p), vs_ in mp.items()]))

        clip("idle", 2.0, 7, lambda u: {
            ("torso", "rotation"): q(14.0 + math.sin(u * 2 * math.pi) * 2.0, 0, 0),
            ("head", "rotation"): q(-8.0, math.sin(u * 2 * math.pi) * 6.0, 0),
            ("leg_L", "rotation"): q(0, 0, 0), ("leg_R", "rotation"): q(0, 0, 0),
            ("arm_L", "rotation"): q(-10, 0, 4), ("arm_R", "rotation"): q(-10, 0, -4),
        })
        clip("walk", 0.90, 9, lambda u: {
            ("pelvis", "translation"): (0, 12.0 * vs + abs(math.sin(u * 2 * math.pi)) * 0.015, 0),
            ("torso", "rotation"): q(18.0, -math.sin(u * 2 * math.pi) * 5.0, 0),
            ("head", "rotation"): q(-12.0, math.sin(u * 2 * math.pi) * 4.0, 0),
            ("leg_L", "rotation"): q(math.sin(u * 2 * math.pi) * 26.0, 0, 0),
            ("leg_R", "rotation"): q(-math.sin(u * 2 * math.pi) * 26.0, 0, 0),
            ("arm_L", "rotation"): q(-math.sin(u * 2 * math.pi) * 18.0 - 8.0, 0, 5),
            ("arm_R", "rotation"): q(math.sin(u * 2 * math.pi) * 18.0 - 8.0, 0, -5),
        })
        clip("turn", 0.55, 7, lambda u: {
            ("torso", "rotation"): q(10.0, math.sin(u * math.pi) * 16.0, 0),
            ("head", "rotation"): q(-10.0, math.sin(u * math.pi) * 34.0, 0),
            ("leg_L", "rotation"): q(0, 0, 0), ("leg_R", "rotation"): q(0, 0, 0),
            ("arm_L", "rotation"): q(-24 * math.sin(u * math.pi), 0, 10),
            ("arm_R", "rotation"): q(-24 * math.sin(u * math.pi), 0, -10),
        })
        clip("chase", 0.50, 9, lambda u: {
            ("pelvis", "translation"): (0, 12.0 * vs + abs(math.sin(u * 2 * math.pi)) * 0.025, 0),
            ("torso", "rotation"): q(26.0, -math.sin(u * 2 * math.pi) * 10.0, 0),
            ("head", "rotation"): q(-18.0, 0, 0),
            ("leg_L", "rotation"): q(math.sin(u * 2 * math.pi) * 42.0, 0, 0),
            ("leg_R", "rotation"): q(-math.sin(u * 2 * math.pi) * 42.0, 0, 0),
            ("arm_L", "rotation"): q(-math.sin(u * 2 * math.pi) * 38.0 - 20.0, 0, 10),
            ("arm_R", "rotation"): q(math.sin(u * 2 * math.pi) * 38.0 - 20.0, 0, -10),
        })
        return out

    export_voxel_rig("scavenger.glb", parts, hierarchy, make_anims, {
        "main": {"name": "M_scav_dark", "roughness": 0.90, "metallic": 0.0},
        "glow": {"name": "M_scav_eye", "roughness": 0.30, "emissive": (0.85, 0.55, 0.18)},
    })


# ==================================================================== 2. Forest Dog

def build_dog():
    vs = 0.024
    FUR     = hex_rgb("#24282E")
    FUR_DK  = hex_rgb("#16191E")
    FUR_RIM = hex_rgb("#48535E")  # cool moonlight rim on spine & pointed ears
    EYE     = hex_rgb("#F0A842")

    def g(ox, oy, oz): return VoxelGrid(vs, (ox * vs, oy * vs, oz * vs))

    body = g(-2.5, -2.0, -7.0)
    body.fill(0, 4, 0, 4, 0, 13, FUR)
    body.paint_box(1, 3, 4, 4, 1, 12, FUR_RIM)  # moonlit spine
    body.paint_box(0, 4, 0, 1, 2, 11, FUR_DK)

    head = g(-2.0, -1.5, 0.0)
    head.fill(0, 3, 0, 3, 0, 4, FUR)
    head.fill(1, 2, 0, 1, 5, 7, FUR_DK)         # snout
    head.set(0, 2, 4, EYE, "glow")
    head.set(3, 2, 4, EYE, "glow")

    ear = g(-0.5, 0.0, -0.5)
    ear.fill(0, 0, 0, 3, 0, 1, FUR)
    ear.set(0, 3, 0, FUR_RIM)                   # bright ear tip readable behind grass!
    ear.set(0, 2, 1, FUR_RIM)

    tail = g(-0.5, -0.5, -5.0)
    tail.fill(0, 0, 0, 0, 0, 4, FUR)
    tail.set(0, 0, 0, FUR_RIM)

    leg = g(-0.5, -7.0, -0.5)
    leg.fill(0, 1, 0, 6, 0, 1, FUR_DK)
    leg.paint_box(0, 1, 0, 0, 0, 1, FUR_RIM)

    parts = {
        "body": body, "head": head, "ear_L": ear, "ear_R": ear, "tail": tail,
        "leg_FL": leg, "leg_FR": leg, "leg_BL": leg, "leg_BR": leg,
    }
    hierarchy = [
        ("root", None, (0, 0, 0), None),
        ("body", "body", (0, 8.0 * vs, 0), "root"),
        ("head", "head", (0, 2.4 * vs, 6.6 * vs), "body"),
        ("ear_L", "ear_L", (-1.5 * vs, 2.5 * vs, 1.2 * vs), "head"),
        ("ear_R", "ear_R", (1.5 * vs, 2.5 * vs, 1.2 * vs), "head"),
        ("tail", "tail", (0, 1.8 * vs, -6.8 * vs), "body"),
        ("leg_FL", "leg_FL", (-1.6 * vs, -1.0 * vs, 4.6 * vs), "body"),
        ("leg_FR", "leg_FR", (1.6 * vs, -1.0 * vs, 4.6 * vs), "body"),
        ("leg_BL", "leg_BL", (-1.6 * vs, -1.0 * vs, -4.6 * vs), "body"),
        ("leg_BR", "leg_BR", (1.6 * vs, -1.0 * vs, -4.6 * vs), "body"),
    ]

    def make_anims(nodes):
        out = []
        def clip(name, dur, n, fn):
            ts = [dur * i / (n - 1) for i in range(n)]
            mp = {}
            for i in range(n):
                for k, v in fn(i / (n - 1)).items():
                    mp.setdefault(k, []).append(v)
            out.append((name, [(nodes[nk], p, ts, vs_) for (nk, p), vs_ in mp.items()]))

        clip("idle", 1.6, 7, lambda u: {
            ("head", "rotation"): q(math.sin(u * 2 * math.pi) * 4.0, 0, 0),
            ("ear_L", "rotation"): q(-10, 0, 12), ("ear_R", "rotation"): q(-10, 0, -12),
            ("tail", "rotation"): q(20, math.sin(u * 2 * math.pi) * 18, 0),
        })
        clip("walk", 0.60, 9, lambda u: {
            ("body", "translation"): (0, 8.0 * vs + abs(math.sin(u * 2 * math.pi)) * 0.012, 0),
            ("head", "rotation"): q(4, 0, 0),
            ("ear_L", "rotation"): q(-12, 0, 10), ("ear_R", "rotation"): q(-12, 0, -10),
            ("leg_FL", "rotation"): q(math.sin(u * 2 * math.pi) * 32, 0, 0),
            ("leg_BR", "rotation"): q(math.sin(u * 2 * math.pi) * 32, 0, 0),
            ("leg_FR", "rotation"): q(-math.sin(u * 2 * math.pi) * 32, 0, 0),
            ("leg_BL", "rotation"): q(-math.sin(u * 2 * math.pi) * 32, 0, 0),
        })
        clip("ear", 0.50, 7, lambda u: {
            ("head", "rotation"): q(-18, math.sin(u * math.pi) * 16, 0),
            ("ear_L", "rotation"): q(14, 0, 4), ("ear_R", "rotation"): q(14, 0, -4),  # sharp perked ears!
            ("tail", "rotation"): q(38, 0, 0),
        })
        clip("chase", 0.36, 9, lambda u: {
            ("body", "translation"): (0, 8.0 * vs + math.sin(u * 2 * math.pi) * 0.024, 0),
            ("body", "rotation"): q(math.cos(u * 2 * math.pi) * 8, 0, 0),
            ("head", "rotation"): q(-8, 0, 0),
            ("ear_L", "rotation"): q(-24, 0, 8), ("ear_R", "rotation"): q(-24, 0, -8),
            ("leg_FL", "rotation"): q(math.sin(u * 2 * math.pi) * 50, 0, 0),
            ("leg_FR", "rotation"): q(math.sin(u * 2 * math.pi + 0.5) * 50, 0, 0),
            ("leg_BL", "rotation"): q(-math.sin(u * 2 * math.pi) * 50, 0, 0),
            ("leg_BR", "rotation"): q(-math.sin(u * 2 * math.pi + 0.5) * 50, 0, 0),
        })
        clip("sniff", 1.1, 7, lambda u: {
            ("head", "rotation"): q(34 + math.sin(u * 4 * math.pi) * 8, math.sin(u * 2 * math.pi) * 14, 0),
            ("ear_L", "rotation"): q(-8, 0, 14), ("ear_R", "rotation"): q(-8, 0, -14),
        })
        return out

    export_voxel_rig("dog.glb", parts, hierarchy, make_anims, {
        "main": {"name": "M_dog_dark", "roughness": 0.88, "metallic": 0.0},
        "glow": {"name": "M_dog_eye", "roughness": 0.25, "emissive": (1.0, 0.45, 0.14)},
    })


# ==================================================================== 3. Tower Guard

def build_guard():
    vs = 0.030  # ~29 voxels = 0.87 m
    ROBE    = hex_rgb("#26313E")
    ROBE_DK = hex_rgb("#19212A")
    TRIM    = hex_rgb("#7A6E5E")
    SKIN    = hex_rgb("#B58F70")
    HAT     = hex_rgb("#1E2228")
    BOOT    = hex_rgb("#231D1A")

    def g(ox, oy, oz): return VoxelGrid(vs, (ox * vs, oy * vs, oz * vs))

    torso = g(-3.5, 0.0, -2.5)
    torso.fill(0, 6, 0, 10, 0, 4, ROBE)
    torso.paint_box(0, 6, 2, 2, 0, 4, TRIM)  # waist sash
    torso.paint_box(2, 4, 8, 10, 4, 4, TRIM)

    head = g(-2.5, 0.0, -2.5)
    head.fill(0, 4, 0, 4, 0, 4, SKIN)
    head.fill(-1, 5, 4, 5, -1, 5, HAT)       # Ming watchman cap

    arm = g(-1.0, -8.0, -1.0)
    arm.fill(0, 1, 1, 7, 0, 1, ROBE)
    arm.fill(0, 1, 0, 0, 0, 1, SKIN)

    leg = g(-1.5, -12.0, -1.5)
    leg.fill(0, 2, 2, 11, 0, 2, ROBE_DK)
    leg.fill(0, 2, 0, 1, 0, 2, BOOT)

    parts = {"torso": torso, "head": head, "arm_L": arm, "arm_R": arm, "leg_L": leg, "leg_R": leg}
    hierarchy = [
        ("root", None, (0, 0, 0), None),
        ("pelvis", None, (0, 12.0 * vs, 0), "root"),
        ("torso", "torso", (0, 0, 0), "pelvis"),
        ("head", "head", (0, 10.5 * vs, 0), "torso"),
        ("arm_L", "arm_L", (-4.2 * vs, 9.0 * vs, 0), "torso"),
        ("arm_R", "arm_R", (4.2 * vs, 9.0 * vs, 0), "torso"),
        ("leg_L", "leg_L", (-1.8 * vs, 0, 0), "pelvis"),
        ("leg_R", "leg_R", (1.8 * vs, 0, 0), "pelvis"),
    ]

    def make_anims(nodes):
        out = []
        def clip(name, dur, n, fn):
            ts = [dur * i / (n - 1) for i in range(n)]
            mp = {}
            for i in range(n):
                for k, v in fn(i / (n - 1)).items():
                    mp.setdefault(k, []).append(v)
            out.append((name, [(nodes[nk], p, ts, vs_) for (nk, p), vs_ in mp.items()]))

        clip("lantern", 2.0, 7, lambda u: {
            ("torso", "rotation"): q(4.0 + math.sin(u * 2 * math.pi) * 1.5, 0, 0),
            ("arm_R", "rotation"): q(-78.0 + math.sin(u * 2 * math.pi) * 4.0, 0, -6),
            ("arm_L", "rotation"): q(-12, 0, 6),
        })
        clip("write", 1.2, 7, lambda u: {
            ("torso", "rotation"): q(18.0, 0, 0),
            ("head", "rotation"): q(14.0, 0, 0),
            ("arm_R", "rotation"): q(-62.0 + math.sin(u * 4 * math.pi) * 8.0, 14.0, -8.0),
            ("arm_L", "rotation"): q(-54.0, -14.0, 8.0),
        })
        return out

    export_voxel_rig("guard.glb", parts, hierarchy, make_anims, {
        "main": {"name": "M_guard_dark", "roughness": 0.86, "metallic": 0.0},
    })


# ==================================================================== 4. Outside Red-Cloth Cart

def build_cart():
    # Matches rooms.ts: bodyW=48 (0.48m), bodyH=26 (0.26m), wheelR=12 (0.12m), handleOffset=+40 (+0.40m)
    vs = 0.025
    WOOD     = hex_rgb("#483525")
    WOOD_DK  = hex_rgb("#2C2016")
    IRON     = hex_rgb("#35393F")
    RED_CL   = hex_rgb("#B83228")   # iconic Ming patched red cloth (bright enough to read in night!)
    RED_HI   = hex_rgb("#DC4A3C")
    PATCH    = hex_rgb("#D8C29C")   # family stitched patch!

    def g(ox, oy, oz): return VoxelGrid(vs, (ox * vs, oy * vs, oz * vs))

    body = g(-10.0, 4.0, -6.0)
    # Bed floor (x=0..19 -> -0.25..+0.25m, z=0..11 -> -0.15..+0.15m)
    body.fill(0, 19, 0, 1, 0, 11, WOOD_DK)
    # Side wooden rails
    body.fill(0, 19, 2, 9, 0, 0, WOOD)
    body.fill(0, 19, 2, 9, 11, 11, WOOD)
    body.fill(0, 0, 2, 9, 0, 11, WOOD)
    body.fill(19, 19, 2, 9, 0, 11, WOOD)
    # Corner posts & iron brackets
    for px in (0, 19):
        for pz in (0, 11):
            body.paint_box(px, px, 2, 10, pz, pz, WOOD_DK)
            body.set(px, 2, pz, IRON, "iron")
            body.set(px, 9, pz, IRON, "iron")
    # Right-side (+X) pull handle beams extending to +0.40 m (x=20..26)
    body.fill(20, 26, 5, 6, 1, 2, WOOD)
    body.fill(20, 26, 5, 6, 9, 10, WOOD)
    body.fill(25, 26, 5, 6, 1, 10, PATCH)  # hand-worn bright handle bar!

    # Fixed left-end (-X) red cloth draped over left rim (never flips!)
    cloth = g(-1.0, -8.0, -4.0)
    cloth.fill(0, 1, 2, 8, 0, 7, RED_CL, "cloth")
    cloth.paint_box(0, 0, 5, 8, 1, 6, RED_HI, "cloth")
    cloth.carve(0, 1, 2, 3, 0, 1)
    cloth.carve(0, 1, 2, 2, 6, 7)
    cloth.set(0, 4, 3, PATCH, "cloth")  # mother's stitch patch
    cloth.set(0, 5, 4, PATCH, "cloth")

    # Wooden spoked wheel (radius ~0.12 m = 5 voxels)
    wheel = g(-4.5, -4.5, -0.5)
    for ix in range(9):
        for iy in range(9):
            d = math.hypot(ix - 4, iy - 4)
            if 3.2 <= d <= 4.4:
                wheel.set(ix, iy, 0, IRON if d >= 3.9 else WOOD_DK, "iron" if d >= 3.9 else "main")
            elif d <= 1.2 or ix == 4 or iy == 4:
                if d <= 3.4:
                    wheel.set(ix, iy, 0, WOOD)

    parts = {"body": body, "cloth": cloth, "wheel_F": wheel, "wheel_B": wheel}
    hierarchy = [
        ("root", None, (0, 0, 0), None),
        ("body", "body", (0, 0, 0), "root"),
        ("cloth", "cloth", (-0.255, 0.34, 0.0), "body"),
        ("wheel_F", "wheel_F", (0.0, 0.12, 0.165), "body"),
        ("wheel_B", "wheel_B", (0.0, 0.12, -0.165), "body"),
    ]

    def make_anims(nodes):
        ts = [0.0, 0.5, 1.0]
        return [
            ("idle", [(nodes["cloth"], "rotation", ts, [q(0, 0, -4), q(0, 0, 6), q(0, 0, -4)])]),
            ("roll", [
                (nodes["cloth"], "rotation", ts, [q(0, 0, -10), q(0, 0, 12), q(0, 0, -10)]),
                (nodes["wheel_F"], "rotation", [0.0, 0.25, 0.5, 0.75, 1.0],
                 [q(0, 0, 0), q(0, 0, -90), q(0, 0, -180), q(0, 0, -270), q(0, 0, -360)]),
                (nodes["wheel_B"], "rotation", [0.0, 0.25, 0.5, 0.75, 1.0],
                 [q(0, 0, 0), q(0, 0, -90), q(0, 0, -180), q(0, 0, -270), q(0, 0, -360)]),
            ]),
        ]

    export_voxel_rig("cart.glb", parts, hierarchy, make_anims, {
        "main":  {"name": "M_cart_wood", "roughness": 0.86, "metallic": 0.0},
        "iron":  {"name": "M_cart_iron", "roughness": 0.45, "metallic": 0.55},
        "cloth": {"name": "M_cart_red_cloth", "roughness": 0.78, "emissive": (0.22, 0.05, 0.04)},
    })


# ==================================================================== 5. Simple 3D Props

def build_simple_props():
    # ---- bottle.glb (coarse Ming clay bottle, ~0.12 m tall)
    vs = 0.018
    g = VoxelGrid(vs, (-2.0 * vs, 0.0, -2.0 * vs))
    CLAY = hex_rgb("#9E744C")
    CLAY_HI = hex_rgb("#C99E6E")
    CLAY_DK = hex_rgb("#64482E")
    g.fill(0, 3, 0, 3, 0, 3, CLAY)
    g.paint_box(0, 3, 0, 0, 0, 3, CLAY_DK)
    g.paint_box(1, 2, 3, 3, 1, 2, CLAY_HI)
    g.fill(1, 2, 4, 5, 1, 2, CLAY_HI)  # neck
    g.fill(1, 2, 6, 6, 1, 2, CLAY_DK)  # rim
    export_voxel_rig("bottle.glb", {"bottle": g}, [("root", "bottle", (0, 0, 0), None)], None, {
        "main": {"name": "M_bottle_clay", "roughness": 0.78, "emissive": (0.14, 0.10, 0.06)},
    })

    # ---- basin.glb (village hammered iron washbasin, diameter ~0.38 m, height 0.11 m)
    vs = 0.028
    g = VoxelGrid(vs, (-7.0 * vs, 0.0, -7.0 * vs))
    IRON_DK = hex_rgb("#262D36")
    IRON_RIM = hex_rgb("#889AA8")  # moonlight glinting rim!
    for ix in range(14):
        for iz in range(14):
            d = math.hypot(ix - 6.5, iz - 6.5)
            if d <= 5.8:
                g.set(ix, 0, iz, IRON_DK)
            if 4.6 <= d <= 6.4:
                g.set(ix, 1, iz, IRON_DK)
                g.set(ix, 2, iz, IRON_DK)
                g.set(ix, 3, iz, IRON_RIM)  # bright rim readable in dark!
    export_voxel_rig("basin.glb", {"basin": g}, [("root", "basin", (0, 0, 0), None)], None, {
        "main": {"name": "M_basin_iron", "roughness": 0.34, "metallic": 0.62, "emissive": (0.06, 0.08, 0.10)},
    })

    # ---- door.glb (North Tower heavy timber door hinged at left edge x=0 -> width 0.34 m, height 1.14 m)
    vs = 0.030
    g = VoxelGrid(vs, (0.0, 0.0, -1.0 * vs))
    DOOR_W = hex_rgb("#35261B")
    DOOR_DK = hex_rgb("#211710")
    BAND = hex_rgb("#30363E")
    KNOCK = hex_rgb("#C9A058")
    g.fill(0, 10, 0, 37, 0, 1, DOOR_W)
    for x in (0, 5, 10):
        g.paint_box(x, x, 0, 37, 0, 1, DOOR_DK)
    for y in (5, 18, 32):
        g.paint_box(0, 10, y, y + 1, 0, 1, BAND, "iron")
    # Brass/iron door knockers on both faces around y = 0.54 m
    g.fill(6, 7, 16, 17, 2, 2, KNOCK, "brass")
    g.fill(6, 7, 16, 17, -1, -1, KNOCK, "brass")
    export_voxel_rig("door.glb", {"door": g}, [("root", "door", (0, 0, 0), None)], None, {
        "main":  {"name": "M_tower_door_wood", "roughness": 0.86},
        "iron":  {"name": "M_tower_door_iron", "roughness": 0.45, "metallic": 0.55},
        "brass": {"name": "M_tower_door_ring", "roughness": 0.35, "metallic": 0.65, "emissive": (0.20, 0.14, 0.05)},
    })

    # ---- lantern.glb (Warm Ming paper lantern, ~0.24 m tall)
    vs = 0.020
    g = VoxelGrid(vs, (-3.0 * vs, 0.0, -3.0 * vs))
    FRAME = hex_rgb("#2B1E16")
    PAPER = hex_rgb("#FFE096")
    CORE  = hex_rgb("#FFF6D2")
    g.fill(0, 5, 0, 1, 0, 5, FRAME)
    g.fill(0, 5, 9, 10, 0, 5, FRAME)
    g.fill(1, 4, 11, 12, 1, 4, FRAME)
    g.fill(1, 4, 2, 8, 1, 4, PAPER, "glow")
    g.paint_box(2, 3, 4, 6, 1, 4, CORE, "glow")
    for cx in (0, 5):
        for cz in (0, 5):
            g.fill(cx, cx, 2, 8, cz, cz, FRAME)
    export_voxel_rig("lantern.glb", {"lantern": g}, [("root", "lantern", (0, 0, 0), None)], None, {
        "main": {"name": "M_lantern_frame", "roughness": 0.82},
        "glow": {"name": "M_lantern_paper", "roughness": 0.40, "emissive": (1.0, 0.78, 0.38)},
    })

    # ---- ledger.glb (North Tower desk register book + inkstone)
    vs = 0.018
    g = VoxelGrid(vs, (-7.0 * vs, 0.0, -4.5 * vs))
    PAPER_BOOK = hex_rgb("#E8DEC4")
    INK_LINE   = hex_rgb("#3A352E")
    COVER      = hex_rgb("#3E3228")
    INKSTONE   = hex_rgb("#1E2228")
    g.fill(0, 13, 0, 0, 0, 8, COVER)
    g.fill(1, 12, 1, 1, 1, 7, PAPER_BOOK)
    g.fill(6, 7, 1, 1, 1, 7, COVER)      # spine fold
    g.fill(2, 5, 1, 1, 3, 3, INK_LINE)   # first written row
    g.fill(15, 17, 0, 1, 2, 5, INKSTONE) # inkstone beside book
    export_voxel_rig("ledger.glb", {"ledger": g}, [("root", "ledger", (0, 0, 0), None)], None, {
        "main": {"name": "M_desk_ledger", "roughness": 0.85, "emissive": (0.14, 0.12, 0.09)},
    })

    # ---- pouch.glb (Needle cloth pouch + brass compass + white folded note placed on desk)
    vs = 0.016
    g = VoxelGrid(vs, (-5.0 * vs, 0.0, -3.0 * vs))
    POUCH = hex_rgb("#C94B3A")
    GOLD  = hex_rgb("#F6C958")
    NOTE  = hex_rgb("#F5EFE0")
    g.fill(0, 3, 0, 1, 1, 4, POUCH)
    g.fill(5, 7, 0, 1, 1, 3, GOLD, "brass")
    g.fill(4, 9, 0, 0, 4, 6, NOTE)
    export_voxel_rig("pouch.glb", {"pouch": g}, [("root", "pouch", (0, 0, 0), None)], None, {
        "main":  {"name": "M_pouch_cloth", "roughness": 0.80, "emissive": (0.18, 0.12, 0.10)},
        "brass": {"name": "M_pouch_compass", "roughness": 0.32, "metallic": 0.55, "emissive": (0.42, 0.32, 0.12)},
    })

    # ---- latch.glb (Outside arch-blocking iron & dark timber crossbar, unit width 0.48m x 0.44m)
    vs = 0.040
    g = VoxelGrid(vs, (-6.0 * vs, 0.0, -0.5 * vs))
    TIMBER = hex_rgb("#2A211A")
    IRON_B = hex_rgb("#4E5660")
    g.fill(0, 11, 9, 10, 0, 0, TIMBER)    # horizontal blocking bar at y=0.36..0.44
    g.fill(0, 11, 10, 10, 0, 0, IRON_B, "iron")
    g.fill(0, 0, 0, 10, 0, 0, TIMBER)     # left post
    g.fill(11, 11, 0, 10, 0, 0, TIMBER)   # right post
    g.fill(5, 6, 11, 22, 0, 0, IRON_B, "iron")  # vertical link rod up to cart axle
    export_voxel_rig("latch.glb", {"latch": g}, [("root", "latch", (0, 0, 0), None)], None, {
        "main": {"name": "M_latch_wood", "roughness": 0.88},
        "iron": {"name": "M_latch_iron", "roughness": 0.44, "metallic": 0.55, "emissive": (0.06, 0.06, 0.07)},
    })

    # ---- grass.glb (Forest dark tall grass cluster, ~0.80 m wide x 0.30 m tall, clear silhouette!)
    vs = 0.025
    g = VoxelGrid(vs, (-16.0 * vs, 0.0, -3.0 * vs))
    G1 = hex_rgb("#1B2D26")
    G2 = hex_rgb("#284237")
    G_RIM = hex_rgb("#486B5D")
    for i in range(16):
        bx = i * 2
        bz = (i * 3) % 5
        bh = 6 + (i * 5) % 6
        g.fill(bx, bx, 0, bh, bz, bz, G1 if (i % 2) else G2)
        g.set(bx, bh, bz, G_RIM)
        if bh >= 9:
            g.set(bx + 1, bh - 1, bz, G2)
    export_voxel_rig("grass.glb", {"grass": g}, [("root", "grass", (0, 0, 0), None)], None, {
        "main": {"name": "M_forest_grass", "roughness": 0.90},
    })

    # ---- twig.glb (Forest dry snapping twigs bundle on trail)
    vs = 0.020
    g = VoxelGrid(vs, (-6.0 * vs, 0.0, -4.0 * vs))
    TW = hex_rgb("#644E38")
    TW_HI = hex_rgb("#8C7254")
    for k in range(10):
        g.set(k + 1, 0, (k // 2) + 1, TW)
    for k in range(8):
        g.set(k + 2, 1 if k in (3, 4) else 0, 7 - (k // 2), TW_HI)
    export_voxel_rig("twig.glb", {"twig": g}, [("root", "twig", (0, 0, 0), None)], None, {
        "main": {"name": "M_forest_twig", "roughness": 0.86, "emissive": (0.08, 0.06, 0.04)},
    })

    # ---- bough.glb (Forest creek overhanging dark pine bough that parts as player walks onto bank)
    vs = 0.060
    g = VoxelGrid(vs, (-12.0 * vs, -8.0 * vs, -1.0 * vs))
    BARK = hex_rgb("#181310")
    PINE = hex_rgb("#13231E")
    PINE_R = hex_rgb("#263D36")
    g.fill(0, 22, 6, 7, 0, 1, BARK)
    for bx in range(1, 22, 2):
        drop = 2 + (bx * 3) % 5
        g.fill(bx, bx + 1, 6 - drop, 6, 0, 1, PINE)
        g.set(bx, 6 - drop, 1, PINE_R)
    export_voxel_rig("bough.glb", {"bough": g}, [("root", "bough", (0, 0, 0), None)], None, {
        "main": {"name": "M_forest_bough", "roughness": 0.92},
    })

    # ---- sky_backdrop.glb (Dark realistic cold midnight sky + distant mountain ridges + faint North Tower lamp)
    w, h = 256, 128
    px = bytearray(w * h * 4)
    for py in range(h):
        v = py / (h - 1)  # 0=top sky, 1=bottom horizon
        # Midnight indigo-slate gradient
        r = 7 + 16 * (v ** 1.6)
        g_ = 11 + 22 * (v ** 1.5)
        b = 19 + 30 * (v ** 1.4)
        for px_i in range(w):
            u = px_i / (w - 1)
            # Cold moon around (0.76, 0.22)
            md = math.hypot((u - 0.76) * 2.0, (v - 0.22))
            if md < 0.055:
                r, g_, b = 188, 206, 226
            elif md < 0.28:
                glow = max(0.0, 1.0 - md / 0.28) ** 2.2
                r += 42 * glow
                g_ += 56 * glow
                b += 74 * glow
            # Distant ridge silhouette
            ridge_y = 0.60 - 0.10 * math.sin(u * 5.2 + 0.4) - 0.05 * math.sin(u * 13.0)
            if v > ridge_y:
                fog = min(1.0, (v - ridge_y) / 0.22)
                r = 10 + 10 * fog
                g_ = 14 + 13 * fog
                b = 20 + 17 * fog
            # Distant North Tower silhouette + warm pinpoint lamp at u=0.84, v=0.49
            if abs(u - 0.84) < 0.014 and 0.44 <= v <= 0.62:
                r, g_, b = 14, 17, 22
            ld = math.hypot((u - 0.84) * 2.0, v - 0.49)
            if ld < 0.012:
                r, g_, b = 255, 228, 156
            elif ld < 0.09:
                lg = (1.0 - ld / 0.09) ** 2.4
                r += 140 * lg
                g_ += 96 * lg
                b += 38 * lg
            o = (py * w + px_i) * 4
            px[o] = clamp_u8(r)
            px[o + 1] = clamp_u8(g_)
            px[o + 2] = clamp_u8(b)
            px[o + 3] = 255
    sky_png = encode_png_rgba(w, h, px)
    glb = GlbBuilder(generator="tools/build-xiaoman-props.py")
    samp = glb.add_sampler(mag=9729, min_f=9729, wrap_s=33071, wrap_t=33071)
    tex = glb.add_png_texture(sky_png, samp, name="sky_night")
    mat = glb.add_material("M_sky_night", base_color=(1, 1, 1, 1), metallic=0.0, roughness=1.0,
                           base_tex=tex, emissive_tex=tex, emissive_factor=(0.92, 0.94, 0.98))
    # Wide quad 26m x 11m facing +Z, centered at x=0, y=2.6
    hw, y0, y1 = 13.0, -1.5, 9.5
    prim = {
        "positions": [-hw, y0, 0.0,  hw, y0, 0.0,  hw, y1, 0.0,  -hw, y1, 0.0],
        "normals":   [0, 0, 1,  0, 0, 1,  0, 0, 1,  0, 0, 1],
        "uvs":       [0.0, 1.0,  1.0, 1.0,  1.0, 0.0,  0.0, 0.0],
        "tangents":  [1, 0, 0, 1,  1, 0, 0, 1,  1, 0, 0, 1,  1, 0, 0, 1],
        "indices":   [0, 1, 2, 0, 2, 3],
    }
    mesh = glb.add_mesh("sky_quad", [(prim, mat)])
    glb.add_node("sky", mesh=mesh)
    nb = glb.save(os.path.join(OUT_DIR, "sky_backdrop.glb"))
    print(f"[prop3d] sky_backdrop.glb {nb:6d}B     2 tris  mats=1 anims=0")


def main():
    build_scavenger()
    build_dog()
    build_guard()
    build_cart()
    build_simple_props()


if __name__ == "__main__":
    main()
