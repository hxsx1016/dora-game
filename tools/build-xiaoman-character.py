#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build pure orthogonal voxel 3D Xiaoman character (assets/xiaoman3d/xiaoman.glb).

Design contract:
- Pure orthogonal voxel (Style 2, MagicaVoxel / pixel-block aesthetic) faithful to prologue Xiaoman
  (art-source/characters/xiaoman.png & docs/守望-明朝全局美术设定.md).
- Bright luminous Ming palette (bright vermilion-coral tunic, cream cross-collar & sash,
  warm sunlit peach face with bright eyes, bright slate-teal lantern pants, cream leg wraps,
  straw sandals, tan crossbody satchel, warm amber-gold wrist compass pouch) so Xiaoman pops
  clearly against dark realistic 3D scenes.
- 6 full distinct sides (Front +Z, Back -Z, Left -X, Right +X, Top +Y, Bottom -Y).
- Standing height ~0.62 m (aligns with CHILD_H = 56 game units = 0.56 m + twin buns),
  crouch height ~0.35 m (< 0.44 m low arch / table / culvert clearance).
- 13 articulated nodes + hand_R_socket for attaching 3D bottle/items + 13 embedded glTF animations.

Usage:
    python3 tools/build-xiaoman-character.py
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
    euler_deg_to_quat,
    hex_rgb,
    resolve_deferred_uvs,
)

# ---------------------------------------------------------------- Bright Ming Palette
SKIN       = hex_rgb("#FDE0C0")
SKIN_SHADE = hex_rgb("#EEBE94")
CHEEK      = hex_rgb("#FAA496")
EYE_DARK   = hex_rgb("#241814")
EYE_WHITE  = hex_rgb("#FFFFFF")
BROW       = hex_rgb("#4A2F24")
MOUTH      = hex_rgb("#D87B6E")

HAIR       = hex_rgb("#422D25")
HAIR_HI    = hex_rgb("#68483B")
HAIR_DEEP  = hex_rgb("#2B1C17")
RIBBON     = hex_rgb("#FF493D")
RIBBON_HI  = hex_rgb("#FF7A6B")

TUNIC      = hex_rgb("#F25F48")
TUNIC_HI   = hex_rgb("#FF866E")
TUNIC_DEEP = hex_rgb("#C93E2B")
CREAM      = hex_rgb("#FBF2DA")
CREAM_SH   = hex_rgb("#E5D5B2")
SASH       = hex_rgb("#FCEBBF")
SASH_TIE   = hex_rgb("#F6D488")

SATCHEL    = hex_rgb("#DF9F56")
SATCHEL_HI = hex_rgb("#F5BE76")
SATCHEL_DK = hex_rgb("#A86C32")
STRAP      = hex_rgb("#BA7B3E")

PANTS      = hex_rgb("#648D96")
PANTS_HI   = hex_rgb("#82B0BA")
PANTS_DK   = hex_rgb("#466972")
WRAP       = hex_rgb("#F5EAD0")
WRAP_SH    = hex_rgb("#D5C49E")
SANDAL     = hex_rgb("#D49E5A")
SOLE       = hex_rgb("#6B4B2E")

COMPASS    = hex_rgb("#FFD25A")
COMPASS_DK = hex_rgb("#D49A28")
COMPASS_RD = hex_rgb("#FF4E40")

# Voxel unit: 2.2 cm -> standing height ~28 voxels = 0.616 m (head top ~0.58 m, buns ~0.625 m)
VS = 0.022


def make_grid(ox_vox: float, oy_vox: float, oz_vox: float) -> VoxelGrid:
    """Create voxel grid whose local origin places (0,0,0) voxel corner at (ox_vox, oy_vox, oz_vox)*VS."""
    return VoxelGrid(VS, (ox_vox * VS, oy_vox * VS, oz_vox * VS))


def build_pelvis() -> VoxelGrid:
    # Local pivot at hip center (0, 0.22, 0). Spans y = -1..+1 voxels around hip.
    g = make_grid(-3.5, -1.0, -2.5)
    # Tunic skirt hem (x=0..6, y=0..1, z=0..4)
    g.fill(0, 6, 0, 1, 0, 4, TUNIC)
    # Front (+Z, z=4) lower overlap hem & cream sash tail hanging
    g.fill(0, 6, 0, 0, 4, 4, TUNIC_DEEP)
    g.set(3, 1, 4, SASH)
    g.set(3, 0, 4, SASH_TIE)
    g.set(4, 0, 4, SASH)
    # Back (-Z, z=0) lower tunic hem with small warm patch
    g.fill(0, 6, 0, 0, 0, 0, TUNIC_DEEP)
    g.set(2, 1, 0, TUNIC_HI)
    # Left-side satchel bottom resting at left hip (x=-1, z=1..3)
    g.fill(-1, -1, -1, 1, 1, 3, SATCHEL)
    g.fill(-1, -1, 1, 1, 1, 3, SATCHEL_HI)  # flap top
    g.set(-1, 0, 2, COMPASS, "brass")       # brass clasp on satchel
    return g


