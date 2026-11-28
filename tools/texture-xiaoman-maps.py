#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Upgrade TQYM's 4 Xiaoman-line room GLBs with world-scale box UVs, tangents, and dark-realistic Ming PBR textures.

Idempotent & geometry-preserving:
- Reads existing assets/xiaoman3d/{outside,village,forest,tower}.glb (keeping exact TQYM geometry & coordinates).
- Splits indexed meshes into crisp flat-normal triangles with world-scale box-projected TEXCOORD_0 + TANGENT.
- Generates deterministic, tileable 128x128 dark-realistic Ming PBR maps (BaseColor + Normal + MetallicRoughness)
  for all 8 material slots (M_xm3d_stone, stone_dark, wood, wood_dark, plaster, earth, metal, void).
- Adds subtle per-room atmospheric tinting (cold wet outside masonry, moonlit village brick, mossy dark forest,
  solemn north tower stonework) so bright voxel Xiaoman pops dramatically against the dark realistic environment.

Usage:
    python3 tools/texture-xiaoman-maps.py
"""

import json
import math
import os
import struct
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(SCRIPT_DIR)
sys.path.insert(0, SCRIPT_DIR)

from glb_voxel_lib import GlbBuilder, clamp_u8, encode_png_rgba

ASSET_DIR = os.path.join(ROOT, "assets", "xiaoman3d")
ROOMS = ("outside", "village", "forest", "tower")

# ---------------------------------------------------------------- Deterministic Noise

def _hash2(ix: int, iy: int, seed: int) -> float:
    n = (ix * 374761393 + iy * 668265263 + seed * 1442695041) & 0xFFFFFFFF
    n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
    return ((n ^ (n >> 16)) & 0xFFFFFF) / 16777216.0


def _tile_noise(u: float, v: float, period: int, seed: int) -> float:
    x = (u % 1.0) * period
    y = (v % 1.0) * period
    x0 = int(math.floor(x)) % period
    y0 = int(math.floor(y)) % period
    x1 = (x0 + 1) % period
    y1 = (y0 + 1) % period
    fx = x - math.floor(x)
    fy = y - math.floor(y)
    sx = fx * fx * (3.0 - 2.0 * fx)
    sy = fy * fy * (3.0 - 2.0 * fy)
    n00 = _hash2(x0, y0, seed)
    n10 = _hash2(x1, y0, seed)
    n01 = _hash2(x0, y1, seed)
    n11 = _hash2(x1, y1, seed)
    nx0 = n00 + (n10 - n00) * sx
    nx1 = n01 + (n11 - n01) * sx
    return nx0 + (nx1 - nx0) * sy


def _fbm(u: float, v: float, base_p: int, seed: int) -> float:
    val = 0.0
    amp = 0.55
    p = base_p
    for o in range(3):
        val += amp * _tile_noise(u, v, p, seed + o * 31)
        p *= 2
        amp *= 0.48
    return val / 0.945


# ---------------------------------------------------------------- Dark Realistic PBR Texture Synthesis

def make_pbr_maps(mat_name: str, room: str, size: int = 128):
    """Synthesize (albedo_png, normal_png, mr_png) for a dark-realistic Ming architectural material."""
    albedo = bytearray(size * size * 4)
    mr = bytearray(size * size * 4)  # glTF: G=roughness, B=metallic
    height = [0.0] * (size * size)

    # Room-specific subtle mood shift
    room_tint = {
        "outside": (0.94, 0.98, 1.06),
        "village": (0.96, 0.98, 1.04),
        "forest":  (0.86, 0.96, 0.92),
        "tower":   (0.95, 0.96, 1.02),
    }[room]

    for py in range(size):
        v = py / size
        for px in range(size):
            u = px / size
            idx = py * size + px
            o = idx * 4

            if mat_name in ("M_xm3d_stone", "M_xm3d_stone_dark"):
                dark = (mat_name == "M_xm3d_stone_dark")
                # Weathered Ming grey brick courses (6 rows x 3 bricks per meter)
                row = int(v * 6.0)
                rv = (v * 6.0) - row
                bu = (u * 3.0 + (0.5 if (row % 2) else 0.0)) % 1.0
                brick_id = int((u * 3.0 + (0.5 if (row % 2) else 0.0))) % 3
                mortar = (rv < 0.085 or rv > 0.945 or bu < 0.055 or bu > 0.96)
                grain = _fbm(u, v, 8, 101 + (17 if dark else 0))
                moss = _fbm(u, v, 4, 211)
                brick_var = (_hash2(brick_id, row, 77) - 0.5) * 14.0

                if dark:
                    br, bg, bb = 34, 38, 46
                else:
                    br, bg, bb = (56, 62, 72) if room == "village" else (48, 53, 61)

                if mortar:
                    r, g, b = br * 0.44, bg * 0.46, bb * 0.50
                    h = 0.15 + grain * 0.15
                    rough = 0.95
                else:
                    # Slight bright edge bevel on village hard brick for readability in moonlight
                    bevel = 1.12 if (not dark and (rv < 0.14 or bu < 0.10)) else 1.0
                    shade = (0.78 + grain * 0.42) * bevel
                    r = (br + brick_var) * shade
                    g = (bg + brick_var) * shade
                    b = (bb + brick_var) * shade
                    if room == "forest" and moss > 0.62:
                        m = (moss - 0.62) * 1.4
                        r = r * (1 - m) + 26 * m
                        g = g * (1 - m) + 44 * m
                        b = b * (1 - m) + 34 * m
                    h = 0.65 + grain * 0.30
                    rough = 0.72 + grain * 0.20 - (0.14 if moss > 0.65 else 0.0)
                metal = 0.04

            elif mat_name in ("M_xm3d_wood", "M_xm3d_wood_dark"):
                dark = (mat_name == "M_xm3d_wood_dark")
                plank = int(v * 5.0)
                pv = (v * 5.0) - plank
                seam = (pv < 0.06 or pv > 0.96)
                fiber = _tile_noise(u, v * 0.25, 16, 307 + plank * 13) * 0.6 + _fbm(u, v * 4.0, 4, 331) * 0.4
                pvar = (_hash2(plank, 3, 41) - 0.5) * 10.0
                br, bg, bb = (32, 24, 19) if dark else (58, 44, 31)
                if seam:
                    r, g, b = br * 0.42, bg * 0.40, bb * 0.40
                    h = 0.20
                    rough = 0.95
                else:
                    s = 0.74 + fiber * 0.46
                    r, g, b = (br + pvar) * s, (bg + pvar) * s, (bb + pvar) * s
                    h = 0.58 + fiber * 0.34
                    rough = 0.78 + (1.0 - fiber) * 0.16
                metal = 0.0

            elif mat_name == "M_xm3d_plaster":
                n1 = _fbm(u, v, 6, 409)
                n2 = _fbm(u, v, 12, 433)
                peel = n1 < 0.33
                if peel:
                    r, g, b = 46 * (0.8 + n2 * 0.3), 40 * (0.8 + n2 * 0.3), 36 * (0.8 + n2 * 0.3)
                    h = 0.35 + n2 * 0.2
                    rough = 0.92
                else:
                    s = 0.78 + n1 * 0.32 + (n2 - 0.5) * 0.12
                    r, g, b = 62 * s, 64 * s, 68 * s
                    h = 0.72 + n2 * 0.16
                    rough = 0.86 + n2 * 0.10
                metal = 0.0

            elif mat_name == "M_xm3d_earth":
                n1 = _fbm(u, v, 8, 503)
                peb = _tile_noise(u, v, 24, 541)
                if room == "forest":
                    br, bg, bb = 30, 39, 32
                else:
                    br, bg, bb = 38, 35, 31
                s = 0.72 + n1 * 0.44 + (peb - 0.5) * 0.18
                r, g, b = br * s, bg * s, bb * s
                h = 0.45 + n1 * 0.35 + peb * 0.20
                rough = 0.88 + peb * 0.10
                metal = 0.0

            elif mat_name == "M_xm3d_metal":
                # In forest, M_xm3d_metal is used for creek/canal water + stone lantern hood;
                # elsewhere it is oxidized iron (culvert rim, iron basin, fixtures).
                if room == "forest":
                    rip = math.sin((v * 8.0 + _fbm(u, v, 4, 601) * 1.4) * 2.0 * math.pi) * 0.5 + 0.5
                    s = 0.72 + rip * 0.55
                    r, g, b = 26 * s, 44 * s, 52 * s
                    h = 0.40 + rip * 0.45
                    rough = 0.22 + (1.0 - rip) * 0.18
                    metal = 0.35
                else:
                    n = _fbm(u, v, 10, 653)
                    s = 0.72 + n * 0.48
                    r, g, b = 46 * s, 52 * s, 60 * s
                    h = 0.50 + n * 0.35
                    rough = 0.38 + (1.0 - n) * 0.24
                    metal = 0.55

            else:  # M_xm3d_void
                n = _fbm(u, v, 6, 701)
                r, g, b = 10 + n * 6, 11 + n * 6, 14 + n * 8
                h = 0.5
                rough = 0.98
                metal = 0.0

            albedo[o]     = clamp_u8(r * room_tint[0])
            albedo[o + 1] = clamp_u8(g * room_tint[1])
            albedo[o + 2] = clamp_u8(b * room_tint[2])
            albedo[o + 3] = 255

            mr[o]     = 255
            mr[o + 1] = clamp_u8(rough * 255.0)
            mr[o + 2] = clamp_u8(metal * 255.0)
            mr[o + 3] = 255
            height[idx] = h

    # Compute tangent-space normal map from tileable heightfield via Sobel-like gradient
    normal = bytearray(size * size * 4)
    strength = 2.4 if mat_name != "M_xm3d_void" else 0.0
    for py in range(size):
        ym = (py - 1) % size
        yp = (py + 1) % size
        for px in range(size):
            xm = (px - 1) % size
            xp = (px + 1) % size
            dx = (height[py * size + xp] - height[py * size + xm]) * strength
            dy = (height[yp * size + px] - height[ym * size + px]) * strength
            nx, ny, nz = -dx, -dy, 1.0
            inv = 1.0 / math.sqrt(nx * nx + ny * ny + nz * nz)
            o = (py * size + px) * 4
            normal[o]     = clamp_u8((nx * inv * 0.5 + 0.5) * 255.0)
            normal[o + 1] = clamp_u8((ny * inv * 0.5 + 0.5) * 255.0)
            normal[o + 2] = clamp_u8((nz * inv * 0.5 + 0.5) * 255.0)
            normal[o + 3] = 255

    return (
        encode_png_rgba(size, size, albedo),
        encode_png_rgba(size, size, normal),
        encode_png_rgba(size, size, mr),
    )


# ---------------------------------------------------------------- GLB Reader & Box-UV Rebuilder

def read_glb(path: str):
    with open(path, "rb") as f:
        data = f.read()
    magic, ver, length = struct.unpack_from("<4sII", data, 0)
    assert magic == b"glTF" and ver == 2, f"Invalid GLB: {path}"
    jlen, jtype = struct.unpack_from("<I4s", data, 12)
    assert jtype == b"JSON"
    gltf = json.loads(data[20:20 + jlen].decode("utf-8"))
    boff = 20 + jlen
    blen, btype = struct.unpack_from("<I4s", data, boff)
    assert btype == b"BIN\x00"
    bin_chunk = data[boff + 8:boff + 8 + blen]
    return gltf, bin_chunk


def read_accessor(gltf, bin_chunk, acc_idx: int):
    acc = gltf["accessors"][acc_idx]
    bv = gltf["bufferViews"][acc["bufferView"]]
    offset = bv.get("byteOffset", 0) + acc.get("byteOffset", 0)
    count = acc["count"]
    ctype = acc["componentType"]
    atype = acc["type"]
    fmt_char = {5120: "b", 5121: "B", 5122: "h", 5123: "H", 5125: "I", 5126: "f"}[ctype]
    ncomp = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}[atype]
    comp_size = struct.calcsize("<" + fmt_char)
    stride = bv.get("byteStride", comp_size * ncomp)
    out = []
    for i in range(count):
        base = offset + i * stride
        vals = struct.unpack_from(f"<{ncomp}{fmt_char}", bin_chunk, base)
        out.append(vals[0] if ncomp == 1 else vals)
    return out


def box_uv_and_tangent(p, n, tile_scale: float = 0.85):
    """World-space triplanar/box UV projection + orthogonal tangent for a vertex (x,y,z) and normal (nx,ny,nz)."""
    ax, ay, az = abs(n[0]), abs(n[1]), abs(n[2])
    if ay >= ax and ay >= az:
        # Horizontal floor / ceiling -> project XZ
        u = p[0] * tile_scale
        v = p[2] * tile_scale
        tang = (1.0, 0.0, 0.0, 1.0)
    elif ax >= az:
        # Side wall (±X normal) -> project ZY
        u = (-p[2] if n[0] >= 0 else p[2]) * tile_scale
        v = -p[1] * tile_scale
        tang = (0.0, 0.0, -1.0 if n[0] >= 0 else 1.0, 1.0)
    else:
        # Front/back wall (±Z normal) -> project XY
        u = (p[0] if n[2] >= 0 else -p[0]) * tile_scale
        v = -p[1] * tile_scale
        tang = (1.0 if n[2] >= 0 else -1.0, 0.0, 0.0, 1.0)
    return (u, v), tang


def process_room(room: str):
    path = os.path.join(ASSET_DIR, f"{room}.glb")
    gltf, bin_chunk = read_glb(path)

    old_mats = gltf.get("materials", [])
    old_meshes = gltf.get("meshes", [])
    old_nodes = gltf.get("nodes", [])

    glb = GlbBuilder(generator="tools/texture-xiaoman-maps.py")
    sampler_repeat = glb.add_sampler(mag=9729, min_f=9729, wrap_s=10497, wrap_t=10497)

    # Build dark-realistic PBR material for every slot in this room
    new_mat_map = {}
    for m_idx, m in enumerate(old_mats):
        mname = m.get("name", f"M_xm3d_stone")
        alb_png, nrm_png, mr_png = make_pbr_maps(mname, room, size=128)
        t_alb = glb.add_png_texture(alb_png, sampler_repeat, name=f"{room}_{mname}_alb")
        t_nrm = glb.add_png_texture(nrm_png, sampler_repeat, name=f"{room}_{mname}_nrm")
        t_mr  = glb.add_png_texture(mr_png, sampler_repeat, name=f"{room}_{mname}_mr")
        # Slight cold shimmer emissive only on forest water (metal) so creek water catches night light
        emissive = (0.04, 0.07, 0.08) if (room == "forest" and mname == "M_xm3d_metal") else None
        new_mat_map[m_idx] = glb.add_material(
            mname,
            base_color=(1.0, 1.0, 1.0, 1.0),
            metallic=1.0,
            roughness=1.0,
            base_tex=t_alb,
            normal_tex=t_nrm,
            mr_tex=t_mr,
            emissive_tex=t_alb if emissive else None,
            emissive_factor=emissive,
        )

    # Rebuild each mesh keeping exact vertex positions & outward normals, adding box-projected UVs + tangents
    new_mesh_map = {}
    total_tris = 0
    for mesh_idx, mesh in enumerate(old_meshes):
        prims_out = []
        for prim in mesh.get("primitives", []):
            attrs = prim["attributes"]
            positions = read_accessor(gltf, bin_chunk, attrs["POSITION"])
            normals = read_accessor(gltf, bin_chunk, attrs["NORMAL"]) if "NORMAL" in attrs else None
            if "indices" in prim:
                indices = read_accessor(gltf, bin_chunk, prim["indices"])
            else:
                indices = list(range(len(positions)))

            old_m_idx = prim.get("material", 0)
            mname = old_mats[old_m_idx].get("name", "") if old_m_idx < len(old_mats) else ""
            tscale = 0.72 if "wood" in mname else (0.95 if "stone" in mname else 0.85)

            out_pos, out_nrm, out_uv, out_tng, out_idx = [], [], [], [], []
            # Unroll triangles so every face gets clean flat normal & seam-free box UV
            for t in range(0, len(indices), 3):
                i0, i1, i2 = indices[t], indices[t + 1], indices[t + 2]
                p0, p1, p2 = positions[i0], positions[i1], positions[i2]
                # Compute geometric face normal (ensures exact box projection axis!)
                e1 = (p1[0] - p0[0], p1[1] - p0[1], p1[2] - p0[2])
                e2 = (p2[0] - p0[0], p2[1] - p0[1], p2[2] - p0[2])
                fnx = e1[1] * e2[2] - e1[2] * e2[1]
                fny = e1[2] * e2[0] - e1[0] * e2[2]
                fnz = e1[0] * e2[1] - e1[1] * e2[0]
                flen = math.sqrt(fnx * fnx + fny * fny + fnz * fnz)
                if flen < 1e-10:
                    continue
                fn = (fnx / flen, fny / flen, fnz / flen)
                base = len(out_pos) // 3
                for vi, vp in ((i0, p0), (i1, p1), (i2, p2)):
                    vn = normals[vi] if normals is not None else fn
                    uv, tang = box_uv_and_tangent(vp, fn, tscale)
                    out_pos.extend(vp)
                    out_nrm.extend(vn)
                    out_uv.extend(uv)
                    out_tng.extend(tang)
                out_idx.extend((base, base + 1, base + 2))
                total_tris += 1

            prims_out.append((
                {"positions": out_pos, "normals": out_nrm, "uvs": out_uv, "tangents": out_tng, "indices": out_idx},
                new_mat_map[old_m_idx],
            ))
        new_mesh_map[mesh_idx] = glb.add_mesh(mesh.get("name", f"{room}_mesh_{mesh_idx}"), prims_out)

    for node in old_nodes:
        glb.add_node(
            node.get("name", "node"),
            mesh=new_mesh_map[node["mesh"]] if "mesh" in node else None,
            translation=node.get("translation"),
            rotation=node.get("rotation"),
            scale=node.get("scale"),
        )

    nbytes = glb.save(path)
    print(f"[map-pbr] {room:<8s} {nbytes:7d}B  {total_tris:4d} tris  mats={len(new_mat_map)} (128px dark PBR + UV + TBN)")


def main():
    for room in ROOMS:
        process_room(room)


if __name__ == "__main__":
    main()
