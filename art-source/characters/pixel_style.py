"""Paint the game's live 2D characters on a coarser pixel grid."""

from pathlib import Path
from xml.etree import ElementTree as XML

from PIL import Image, ImageChops, ImageColor, ImageFilter


HERE = Path(__file__).resolve().parent
SOLDIER_PIXEL = 4.5
CHILD_PIXEL = 4.3
COVERAGE = 100
PALETTE = tuple(map(ImageColor.getrgb, (
    # Ink, iron and weathered indigo cloth
    "#191c29", "#293548", "#445469", "#6d869c", "#b5c5cc",
    "#244353", "#365f79", "#508fa0", "#85bdbe",
    # Iron-red cloth, leather and straw
    "#3e2830", "#753638", "#ac4a32", "#d87d4b",
    "#382d29", "#55473e", "#644332", "#8d5d37", "#be8850",
    # Trousers, skin and undyed cloth
    "#2e3c36", "#495b43", "#6b8055", "#968d5e",
    "#a15f47", "#cf8c60", "#efb97e", "#ffdea2",
    "#686052", "#9d896c", "#c5af86", "#e8d5ab",
)))
TRANSPARENT = len(PALETTE)
INDEXED = Image.new("P", (1, 1))
INDEXED.putpalette([
    channel for rgb in PALETTE + ((0, 0, 0),) * (256 - len(PALETTE))
    for channel in rgb
])

# Helmet and hair landmarks, in the pose cels before downsampling.
# Coordinates are (head center x, top, neck); the feet and props retain their pivots.
POSE_HEADS = {
    "soldier_idle": (35, 0, 63), "soldier_run": (121, 0, 53),
    "soldier_step": (110, 0, 53), "soldier_roll": (145, 0, 84),
    "soldier_cover": (137, 0, 64), "soldier_push": (135, 0, 61),
    "soldier_hold": (85, 16, 76), "soldier_offer": (118, 0, 72),
    "soldier_knock": (130, 0, 70), "soldier_hit": (34, 0, 51),
    "soldier_fire": (112, 0, 45), "soldier_push_step": (120, 0, 58),
    "soldier_fire_run": (140, 0, 45), "soldier_fire_run_step": (148, 0, 46),
    "soldier_slide_0": (151, 45, 102), "soldier_slide_1": (130, 70, 124),
    "soldier_slide_2": (155, 57, 117), "soldier_slide_3": (154, 41, 108),
    "child_idle": (27, 0, 56), "child_run": (67, 0, 53),
    "child_step": (73, 0, 55), "child_fear": (62, 0, 70),
    "child_crouch": (189, 0, 88), "child_crouch_step": (174, 0, 87),
    "child_peek": (112, 0, 55), "child_pull": (86, 0, 56),
    "child_aim": (56, 0, 47), "child_throw": (72, 0, 52),
    "child_knock": (46, 0, 53), "child_offer": (48, 0, 53),
    "child_pull_step": (50, 0, 58),
}

# NPC and paired pose sources share the existing clip rectangles, stacked in one
# image. Only the actor tiles are present in this source sheet.
CAST_SHEETS = (
    ("sprites", 0, 1.55, ("enemy_", "scavenger_", "dog_")),
    ("actors_extra", 512, 3.4, ("enemy_", "tower_guard_", "duo_")),
    ("sprites_fe", 800, 1.45, ("carry_", "soldier_", "child_", "tower_guard_")),
)


def widen_head(cel, center, top, neck):
    """Give the head a wider silhouette, easing the change into the neck."""
    height = neck - top
    radius = round(height * 0.82)
    left, right = max(0, center - radius), min(cel.width, center + radius)
    crop = cel.crop((left, top, right, neck))
    pivot = center - left
    edge_a = round(pivot * 0.22)
    edge_b = round(pivot + (crop.width - pivot) * 0.78)
    mesh = []
    for y in range(height):
        weight = min(1, (height - y - 1) / (height * 0.34))
        scale = 1 + 0.34 * weight * weight * (3 - 2 * weight)
        dest = (0, edge_a, edge_b, crop.width)
        src = (0, pivot + (edge_a - pivot) / scale,
               pivot + (edge_b - pivot) / scale, crop.width)
        for x0, x1, u0, u1 in zip(dest, dest[1:], src, src[1:]):
            if x0 < x1:
                mesh.append(((x0, y, x1, y + 1), (u0, y, u0, y + 1, u1, y + 1, u1, y)))
    result = cel.copy()
    result.paste(crop.transform(crop.size, Image.Transform.MESH, mesh, Image.Resampling.BICUBIC),
                 (left, top))
    return result