def build_torso() -> VoxelGrid:
    # Local pivot at waist (0, 0.242, 0), extends upward y = 0..7 voxels (0.176 m tall)
    # Width x = 0..6 (7 voxels = 0.154 m), depth z = 0..4 (5 voxels = 0.110 m)
    g = make_grid(-3.5, 0.0, -2.5)
    g.fill(0, 6, 0, 6, 0, 4, TUNIC)
    # Slight shoulder taper at top row y=6
    g.carve(0, 0, 6, 6, 0, 0)
    g.carve(6, 6, 6, 6, 0, 0)
    g.carve(0, 0, 6, 6, 4, 4)
    g.carve(6, 6, 6, 6, 4, 4)
    # Bright sunlit upper shoulders & chest highlights
    g.paint_box(1, 5, 5, 6, 1, 3, TUNIC_HI)

    # Cream sash wrapping all 4 sides at y=1
    g.paint_box(0, 6, 1, 1, 0, 4, SASH)
    # Front (+Z, z=4) sash bow knot & Ming right-lapel cross-collar (右衽斜襟)
    g.set(3, 1, 4, SASH_TIE)
    g.set(4, 1, 4, CREAM)
    # Cross-collar cream V-line from shoulders down to right hip (classic Ming 右衽)
    collar_front = [
        (2, 6, 4), (4, 6, 4),
        (2, 5, 4), (3, 5, 4), (4, 5, 4),
        (3, 4, 4), (4, 4, 4),
        (4, 3, 4),
        (4, 2, 4),
    ]
    for x, y, z in collar_front:
        g.set(x, y, z, CREAM)
    # Inner neckline skin peek
    g.set(3, 6, 4, SKIN)
    # Diagonal satchel strap across chest (+Z): from right shoulder (x=5,y=6) down to left hip (x=0,y=1)
    strap_front = [(5, 6, 4), (4, 5, 4), (3, 4, 4), (2, 3, 4), (1, 2, 4), (0, 2, 4)]
    for x, y, z in strap_front:
        g.set(x, y, z, STRAP)

    # Back (-Z, z=0) details: cream back collar, diagonal strap across back, warm stitched patch
    g.fill(2, 4, 6, 6, 0, 0, CREAM)
    strap_back = [(5, 6, 0), (4, 5, 0), (3, 4, 0), (2, 3, 0), (1, 2, 0), (0, 2, 0)]
    for x, y, z in strap_back:
        g.set(x, y, z, STRAP)
    # Subtle Ming hand-stitched patch on lower-right back (charming back-view detail!)
    g.fill(4, 5, 2, 3, 0, 0, TUNIC_HI)
    g.set(5, 2, 0, CREAM_SH)
    # Top strap segment on right shoulder
    g.set(5, 6, 1, STRAP)
    g.set(5, 6, 2, STRAP)
    g.set(5, 6, 3, STRAP)

    # Left side (-X, x=0): satchel strap descending into hip bag
    g.set(0, 2, 1, STRAP)
    g.set(0, 2, 2, STRAP)
    g.set(0, 2, 3, STRAP)
    g.set(0, 1, 2, SATCHEL_DK)

    # Right side (+X, x=6): bright tunic side seam & sash knot detail
    g.set(6, 2, 2, TUNIC_HI)
    g.set(6, 1, 2, SASH_TIE)

    # Neck stub at y=7 (2x1x2 centered)
    g.fill(2, 4, 7, 7, 1, 3, SKIN_SHADE)
    g.set(3, 7, 3, SKIN)
    return g


