#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Zero-dependency pure-Python glTF 2.0 (.glb) & PNG builder for Xiaoman 3D voxel/lowpoly assets.

Features:
- Pure stdlib PNG writer (RGBA/RGB) using zlib + struct
- VoxelGrid with exposed-face culling, subtle per-face & corner-AO palette baking, and crisp solid-swatch UVs
- Rigid hierarchical glTF 2.0 node tree with named socket nodes (for Dora Model3D.attachToNode)
- glTF 2.0 keyframe animations (translation, rotation quaternions with hemisphere continuity, scale)
- Embedded PNG textures (BaseColor, Emissive, Normal, MetallicRoughness) with NEAREST / LINEAR samplers
"""

import json
import math
import struct
import zlib

# ==================================================================== PNG Encoder

def _png_chunk(tag: bytes, data: bytes) -> bytes:
    crc = zlib.crc32(tag + data) & 0xFFFFFFFF
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)


def encode_png_rgba(width: int, height: int, pixels) -> bytes:
    """Encode a width*height list/flat-bytes of RGBA (0..255) into PNG bytes.
    pixels: either bytes/bytearray of length width*height*4 (row-major top-to-bottom),
            or a list of (r, g, b, a) tuples of length width*height.
    """
    if isinstance(pixels, (bytes, bytearray)):
        raw_bytes = bytes(pixels)
    else:
        buf = bytearray(width * height * 4)
        idx = 0
        for r, g, b, a in pixels:
            buf[idx] = r & 255
            buf[idx + 1] = g & 255
            buf[idx + 2] = b & 255
            buf[idx + 3] = a & 255
            idx += 4
        raw_bytes = bytes(buf)

    stride = width * 4
    scanlines = bytearray()
    for y in range(height):
        scanlines.append(0)  # Filter type 0 (None)
        row_start = y * stride
        scanlines.extend(raw_bytes[row_start:row_start + stride])

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    idat = zlib.compress(bytes(scanlines), level=6)
    return (
        b"\x89PNG\r\n\x1a\n"
        + _png_chunk(b"IHDR", ihdr)
        + _png_chunk(b"IDAT", idat)
        + _png_chunk(b"IEND", b"")
    )


# ==================================================================== Math Helpers

def euler_deg_to_quat(rx_deg: float, ry_deg: float, rz_deg: float):
    """Intrinsic XYZ (or extrinsic ZYX) Euler degrees -> glTF unit quaternion [x, y, z, w]."""
    hx = math.radians(rx_deg) * 0.5
    hy = math.radians(ry_deg) * 0.5
    hz = math.radians(rz_deg) * 0.5
    cx, sx = math.cos(hx), math.sin(hx)
    cy, sy = math.cos(hy), math.sin(hy)
    cz, sz = math.cos(hz), math.sin(hz)
    # q = qz * qy * qx (standard yaw-pitch-roll / ZYX)
    x = sx * cy * cz - cx * sy * sz
    y = cx * sy * cz + sx * cy * sz
    z = cx * cy * sz - sx * sy * cz
    w = cx * cy * cz + sx * sy * sz
    inv = 1.0 / max(1e-12, math.sqrt(x * x + y * y + z * z + w * w))
    return (x * inv, y * inv, z * inv, w * inv)


def clamp_u8(v: float) -> int:
    iv = int(round(v))
    return 0 if iv < 0 else (255 if iv > 255 else iv)


def shade_rgb(rgb, factor: float):
    return (clamp_u8(rgb[0] * factor), clamp_u8(rgb[1] * factor), clamp_u8(rgb[2] * factor))


def hex_rgb(s: str):
    s = s.lstrip("#")
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16))


# ==================================================================== Palette Texture

class PaletteAtlas:
    """Packs solid RGBA colors as 4x4 texel tiles in a square PNG so every face samples a clean texel center."""

    def __init__(self, cell_px: int = 4):
        self.cell_px = cell_px
        self.colors = []
        self.lookup = {}

    def add(self, rgba) -> int:
        if len(rgba) == 3:
            rgba = (rgba[0], rgba[1], rgba[2], 255)
        key = (int(rgba[0]) & 255, int(rgba[1]) & 255, int(rgba[2]) & 255, int(rgba[3]) & 255)
        idx = self.lookup.get(key)
        if idx is None:
            idx = len(self.colors)
            self.colors.append(key)
            self.lookup[key] = idx
        return idx

    def grid_side(self) -> int:
        n = max(1, len(self.colors))
        side = 1
        while side * side < n:
            side *= 2
        return max(4, side)

    def uv_of(self, idx: int):
        side = self.grid_side()
        gx = idx % side
        gy = idx // side
        u = (gx + 0.5) / side
        v = (gy + 0.5) / side
        return (u, v)

    def to_png(self) -> bytes:
        side = self.grid_side()
        c = self.cell_px
        w = side * c
        h = side * c
        buf = bytearray(w * h * 4)
        for idx, (r, g, b, a) in enumerate(self.colors):
            gx = (idx % side) * c
            gy = (idx // side) * c
            for dy in range(c):
                row = ((gy + dy) * w + gx) * 4
                for dx in range(c):
                    o = row + dx * 4
                    buf[o] = r
                    buf[o + 1] = g
                    buf[o + 2] = b
                    buf[o + 3] = a
        return encode_png_rgba(w, h, buf)


# ==================================================================== Pure Voxel Grid Mesher

# Six orthogonal directions: (dx, dy, dz), normal, 4 CCW corners relative to (ix, iy, iz)
VOXEL_FACES = [
    # +X
    ((1, 0, 0), (1.0, 0.0, 0.0), ((1, 0, 1), (1, 0, 0), (1, 1, 0), (1, 1, 1)), 0.96, (0.0, 0.0, -1.0, 1.0)),
    # -X
    ((-1, 0, 0), (-1.0, 0.0, 0.0), ((0, 0, 0), (0, 0, 1), (0, 1, 1), (0, 1, 0)), 0.92, (0.0, 0.0, 1.0, 1.0)),
    # +Y (top)
    ((0, 1, 0), (0.0, 1.0, 0.0), ((0, 1, 1), (1, 1, 1), (1, 1, 0), (0, 1, 0)), 1.05, (1.0, 0.0, 0.0, 1.0)),
    # -Y (bottom)
    ((0, -1, 0), (0.0, -1.0, 0.0), ((0, 0, 0), (1, 0, 0), (1, 0, 1), (0, 0, 1)), 0.78, (1.0, 0.0, 0.0, 1.0)),
    # +Z (front)
    ((0, 0, 1), (0.0, 0.0, 1.0), ((0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1)), 1.00, (1.0, 0.0, 0.0, 1.0)),
    # -Z (back)
    ((0, 0, -1), (0.0, 0.0, -1.0), ((1, 0, 0), (0, 0, 0), (0, 1, 0), (1, 1, 0)), 0.94, (-1.0, 0.0, 0.0, 1.0)),
]


class VoxelGrid:
    """Integer 3D voxel lattice storing (rgb_tuple, mat_tag) per occupied voxel."""

    def __init__(self, voxel_size: float = 0.024, origin=(0.0, 0.0, 0.0)):
        self.voxel_size = voxel_size
        self.origin = origin  # world-local position of voxel grid (0,0,0) corner
        self.cells = {}       # (ix, iy, iz) -> (rgb, mat_tag)

    def set(self, x: int, y: int, z: int, rgb, mat: str = "main"):
        self.cells[(int(x), int(y), int(z))] = (rgb, mat)

    def clear(self, x: int, y: int, z: int):
        self.cells.pop((int(x), int(y), int(z)), None)

    def has(self, x: int, y: int, z: int) -> bool:
        return (int(x), int(y), int(z)) in self.cells

    def fill(self, x0: int, x1: int, y0: int, y1: int, z0: int, z1: int, rgb, mat: str = "main"):
        """Inclusive integer box fill: x in [x0..x1], y in [y0..y1], z in [z0..z1]."""
        for x in range(int(x0), int(x1) + 1):
            for y in range(int(y0), int(y1) + 1):
                for z in range(int(z0), int(z1) + 1):
                    self.cells[(x, y, z)] = (rgb, mat)

    def carve(self, x0: int, x1: int, y0: int, y1: int, z0: int, z1: int):
        for x in range(int(x0), int(x1) + 1):
            for y in range(int(y0), int(y1) + 1):
                for z in range(int(z0), int(z1) + 1):
                    self.cells.pop((x, y, z), None)

    def paint_box(self, x0: int, x1: int, y0: int, y1: int, z0: int, z1: int, rgb, mat: str = None):
        """Repaint only already-occupied voxels inside the box."""
        for x in range(int(x0), int(x1) + 1):
            for y in range(int(y0), int(y1) + 1):
                for z in range(int(z0), int(z1) + 1):
                    k = (x, y, z)
                    if k in self.cells:
                        old_mat = self.cells[k][1]
                        self.cells[k] = (rgb, old_mat if mat is None else mat)

    def build_primitives(self, atlas: PaletteAtlas, bake_ao: bool = True):
        """Return dict[mat_tag] -> {positions, normals, uvs, tangents, indices}."""
        by_mat = {}
        vs = self.voxel_size
        ox, oy, oz = self.origin
        cells = self.cells

        for (ix, iy, iz), (rgb, mat) in cells.items():
            for (dx, dy, dz), norm, corners, face_shade, tang in VOXEL_FACES:
                if (ix + dx, iy + dy, iz + dz) in cells:
                    continue  # Internal face culled
                # Subtle voxel crease AO: count orthogonal neighbors touching the front of this face
                ao = 1.0
                if bake_ao:
                    nx, ny, nz = ix + dx, iy + dy, iz + dz
                    occ = 0
                    if dx == 0:
                        if (nx - 1, ny, nz) in cells: occ += 1
                        if (nx + 1, ny, nz) in cells: occ += 1
                    if dy == 0:
                        if (nx, ny - 1, nz) in cells: occ += 1
                        if (nx, ny + 1, nz) in cells: occ += 1
                    if dz == 0:
                        if (nx, ny, nz - 1) in cells: occ += 1
                        if (nx, ny, nz + 1) in cells: occ += 1
                    ao = 1.0 - min(0.22, occ * 0.055)

                shaded = shade_rgb(rgb, face_shade * ao)
                cidx = atlas.add(shaded)
                u, v = atlas.uv_of(cidx)

                bucket = by_mat.get(mat)
                if bucket is None:
                    bucket = {"positions": [], "normals": [], "uvs": [], "tangents": [], "indices": []}
                    by_mat[mat] = bucket

                base = len(bucket["positions"]) // 3
                for cx, cy, cz in corners:
                    bucket["positions"].extend((ox + (ix + cx) * vs, oy + (iy + cy) * vs, oz + (iz + cz) * vs))
                    bucket["normals"].extend(norm)
                    bucket["uvs"].extend((u, v))
                    bucket["tangents"].extend(tang)
                bucket["indices"].extend((base, base + 1, base + 2, base, base + 2, base + 3))

        return by_mat

    def build_primitives_deferred(self, atlas: PaletteAtlas, bake_ao: bool = True):
        """Two-pass safe voxel mesher: registers colors in atlas and stores cidx per quad;
        call resolve_deferred_uvs(prims_dict, atlas) after ALL parts have registered colors!"""
        by_mat = {}
        vs = self.voxel_size
        ox, oy, oz = self.origin
        cells = self.cells

        for (ix, iy, iz), (rgb, mat) in cells.items():
            for (dx, dy, dz), norm, corners, face_shade, tang in VOXEL_FACES:
                if (ix + dx, iy + dy, iz + dz) in cells:
                    continue
                ao = 1.0
                if bake_ao:
                    nx, ny, nz = ix + dx, iy + dy, iz + dz
                    occ = 0
                    if dx == 0:
                        if (nx - 1, ny, nz) in cells: occ += 1
                        if (nx + 1, ny, nz) in cells: occ += 1
                    if dy == 0:
                        if (nx, ny - 1, nz) in cells: occ += 1
                        if (nx, ny + 1, nz) in cells: occ += 1
                    if dz == 0:
                        if (nx, ny, nz - 1) in cells: occ += 1
                        if (nx, ny, nz + 1) in cells: occ += 1
                    ao = 1.0 - min(0.22, occ * 0.055)

                shaded = shade_rgb(rgb, face_shade * ao)
                cidx = atlas.add(shaded)

                bucket = by_mat.get(mat)
                if bucket is None:
                    bucket = {"positions": [], "normals": [], "uvs": [], "cidx": [], "tangents": [], "indices": []}
                    by_mat[mat] = bucket

                base = len(bucket["positions"]) // 3
                for cx, cy, cz in corners:
                    bucket["positions"].extend((ox + (ix + cx) * vs, oy + (iy + cy) * vs, oz + (iz + cz) * vs))
                    bucket["normals"].extend(norm)
                    bucket["cidx"].append(cidx)
                    bucket["tangents"].extend(tang)
                bucket["indices"].extend((base, base + 1, base + 2, base, base + 2, base + 3))

        return by_mat


def resolve_deferred_uvs(all_parts_by_mat: dict, atlas: PaletteAtlas):
    """Second pass: convert stored palette indices to final texel-center UVs once atlas size is final."""
    for by_mat in all_parts_by_mat.values():
        for bucket in by_mat.values():
            uvs = []
            for cidx in bucket["cidx"]:
                u, v = atlas.uv_of(cidx)
                uvs.extend((u, v))
            bucket["uvs"] = uvs
            del bucket["cidx"]


def build_box_primitive(x0, x1, y0, y1, z0, z1, atlas: PaletteAtlas, rgb, bake_shade: bool = True):
    """Single clean CCW axis-aligned box primitive."""
    pos, nrm, uvs, tng, idx = [], [], [], [], []
    faces = [
        ((1, 0, 0), ((x1, y0, z1), (x1, y0, z0), (x1, y1, z0), (x1, y1, z1)), 0.96, (0, 0, -1, 1)),
        ((-1, 0, 0), ((x0, y0, z0), (x0, y0, z1), (x0, y1, z1), (x0, y1, z0)), 0.92, (0, 0, 1, 1)),
        ((0, 1, 0), ((x0, y1, z1), (x1, y1, z1), (x1, y1, z0), (x0, y1, z0)), 1.05, (1, 0, 0, 1)),
        ((0, -1, 0), ((x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1)), 0.78, (1, 0, 0, 1)),
        ((0, 0, 1), ((x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)), 1.00, (1, 0, 0, 1)),
        ((0, 0, -1), ((x1, y0, z0), (x0, y0, z0), (x0, y1, z0), (x1, y1, z0)), 0.94, (-1, 0, 0, 1)),
    ]
    for norm, verts, shade, tang in faces:
        col = shade_rgb(rgb, shade) if bake_shade else rgb
        u, v = atlas.uv_of(atlas.add(col))
        base = len(pos) // 3
        for vx, vy, vz in verts:
            pos.extend((vx, vy, vz))
            nrm.extend(norm)
            uvs.extend((u, v))
            tng.extend(tang)
        idx.extend((base, base + 1, base + 2, base, base + 2, base + 3))
    return {"positions": pos, "normals": nrm, "uvs": uvs, "tangents": tng, "indices": idx}


# ==================================================================== glTF 2.0 GLB Writer

class GlbBuilder:
    def __init__(self, generator: str = "xiaoman3d-voxel-builder"):
        self.generator = generator
        self.bin_data = bytearray()
        self.buffer_views = []
        self.accessors = []
        self.images = []
        self.samplers = []
        self.textures = []
        self.materials = []
        self.meshes = []
        self.nodes = []
        self.animations = []
        self.root_nodes = []

    def _pad4(self):
        rem = len(self.bin_data) % 4
        if rem:
            self.bin_data.extend(b"\x00" * (4 - rem))

    def _add_bv(self, raw: bytes, target: int = None) -> int:
        self._pad4()
        offset = len(self.bin_data)
        self.bin_data.extend(raw)
        bv = {"buffer": 0, "byteOffset": offset, "byteLength": len(raw)}
        if target is not None:
            bv["target"] = target
        idx = len(self.buffer_views)
        self.buffer_views.append(bv)
        return idx

    def _add_accessor(self, raw: bytes, comp_type: int, acc_type: str, count: int,
                      target: int = None, min_v=None, max_v=None) -> int:
        bv = self._add_bv(raw, target=target)
        acc = {
            "bufferView": bv,
            "componentType": comp_type,
            "count": count,
            "type": acc_type,
        }
        if min_v is not None:
            acc["min"] = list(min_v)
        if max_v is not None:
            acc["max"] = list(max_v)
        idx = len(self.accessors)
        self.accessors.append(acc)
        return idx

    def add_sampler(self, mag: int = 9728, min_f: int = 9728, wrap_s: int = 33071, wrap_t: int = 33071) -> int:
        idx = len(self.samplers)
        self.samplers.append({"magFilter": mag, "minFilter": min_f, "wrapS": wrap_s, "wrapT": wrap_t})
        return idx

    def add_png_texture(self, png_bytes: bytes, sampler_idx: int, name: str = "") -> int:
        bv = self._add_bv(png_bytes, target=None)
        img_idx = len(self.images)
        img = {"bufferView": bv, "mimeType": "image/png"}
        if name:
            img["name"] = name
        self.images.append(img)
        tex_idx = len(self.textures)
        self.textures.append({"sampler": sampler_idx, "source": img_idx})
        return tex_idx

    def add_material(self, name: str, base_color=(1.0, 1.0, 1.0, 1.0), metallic: float = 0.0,
                     roughness: float = 0.8, base_tex: int = None, normal_tex: int = None,
                     mr_tex: int = None, emissive_tex: int = None, emissive_factor=None,
                     double_sided: bool = False, alpha_mode: str = "OPAQUE") -> int:
        pbr = {
            "baseColorFactor": [float(c) for c in base_color],
            "metallicFactor": float(metallic),
            "roughnessFactor": float(roughness),
        }
        if base_tex is not None:
            pbr["baseColorTexture"] = {"index": base_tex}
        if mr_tex is not None:
            pbr["metallicRoughnessTexture"] = {"index": mr_tex}
        mat = {"name": name, "pbrMetallicRoughness": pbr}
        if normal_tex is not None:
            mat["normalTexture"] = {"index": normal_tex, "scale": 1.0}
        if emissive_tex is not None:
            mat["emissiveTexture"] = {"index": emissive_tex}
        if emissive_factor is not None:
            mat["emissiveFactor"] = [float(c) for c in emissive_factor]
        if double_sided:
            mat["doubleSided"] = True
        if alpha_mode != "OPAQUE":
            mat["alphaMode"] = alpha_mode
        idx = len(self.materials)
        self.materials.append(mat)
        return idx

    def add_mesh(self, name: str, prim_list) -> int:
        """prim_list: list of (prim_dict, material_idx)."""
        gltf_prims = []
        for prim, mat_idx in prim_list:
            pos = prim["positions"]
            nrm = prim["normals"]
            uvs = prim["uvs"]
            indices = prim["indices"]
            vcount = len(pos) // 3
            if vcount == 0 or not indices:
                continue
            xs = pos[0::3]
            ys = pos[1::3]
            zs = pos[2::3]
            pos_raw = struct.pack(f"<{len(pos)}f", *pos)
            nrm_raw = struct.pack(f"<{len(nrm)}f", *nrm)
            uv_raw = struct.pack(f"<{len(uvs)}f", *uvs)
            pos_acc = self._add_accessor(pos_raw, 5126, "VEC3", vcount, 34962,
                                         (min(xs), min(ys), min(zs)), (max(xs), max(ys), max(zs)))
            nrm_acc = self._add_accessor(nrm_raw, 5126, "VEC3", vcount, 34962)
            uv_acc = self._add_accessor(uv_raw, 5126, "VEC2", vcount, 34962)
            attrs = {"POSITION": pos_acc, "NORMAL": nrm_acc, "TEXCOORD_0": uv_acc}
            if "tangents" in prim and prim["tangents"]:
                tng = prim["tangents"]
                tng_raw = struct.pack(f"<{len(tng)}f", *tng)
                attrs["TANGENT"] = self._add_accessor(tng_raw, 5126, "VEC4", vcount, 34962)
            if vcount <= 65535:
                idx_raw = struct.pack(f"<{len(indices)}H", *indices)
                idx_acc = self._add_accessor(idx_raw, 5123, "SCALAR", len(indices), 34963)
            else:
                idx_raw = struct.pack(f"<{len(indices)}I", *indices)
                idx_acc = self._add_accessor(idx_raw, 5125, "SCALAR", len(indices), 34963)
            gltf_prims.append({"attributes": attrs, "indices": idx_acc, "material": mat_idx})
        idx = len(self.meshes)
        self.meshes.append({"name": name, "primitives": gltf_prims})
        return idx

    def add_node(self, name: str, mesh: int = None, translation=None, rotation=None, scale=None,
                 parent: int = None) -> int:
        node = {"name": name}
        if mesh is not None:
            node["mesh"] = mesh
        if translation is not None:
            node["translation"] = [float(v) for v in translation]
        if rotation is not None:
            node["rotation"] = [float(v) for v in rotation]
        if scale is not None:
            node["scale"] = [float(v) for v in scale]
        idx = len(self.nodes)
        self.nodes.append(node)
        if parent is not None:
            self.nodes[parent].setdefault("children", []).append(idx)
        else:
            self.root_nodes.append(idx)
        return idx

    def add_animation(self, name: str, tracks):
        """tracks: list of (node_idx, path, times_list, values_list)
        where path is 'translation' (VEC3), 'rotation' (VEC4 xyzw quat), or 'scale' (VEC3).
        """
        samplers = []
        channels = []
        for node_idx, path, times, values in tracks:
            n = len(times)
            assert n >= 2 and len(values) == n
            t_raw = struct.pack(f"<{n}f", *[float(t) for t in times])
            t_acc = self._add_accessor(t_raw, 5126, "SCALAR", n, None, (min(times),), (max(times),))
            if path == "rotation":
                # Ensure shortest-arc quaternion sign continuity
                fixed = []
                prev = None
                for q in values:
                    qx, qy, qz, qw = q
                    if prev is not None and (prev[0] * qx + prev[1] * qy + prev[2] * qz + prev[3] * qw) < 0.0:
                        qx, qy, qz, qw = -qx, -qy, -qz, -qw
                    cur = (qx, qy, qz, qw)
                    fixed.append(cur)
                    prev = cur
                flat = [c for q in fixed for c in q]
                v_raw = struct.pack(f"<{len(flat)}f", *flat)
                v_acc = self._add_accessor(v_raw, 5126, "VEC4", n, None)
            else:
                flat = [float(c) for v in values for c in v]
                v_raw = struct.pack(f"<{len(flat)}f", *flat)
                v_acc = self._add_accessor(v_raw, 5126, "VEC3", n, None)
            s_idx = len(samplers)
            samplers.append({"input": t_acc, "interpolation": "LINEAR", "output": v_acc})
            channels.append({"sampler": s_idx, "target": {"node": node_idx, "path": path}})
        self.animations.append({"name": name, "samplers": samplers, "channels": channels})

    def to_glb_bytes(self) -> bytes:
        self._pad4()
        gltf = {
            "asset": {"version": "2.0", "generator": self.generator},
            "scene": 0,
            "scenes": [{"name": "Scene", "nodes": self.root_nodes}],
            "nodes": self.nodes,
            "meshes": self.meshes,
            "materials": self.materials,
            "accessors": self.accessors,
            "bufferViews": self.buffer_views,
            "buffers": [{"byteLength": len(self.bin_data)}],
        }
        if self.samplers:
            gltf["samplers"] = self.samplers
        if self.images:
            gltf["images"] = self.images
        if self.textures:
            gltf["textures"] = self.textures
        if self.animations:
            gltf["animations"] = self.animations

        json_bytes = json.dumps(gltf, separators=(",", ":"), ensure_ascii=True).encode("utf-8")
        jpad = (4 - (len(json_bytes) % 4)) % 4
        json_bytes += b" " * jpad

        bpad = (4 - (len(self.bin_data) % 4)) % 4
        bin_bytes = bytes(self.bin_data) + (b"\x00" * bpad)

        total_len = 12 + 8 + len(json_bytes) + 8 + len(bin_bytes)
        header = struct.pack("<4sII", b"glTF", 2, total_len)
        jchunk = struct.pack("<I4s", len(json_bytes), b"JSON") + json_bytes
        bchunk = struct.pack("<I4s", len(bin_bytes), b"BIN\x00") + bin_bytes
        return header + jchunk + bchunk

    def save(self, path: str) -> int:
        data = self.to_glb_bytes()
        with open(path, "wb") as f:
            f.write(data)
        return len(data)