def paint_cel(cel, pixel_size, iron_to=None):
    grid = max(1, round(cel.width / pixel_size)), max(1, round(cel.height / pixel_size))
    sampled = cel.resize(grid, Image.Resampling.BOX)
    alpha = sampled.getchannel("A").point(lambda a: 255 if a >= COVERAGE else 0)
    edge = ImageChops.subtract(alpha, alpha.filter(ImageFilter.MinFilter(3)))

    # Cool cloth takes a blue lift, and faces keep warm broad highlights.
    colors = []
    iron_row = iron_to * grid[1] / cel.height if iron_to is not None else 0
    for index, ((r, g, b, a), rim) in enumerate(zip(sampled.getdata(), edge.getdata())):
        if a < COVERAGE:
            colors.append((0, 0, 0))
            continue
        luma = (3 * r + 6 * g + b) / 10
        lift = 6 if rim else 10
        if iron_to is not None and luma < 145 and r - g <= 15 and g - b <= 21:
            # Keep the guard's iron helmet cooler and less saturated than his coat.
            helmet = index // grid[0] < iron_row
            r = luma - (4 if helmet else 13)
            g = luma + (0 if helmet else 7)
            b = luma + (14 if helmet else 23)
        elif b >= r and luma < 145:
            g += 5
            b += 12
            lift += 6
        if r > g * 1.22 and g > b:
            r += 7
        if r > 135 and r - g >= 18 and g - b >= 8:
            lift += 6
        light = 0.95 * luma + lift + 7 * min(1, luma / 48)
        colors.append(tuple(max(0, min(255, round(light + (channel - luma) * 1.34)))
                            for channel in (r, g, b)))

    flat = Image.new("RGB", grid)
    flat.putdata(colors)
    indexed = flat.quantize(palette=INDEXED, dither=Image.Dither.NONE)
    # Merge isolated variations in adjacent shades. High-contrast details
    # such as the profile, cuffs and helmet band survive the cleanup.
    indexed.paste(TRANSPARENT, (0, 0, *grid), ImageChops.invert(alpha))
    nearby = indexed.filter(ImageFilter.ModeFilter(3))
    indices = []
    for current, neighbor in zip(indexed.getdata(), nearby.getdata()):
        if current != neighbor and current < TRANSPARENT and neighbor < TRANSPARENT:
            difference = sum((a - b) ** 2 for a, b in zip(PALETTE[current], PALETTE[neighbor]))
            if difference < 52 ** 2:
                current = neighbor
        indices.append(current)
    indexed.putdata(indices)
    result = indexed.convert("RGBA")
    result.putalpha(alpha)
    return result.resize(cel.size, Image.Resampling.NEAREST)


def paint_pose(key, cel):
    soldier = key.startswith("soldier_")
    pixel_size = SOLDIER_PIXEL if soldier else CHILD_PIXEL
    center, top, neck = POSE_HEADS[key]
    return paint_cel(widen_head(cel, center, top, neck), pixel_size, neck if soldier else None)


def paint_motion(cel, soldier):
    pixel_size = SOLDIER_PIXEL if soldier else CHILD_PIXEL
    head_height = 54 if soldier else 60
    # Running, stopping and sliding all keep the head above the hands. Sample
    # mid-head (below the plume or buns) to track it across the existing motion.
    alpha = cel.getchannel("A").point(lambda a: 255 if a >= COVERAGE else 0)
    _, top, _, bottom = alpha.getbbox()
    neck = min(top + head_height, bottom)
    head = alpha.crop((0, top + head_height // 3, cel.width, top + head_height * 2 // 3))
    left, _, right, _ = head.getbbox()
    return paint_cel(widen_head(cel, (left + right) // 2, top, neck),
                     pixel_size, neck if soldier else None)


def cast_frames(art):
    for stem, offset, block, prefixes in CAST_SHEETS:
        clip = XML.parse(art / (stem + ".clip")).getroot()
        frames = {
            node.attrib["A"]: tuple(map(int, node.attrib["B"].split(",")))
            for node in clip if node.attrib["A"].startswith(prefixes)
        }
        yield art / clip.attrib["A"], offset, block, frames


def export_cast(art):
    with Image.open(HERE / "support-poses.png") as source:
        for path, offset, block, frames in cast_frames(art):
            with Image.open(path) as image:
                atlas = image.convert("RGBA")
            for key, (x, y, w, h) in frames.items():
                cel = source.crop((x, y + offset, x + w, y + offset + h))
                if not cel.getbbox():
                    raise ValueError(f"Missing source cel for {path.name}: {key}")
                size = 1 if key.startswith("dog_") else block
                atlas.paste(paint_cel(cel, size), (x, y))
            atlas.save(path, optimize=True)