def build_head() -> VoxelGrid:
    # Local pivot at neck base (0, 0.396, 0).
    # Child voxel head: 9 wide (x=0..8), 8 tall (y=0..7), 8 deep (z=0..7).
    # Rounded pure-voxel corners (carving outer 8 corner voxels makes it look crisp MagicaVoxel style!).
    g = make_grid(-4.5, 0.0, -4.0)
    g.fill(0, 8, 0, 7, 0, 7, SKIN)
    # Carve 8 outer extreme corners for adorable voxel roundness
    for cx in (0, 8):
        for cy in (0, 7):
            for cz in (0, 7):
                g.clear(cx, cy, cz)
    # Slightly soften top edges
    g.carve(0, 0, 7, 7, 0, 7)
    g.carve(8, 8, 7, 7, 0, 7)

    # ---- Hair cap (top y=6..7, back z=0..2, sides x=0 & x=8 upper/back)
    g.paint_box(0, 8, 6, 7, 0, 7, HAIR)
    g.paint_box(2, 6, 7, 7, 2, 5, HAIR_HI)       # warm sunlit hair highlight on crown
    g.paint_box(0, 8, 1, 6, 0, 2, HAIR)          # full back hair
    g.paint_box(1, 7, 4, 6, 0, 0, HAIR_HI)       # back hair rim shine
    g.paint_box(1, 7, 1, 1, 0, 1, HAIR_DEEP)     # nape hairline shadow
    # Back nape skin peek at bottom center y=0
    g.paint_box(2, 6, 0, 0, 0, 1, SKIN_SHADE)

    # Side locks framing face (Left x=0 & Right x=8)
    for sx in (0, 8):
        g.paint_box(sx, sx, 2, 6, 1, 5, HAIR)
        g.paint_box(sx, sx, 5, 6, 3, 6, HAIR)
        g.paint_box(sx, sx, 4, 5, 2, 3, HAIR_HI)
        # Cute little peach voxel ears poking out at (sx, y=2..3, z=3..4)
        g.set(sx, 2, 4, SKIN)
        g.set(sx, 3, 4, SKIN)
        g.set(sx, 2, 3, SKIN_SHADE)

    # ---- Front (+Z, z=7) Bangs (齐刘海) & Expressive Bright Pixel Face!
    # Layered bangs across forehead y=5..6
    g.paint_box(1, 7, 6, 6, 7, 7, HAIR)
    g.set(1, 5, 7, HAIR)
    g.set(2, 5, 7, HAIR)
    g.set(4, 5, 7, HAIR)       # cute center wisp
    g.set(6, 5, 7, HAIR)
    g.set(7, 5, 7, HAIR)
    g.set(3, 6, 7, HAIR_HI)
    g.set(5, 6, 7, HAIR_HI)

    # Eyebrows (y=4, z=7)
    g.set(2, 4, 7, BROW)
    g.set(6, 4, 7, BROW)
    # Bright expressive 2x2 pixel eyes (x=2..3 and x=5..6, y=2..3, z=7)
    # Left eye (viewer left, x=2..3)
    g.set(2, 3, 7, EYE_WHITE)  # bright upper-left catchlight!
    g.set(3, 3, 7, EYE_DARK)
    g.set(2, 2, 7, EYE_DARK)
    g.set(3, 2, 7, EYE_DARK)
    # Right eye (viewer right, x=5..6)
    g.set(5, 3, 7, EYE_WHITE)  # bright catchlight!
    g.set(6, 3, 7, EYE_DARK)
    g.set(5, 2, 7, EYE_DARK)
    g.set(6, 2, 7, EYE_DARK)
    # Rosy cheeks & gentle tiny mouth
    g.set(1, 1, 7, CHEEK)
    g.set(7, 1, 7, CHEEK)
    g.set(4, 1, 7, MOUTH)
    # Subtle chin shade
    g.paint_box(2, 6, 0, 0, 6, 7, SKIN_SHADE)
    g.set(4, 0, 7, SKIN)

    # Subtle 1-voxel nose hint / side-profile contour (already crisp with z=7 front plane)
    return g


def build_bun(side: int) -> VoxelGrid:
    """Ming twin hair bun (双髻) with bright red ribbon wrap! side=-1 (left) or +1 (right)."""
    g = make_grid(-2.0, -2.0, -2.0)
    g.fill(0, 3, 0, 3, 0, 3, HAIR)
    # Carve outer corners for crisp rounded voxel sphere bun
    for cx in (0, 3):
        for cy in (0, 3):
            for cz in (0, 3):
                g.clear(cx, cy, cz)
    # Highlight top-front of bun
    g.paint_box(1, 2, 3, 3, 1, 2, HAIR_HI)
    # Bright vermilion ribbon band wrapping base of the bun (visible from front, back, and sides!)
    inner_x = 3 if side < 0 else 0
    g.paint_box(inner_x, inner_x, 0, 3, 0, 3, RIBBON)
    g.paint_box(inner_x, inner_x, 2, 3, 1, 2, RIBBON_HI)
    # Extra bow knot nub on back of bun (-Z, z=0)
    g.fill(1, 2, 1, 2, 0, 0, RIBBON)
    g.set(1, 2, 0, RIBBON_HI)
    return g


def build_ribbon() -> VoxelGrid:
    """Trailing bright vermilion voxel hair ribbon hanging down behind each bun (animated!)."""
    g = make_grid(-0.5, -4.0, -0.5)
    g.set(0, 3, 0, RIBBON_HI)
    g.set(0, 2, 0, RIBBON)
    g.set(0, 1, -1, RIBBON)
    g.set(0, 0, -1, RIBBON_HI)
    return g


def build_arm(is_right: bool) -> VoxelGrid:
    """Articulated arm hanging downward from shoulder pivot (y=0 down to y=-6 voxels)."""
    g = make_grid(-1.0, -6.0, -1.0)
    # Upper & mid bright vermilion Ming wide sleeve (y=2..6)
    g.fill(0, 1, 2, 5, 0, 1, TUNIC)
    g.paint_box(0, 1, 4, 5, 0, 1, TUNIC_HI)
    # Crisp bright cream rolled cuff (y=2)
    g.fill(0, 1, 2, 2, 0, 1, CREAM)
    # Right wrist carries Xiaoman's iconic Ming compass pouch (腕上指南针布套)!
    if is_right:
        g.set(1, 1, 1, COMPASS, "brass")
        g.set(1, 1, 0, COMPASS_DK, "brass")
        g.set(1, 2, 1, COMPASS_RD)  # red wrist cord wrap!
    # Warm peach voxel hand (y=0..1)
    g.fill(0, 1, 0, 1, 0, 1, SKIN)
    if is_right:
        # Keep compass nub on outer right wrist (+X)
        g.set(2, 1, 1, COMPASS, "brass")
        g.set(2, 1, 0, COMPASS_DK, "brass")
    return g


def build_leg(is_right: bool) -> VoxelGrid:
    """Articulated Ming lantern trouser + cream cross-wrap bindings + straw cloth sandal.
    Pivot at hip y=0, extends down y=-10..-1 voxels (0.22 m). Foot sole sits cleanly at y = -10*VS = -0.22 m.
    """
    g = make_grid(-1.5, -10.0, -1.5)
    # Upper puffy lantern pants (y=5..9, 3x5x3 voxels)
    g.fill(0, 2, 5, 9, 0, 2, PANTS)
    g.paint_box(0, 2, 7, 9, 2, 2, PANTS_HI)   # front highlight
    g.paint_box(0, 2, 5, 6, 0, 0, PANTS_DK)   # back knee fold
    # Cream-white Ming shin leg wraps (绑腿, y=2..4, 2x3x2 centered)
    g.fill(0, 1, 2, 4, 0, 1, WRAP)
    g.set(0, 3, 1, WRAP_SH)
    g.set(1, 2, 0, WRAP_SH)
    # Straw cloth sandal (草编布鞋, y=0..1, slightly extended forward to +Z=2 for toe!)
    g.fill(0, 1, 0, 0, 0, 2, SOLE)            # firm dark sandal sole
    g.fill(0, 1, 1, 1, 0, 2, SANDAL)          # woven straw upper
    g.set(0, 1, 2, WRAP)                      # toe strap highlight
    return g


# ---------------------------------------------------------------- Keyframe Animation Helper

def build_animations(nodes):
    """Build 13 rich glTF keyframe animations targeting the 13 rigid nodes."""
    anims = []
    # Base local rest translations of pelvis & head
    pelvis_rest = (0.0, 10.0 * VS, 0.0)   # 0.220 m

    def q(rx=0.0, ry=0.0, rz=0.0):
        return euler_deg_to_quat(rx, ry, rz)

    def make_clip(name, duration, samples, pose_fn):
        times = [duration * i / (samples - 1) for i in range(samples)]
        tracks_map = {}  # (node_key, path) -> list of values
        for i, t in enumerate(times):
            u = i / (samples - 1)
            pose = pose_fn(u)
            for (nkey, path), val in pose.items():
                tracks_map.setdefault((nkey, path), []).append(val)
        tracks = []
        for (nkey, path), vals in tracks_map.items():
            tracks.append((nodes[nkey], path, times, vals))
        anims.append((name, tracks))

    # 1. idle: calm breathing, gentle arm sway, ribbons fluttering
    def idle_pose(u):
        s = math.sin(u * 2 * math.pi)
        c = math.cos(u * 2 * math.pi)
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] + s * 0.005, 0.0),
            ("torso", "rotation"): q(s * 2.0, 0.0, 0.0),
            ("head", "rotation"): q(-s * 2.0, math.sin(u * 2 * math.pi) * 3.0, 0.0),
            ("arm_L", "rotation"): q(s * 4.0, 0.0, 6.0 + c * 2.0),
            ("arm_R", "rotation"): q(-s * 4.0, 0.0, -6.0 - c * 2.0),
            ("leg_L", "rotation"): q(0.0, 0.0, 0.0),
            ("leg_R", "rotation"): q(0.0, 0.0, 0.0),
            ("ribbon_L", "rotation"): q(8.0 + s * 10.0, 0.0, 4.0 + c * 4.0),
            ("ribbon_R", "rotation"): q(8.0 + c * 10.0, 0.0, -4.0 - s * 4.0),
        }
    make_clip("idle", 2.0, 9, idle_pose)

    # 2. walk: gentle child stride
    def walk_pose(u):
        s = math.sin(u * 2 * math.pi)
        b = abs(math.sin(u * 2 * math.pi))
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] + b * 0.014, 0.0),
            ("torso", "rotation"): q(6.0, -s * 6.0, s * 2.0),
            ("head", "rotation"): q(-3.0, s * 4.0, 0.0),
            ("leg_L", "rotation"): q(s * 28.0, 0.0, 0.0),
            ("leg_R", "rotation"): q(-s * 28.0, 0.0, 0.0),
            ("arm_L", "rotation"): q(-s * 24.0, 0.0, 8.0),
            ("arm_R", "rotation"): q(s * 24.0, 0.0, -8.0),
            ("ribbon_L", "rotation"): q(18.0 + b * 14.0, 0.0, 6.0 + s * 6.0),
            ("ribbon_R", "rotation"): q(18.0 + b * 14.0, 0.0, -6.0 + s * 6.0),
        }
    make_clip("walk", 0.72, 9, walk_pose)

    # 3. run: brisk energetic Ming child sprint with streaming ribbons
    def run_pose(u):
        s = math.sin(u * 2 * math.pi)
        b = abs(math.sin(u * 2 * math.pi))
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] + b * 0.028 - 0.008, 0.0),
            ("torso", "rotation"): q(15.0 + b * 4.0, -s * 10.0, s * 3.0),
            ("head", "rotation"): q(-10.0, s * 6.0, 0.0),
            ("leg_L", "rotation"): q(s * 46.0, 0.0, 0.0),
            ("leg_R", "rotation"): q(-s * 46.0, 0.0, 0.0),
            ("arm_L", "rotation"): q(-s * 44.0 + 10.0, 0.0, 12.0),
            ("arm_R", "rotation"): q(s * 44.0 + 10.0, 0.0, -12.0),
            ("ribbon_L", "rotation"): q(44.0 + b * 18.0, 0.0, 10.0 + s * 8.0),
            ("ribbon_R", "rotation"): q(44.0 + b * 18.0, 0.0, -10.0 + s * 8.0),
        }
    make_clip("run", 0.44, 9, run_pose)

    # 4. jump: tucked legs, arms out for balance
    def jump_pose(u):
        arc = math.sin(u * math.pi)
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] + 0.025 * arc, 0.0),
            ("torso", "rotation"): q(8.0 * arc, 0.0, 0.0),
            ("head", "rotation"): q(-6.0 * arc, 0.0, 0.0),
            ("leg_L", "rotation"): q(-32.0 * arc - 12.0, 0.0, 4.0),
            ("leg_R", "rotation"): q(24.0 * arc + 10.0, 0.0, -4.0),
            ("arm_L", "rotation"): q(-26.0 * arc, 0.0, 38.0 * arc + 12.0),
            ("arm_R", "rotation"): q(-26.0 * arc, 0.0, -38.0 * arc - 12.0),
            ("ribbon_L", "rotation"): q(34.0 + 24.0 * arc, 0.0, 14.0),
            ("ribbon_R", "rotation"): q(34.0 + 24.0 * arc, 0.0, -14.0),
        }
    make_clip("jump", 0.50, 7, jump_pose)

    # 5. crouch_idle: tucked compactly to ~0.35 m total height (< 0.44 m low arch!)
    def crouch_idle_pose(u):
        s = math.sin(u * 2 * math.pi)
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] - 0.130 + s * 0.004, 0.0),
            ("pelvis", "scale"): (1.0, 0.72, 1.0),
            ("torso", "rotation"): q(30.0 + s * 2.0, 0.0, 0.0),
            ("head", "rotation"): q(-26.0, 0.0, 0.0),
            ("leg_L", "rotation"): q(-52.0, 0.0, 8.0),
            ("leg_R", "rotation"): q(-52.0, 0.0, -8.0),
            ("arm_L", "rotation"): q(-26.0, 0.0, 14.0),
            ("arm_R", "rotation"): q(-26.0, 0.0, -14.0),
            ("ribbon_L", "rotation"): q(20.0 + s * 6.0, 0.0, 6.0),
            ("ribbon_R", "rotation"): q(20.0 - s * 6.0, 0.0, -6.0),
        }
    make_clip("crouch_idle", 1.6, 7, crouch_idle_pose)

    # 6. crouch_walk: stealth low waddle under tables/arches/culvert
    def crouch_walk_pose(u):
        s = math.sin(u * 2 * math.pi)
        b = abs(math.sin(u * 2 * math.pi))
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] - 0.130 + b * 0.012, 0.0),
            ("pelvis", "scale"): (1.0, 0.72, 1.0),
            ("torso", "rotation"): q(34.0, -s * 8.0, s * 4.0),
            ("head", "rotation"): q(-28.0, s * 6.0, 0.0),
            ("leg_L", "rotation"): q(-48.0 + s * 26.0, 0.0, 8.0),
            ("leg_R", "rotation"): q(-48.0 - s * 26.0, 0.0, -8.0),
            ("arm_L", "rotation"): q(-34.0 - s * 18.0, 0.0, 14.0),
            ("arm_R", "rotation"): q(-34.0 + s * 18.0, 0.0, -14.0),
            ("ribbon_L", "rotation"): q(30.0 + b * 10.0, 0.0, 8.0),
            ("ribbon_R", "rotation"): q(30.0 + b * 10.0, 0.0, -8.0),
        }
    make_clip("crouch_walk", 0.64, 9, crouch_walk_pose)

    # 7. pull_idle: child reaching UP high to grip the cart handle (人小柄高)
    def pull_idle_pose(u):
        s = math.sin(u * 2 * math.pi)
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] - 0.012, 0.0),
            ("torso", "rotation"): q(-10.0 + s * 2.0, 0.0, 0.0),
            ("head", "rotation"): q(6.0, 0.0, 0.0),
            ("arm_L", "rotation"): q(-112.0, 0.0, -8.0),
            ("arm_R", "rotation"): q(-112.0, 0.0, 8.0),
            ("leg_L", "rotation"): q(14.0, 0.0, 0.0),
            ("leg_R", "rotation"): q(-14.0, 0.0, 0.0),
            ("ribbon_L", "rotation"): q(16.0 + s * 6.0, 0.0, 6.0),
            ("ribbon_R", "rotation"): q(16.0 - s * 6.0, 0.0, -6.0),
        }
    make_clip("pull_idle", 1.2, 7, pull_idle_pose)

    # 8. pull_walk: leaning & straining while hauling the red-cloth cart
    def pull_walk_pose(u):
        s = math.sin(u * 2 * math.pi)
        b = abs(math.sin(u * 2 * math.pi))
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] - 0.022 + b * 0.014, 0.0),
            ("torso", "rotation"): q(-16.0 - b * 4.0, s * 6.0, 0.0),
            ("head", "rotation"): q(12.0, -s * 4.0, 0.0),
            ("arm_L", "rotation"): q(-118.0 + b * 6.0, 0.0, -8.0),
            ("arm_R", "rotation"): q(-118.0 + b * 6.0, 0.0, 8.0),
            ("leg_L", "rotation"): q(s * 30.0, 0.0, 0.0),
            ("leg_R", "rotation"): q(-s * 30.0, 0.0, 0.0),
            ("ribbon_L", "rotation"): q(26.0 + b * 12.0, 0.0, 8.0),
            ("ribbon_R", "rotation"): q(26.0 + b * 12.0, 0.0, -8.0),
        }
    make_clip("pull_walk", 0.68, 9, pull_walk_pose)

    # 9. aim: raising right arm back with clay bottle, sighting target
    def aim_pose(u):
        s = math.sin(u * 2 * math.pi)
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] - 0.015, 0.0),
            ("torso", "rotation"): q(6.0, -24.0 + s * 3.0, 0.0),
            ("head", "rotation"): q(-4.0, 22.0, 0.0),
            ("arm_L", "rotation"): q(-74.0, 12.0, 14.0),
            ("arm_R", "rotation"): q(-146.0 + s * 4.0, -10.0, -18.0),
            ("leg_L", "rotation"): q(-16.0, 0.0, 0.0),
            ("leg_R", "rotation"): q(16.0, 0.0, 0.0),
            ("ribbon_L", "rotation"): q(22.0, 0.0, 8.0),
            ("ribbon_R", "rotation"): q(22.0, 0.0, -8.0),
        }
    make_clip("aim", 1.0, 7, aim_pose)

    # 10. throw: crisp overhand bottle release
    def throw_pose(u):
        swing = math.sin(min(1.0, u * 1.4) * math.pi * 0.5)
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] - 0.010, 0.0),
            ("torso", "rotation"): q(12.0 * swing, -24.0 + 48.0 * swing, 0.0),
            ("head", "rotation"): q(-6.0 * swing, 20.0 - 30.0 * swing, 0.0),
            ("arm_L", "rotation"): q(-50.0 + 60.0 * swing, 0.0, 16.0),
            ("arm_R", "rotation"): q(-148.0 + 112.0 * swing, 0.0, -12.0),
            ("leg_L", "rotation"): q(-18.0, 0.0, 0.0),
            ("leg_R", "rotation"): q(18.0, 0.0, 0.0),
            ("ribbon_L", "rotation"): q(32.0 + 18.0 * swing, 0.0, 10.0),
            ("ribbon_R", "rotation"): q(32.0 + 18.0 * swing, 0.0, -10.0),
        }
    make_clip("throw", 0.40, 7, throw_pose)

    # 11. knock: two crisp knocks aligned to North Tower door (0.00s & 0.20s inside 0.60s)
    def knock_pose(u):
        # Two knocks at u ≈ 0.12 and u ≈ 0.46
        k1 = math.exp(-((u - 0.12) / 0.08) ** 2)
        k2 = math.exp(-((u - 0.46) / 0.08) ** 2)
        tap = max(k1, k2)
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1], 0.0),
            ("torso", "rotation"): q(6.0 + tap * 5.0, 0.0, 0.0),
            ("head", "rotation"): q(-6.0, 0.0, 0.0),
            ("arm_L", "rotation"): q(-10.0, 0.0, 8.0),
            ("arm_R", "rotation"): q(-96.0 - tap * 24.0, 0.0, -6.0),
            ("leg_L", "rotation"): q(0.0, 0.0, 0.0),
            ("leg_R", "rotation"): q(0.0, 0.0, 0.0),
            ("ribbon_L", "rotation"): q(14.0 + tap * 8.0, 0.0, 4.0),
            ("ribbon_R", "rotation"): q(14.0 + tap * 8.0, 0.0, -4.0),
        }
    make_clip("knock", 0.60, 13, knock_pose)

    # 12. offer: holding out needle pouch & compass gently with both hands at the tower desk
    def offer_pose(u):
        s = math.sin(u * 2 * math.pi)
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] - 0.006, 0.0),
            ("torso", "rotation"): q(10.0 + s * 2.0, 0.0, 0.0),
            ("head", "rotation"): q(-4.0, 0.0, 0.0),
            ("arm_L", "rotation"): q(-76.0 + s * 3.0, -14.0, 6.0),
            ("arm_R", "rotation"): q(-76.0 + s * 3.0, 14.0, -6.0),
            ("leg_L", "rotation"): q(0.0, 0.0, 0.0),
            ("leg_R", "rotation"): q(0.0, 0.0, 0.0),
            ("ribbon_L", "rotation"): q(12.0 + s * 6.0, 0.0, 4.0),
            ("ribbon_R", "rotation"): q(12.0 - s * 6.0, 0.0, -4.0),
        }
    make_clip("offer", 1.2, 7, offer_pose)

    # 13. listen: twig-snap / dog-ear attentive head tilt without blocking stride
    def listen_pose(u):
        s = math.sin(u * math.pi)
        return {
            ("pelvis", "translation"): (0.0, pelvis_rest[1] - 0.014 * s, 0.0),
            ("torso", "rotation"): q(6.0 * s, 10.0 * s, 0.0),
            ("head", "rotation"): q(-4.0 * s, 24.0 * s, 12.0 * s),
            ("arm_L", "rotation"): q(-24.0 * s, 0.0, 18.0 * s),
            ("arm_R", "rotation"): q(-24.0 * s, 0.0, -18.0 * s),
            ("leg_L", "rotation"): q(0.0, 0.0, 0.0),
            ("leg_R", "rotation"): q(0.0, 0.0, 0.0),
            ("ribbon_L", "rotation"): q(16.0 + 10.0 * s, 0.0, 10.0 * s),
            ("ribbon_R", "rotation"): q(16.0 + 10.0 * s, 0.0, -10.0 * s),
        }
    make_clip("listen", 0.55, 7, listen_pose)

    return anims


def main():
    atlas = PaletteAtlas(cell_px=4)
    parts = {
        "pelvis": build_pelvis(),
        "torso": build_torso(),
        "head": build_head(),
        "bun_L": build_bun(-1),
        "bun_R": build_bun(1),
        "ribbon_L": build_ribbon(),
        "ribbon_R": build_ribbon(),
        "arm_L": build_arm(False),
        "arm_R": build_arm(True),
        "leg_L": build_leg(False),
        "leg_R": build_leg(True),
    }

    # Two-pass UV build: register all colors first, then resolve exact texel-center UVs once atlas size is final!
    part_prims = {k: g.build_primitives_deferred(atlas, bake_ao=True) for k, g in parts.items()}
    resolve_deferred_uvs(part_prims, atlas)

    glb = GlbBuilder(generator="tools/build-xiaoman-character.py")
    sampler_nearest = glb.add_sampler(mag=9728, min_f=9728, wrap_s=33071, wrap_t=33071)
    tex_pal = glb.add_png_texture(atlas.to_png(), sampler_nearest, name="xiaoman_voxel_palette")

    # Bright self-luminous character materials (stand out crisply against dark realistic scenes)
    mat_main = glb.add_material(
        "M_xiaoman_bright",
        base_color=(1.0, 1.0, 1.0, 1.0),
        metallic=0.0,
        roughness=0.72,
        base_tex=tex_pal,
        emissive_tex=tex_pal,
        emissive_factor=(0.24, 0.21, 0.18),
    )
    mat_brass = glb.add_material(
        "M_xiaoman_brass",
        base_color=(1.0, 1.0, 1.0, 1.0),
        metallic=0.45,
        roughness=0.34,
        base_tex=tex_pal,
        emissive_tex=tex_pal,
        emissive_factor=(0.45, 0.36, 0.16),
    )
    mat_map = {"main": mat_main, "brass": mat_brass}

    meshes = {}
    total_tris = 0
    for name, by_mat in part_prims.items():
        plist = [(prim, mat_map[mtag]) for mtag, prim in by_mat.items()]
        for prim, _ in plist:
            total_tris += len(prim["indices"]) // 3
        meshes[name] = glb.add_mesh("mesh_" + name, plist)

    # Hierarchical skeleton matching exact joint pivots (meters)
    nodes = {}
    nodes["root"] = glb.add_node("root", translation=(0.0, 0.0, 0.0))
    nodes["pelvis"] = glb.add_node("pelvis", mesh=meshes["pelvis"],
                                   translation=(0.0, 10.0 * VS, 0.0), parent=nodes["root"])
    nodes["torso"] = glb.add_node("torso", mesh=meshes["torso"],
                                  translation=(0.0, 1.0 * VS, 0.0), parent=nodes["pelvis"])
    nodes["head"] = glb.add_node("head", mesh=meshes["head"],
                                 translation=(0.0, 7.2 * VS, 0.0), parent=nodes["torso"])
    nodes["bun_L"] = glb.add_node("bun_L", mesh=meshes["bun_L"],
                                  translation=(-4.7 * VS, 7.2 * VS, -0.6 * VS), parent=nodes["head"])
    nodes["bun_R"] = glb.add_node("bun_R", mesh=meshes["bun_R"],
                                  translation=(4.7 * VS, 7.2 * VS, -0.6 * VS), parent=nodes["head"])
    nodes["ribbon_L"] = glb.add_node("ribbon_L", mesh=meshes["ribbon_L"],
                                     translation=(-0.3 * VS, -1.0 * VS, -2.0 * VS), parent=nodes["bun_L"])
    nodes["ribbon_R"] = glb.add_node("ribbon_R", mesh=meshes["ribbon_R"],
                                     translation=(0.3 * VS, -1.0 * VS, -2.0 * VS), parent=nodes["bun_R"])
    nodes["arm_L"] = glb.add_node("arm_L", mesh=meshes["arm_L"],
                                  translation=(-4.4 * VS, 5.6 * VS, 0.0), parent=nodes["torso"])
    nodes["arm_R"] = glb.add_node("arm_R", mesh=meshes["arm_R"],
                                  translation=(4.4 * VS, 5.6 * VS, 0.0), parent=nodes["torso"])
    nodes["hand_R_socket"] = glb.add_node("hand_R_socket",
                                          translation=(0.0, -5.6 * VS, 0.5 * VS), parent=nodes["arm_R"])
    nodes["leg_L"] = glb.add_node("leg_L", mesh=meshes["leg_L"],
                                  translation=(-1.7 * VS, 0.0, 0.0), parent=nodes["pelvis"])
    nodes["leg_R"] = glb.add_node("leg_R", mesh=meshes["leg_R"],
                                  translation=(1.7 * VS, 0.0, 0.0), parent=nodes["pelvis"])

    anims = build_animations(nodes)
    for anim_name, tracks in anims:
        glb.add_animation(anim_name, tracks)

    out_dir = os.path.join(ROOT, "assets", "xiaoman3d")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "xiaoman.glb")
    nbytes = glb.save(out_path)
    print(f"[xiaoman-voxel] saved {out_path}: {nbytes}B, {total_tris} tris, {len(atlas.colors)} palette colors, {len(anims)} animations")


if __name__ == "__main__":
    main()
