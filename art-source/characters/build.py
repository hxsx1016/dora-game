"""Export the playable character cels, running cycles and grounded transitions.

Run with Python 3 and Pillow. Rig coordinates are measured in the trimmed
running source cel. The output atlases keep one planted-heel baseline.
"""

from dataclasses import dataclass
from math import cos, hypot, pi, sin, sqrt
from pathlib import Path
from xml.etree import ElementTree as XML

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter


HERE = Path(__file__).resolve().parent
ART = HERE.parents[1] / "assets" / "art"
FRAMES = 160
COLUMNS = 10
GUTTER = 2
TRANSITION_PHASES = 8
TRANSITION_LEVELS = 12
SLIDE_FRAMES = 64
SLIDE_SIZE = (300, 198)
# A small midtone lift keeps the original cloth and skin hues readable at dusk.
MIDTONES = [value + round(9 * value * (255 - value) / 16256) for value in range(256)] * 3


def grid(name, columns, rows):
    with Image.open(HERE / name) as source:
        w, h = source.size
        source = source.convert("RGBA")
        for row in range(rows):
            for col in range(columns):
                yield source.crop(
                    (col * w // columns, row * h // rows,
                     (col + 1) * w // columns, (row + 1) * h // rows)
                )


def trim(image):
    original = image.getchannel("A")
    mask = original.point(lambda a: 255 if a >= 215 else 0)
    bounds = mask.getbbox()
    if bounds is None:
        raise ValueError("Empty character cel")
    edge = mask.filter(ImageFilter.MinFilter(9))
    cleaned = []
    for (r, g, b, _), opaque, interior in zip(image.getdata(), mask.getdata(), edge.getdata()):
        matte_fringe = min(r, g, b) < 45 and max(r, g, b) - min(r, g, b) > 96
        cleaned.append(0 if matte_fringe and not interior else opaque)
    mask.putdata(cleaned)
    image.putalpha(mask)
    return image.crop(bounds)


def cut(image, polygon, darken=1):
    mask = Image.new("L", image.size)
    ImageDraw.Draw(mask).polygon(polygon, fill=255)
    mask = ImageChops.multiply(mask, image.getchannel("A"))
    part = ImageEnhance.Brightness(image).enhance(darken) if darken < 1 else image.copy()
    part.putalpha(mask)
    return part


def add(point, offset):
    return point[0] + offset[0], point[1] + offset[1]


def rotate(vector, angle):
    x, y = vector
    return x * cos(angle) - y * sin(angle), x * sin(angle) + y * cos(angle)


def draw_bone(canvas, part, source_a, source_b, target_a, target_b):
    """Place a textured part using the two joints that bound it."""
    sx, sy = source_b[0] - source_a[0], source_b[1] - source_a[1]
    tx, ty = target_b[0] - target_a[0], target_b[1] - target_a[1]
    squared = tx * tx + ty * ty
    p = (sx * tx + sy * ty) / squared
    q = (sy * tx - sx * ty) / squared
    x_shift = source_a[0] - p * target_a[0] + q * target_a[1]
    y_shift = source_a[1] - q * target_a[0] - p * target_a[1]
    warped = part.transform(
        canvas.size, Image.Transform.AFFINE, (p, -q, x_shift, q, p, y_shift),
        Image.Resampling.BICUBIC,
    )
    canvas.alpha_composite(warped)


def draw_rotated(canvas, part, source_pivot, target_pivot, angle):
    tangent = (40, 0)
    draw_bone(canvas, part, source_pivot, add(source_pivot, tangent),
              target_pivot, add(target_pivot, rotate(tangent, angle)))


@dataclass(frozen=True)
class Rig:
    field: tuple
    cel: tuple
    pelvis: tuple
    knee: tuple
    ankle: tuple
    shoulders: tuple
    hip_height: int
    stride: int
    rise: int
    torso: tuple
    near_arm: tuple
    far_arm: tuple
    thigh: tuple
    shin: tuple
    boot: tuple


SOLDIER = Rig(
    field=(290, 323), cel=(180, 200), pelvis=(121, 182), knee=(174, 234), ankle=(197, 280),
    shoulders=((112, 96), (151, 107)), hip_height=109, stride=78, rise=55,
    torso=((123, 0), (204, 0), (204, 72), (182, 78), (166, 112), (158, 146),
           (157, 171), (177, 195), (145, 191), (125, 216), (91, 221), (76, 207),
           (12, 219), (26, 190), (64, 174), (84, 123), (81, 98), (98, 74)),
    near_arm=((93, 74), (130, 77), (137, 98), (114, 113), (87, 119), (78, 145),
              (82, 156), (65, 164), (49, 150), (49, 93)),
    far_arm=((142, 100), (166, 97), (171, 119), (181, 125), (204, 109), (226, 114),
             (229, 141), (196, 157), (149, 159), (143, 137)),
    thigh=((107, 174), (143, 178), (168, 190), (183, 202), (193, 218), (198, 238),
           (191, 253), (167, 257), (154, 247), (135, 225), (114, 217)),
    shin=((165, 228), (189, 230), (198, 249), (216, 279), (210, 294),
          (193, 295), (182, 278), (174, 253), (164, 245)),
    boot=((181, 268), (206, 265), (216, 280), (237, 271), (237, 312),
          (193, 312), (181, 300), (179, 280)),
)

CHILD = Rig(
    field=(266, 305), cel=(144, 164), pelvis=(106, 180), knee=(147, 225), ankle=(159, 268),
    shoulders=((83, 101), (131, 110)), hip_height=101, stride=62, rise=56,
    torso=((75, 0), (180, 0), (186, 71), (167, 91), (150, 115), (150, 142),
           (137, 152), (124, 187), (110, 197), (73, 200), (43, 189), (40, 168),
           (59, 150), (62, 126), (55, 108), (57, 81), (76, 63)),
    near_arm=((63, 75), (102, 77), (111, 100), (86, 119), (61, 112), (48, 131),
              (49, 153), (28, 156), (16, 133), (29, 102)),
    far_arm=((122, 101), (148, 104), (156, 119), (172, 100), (191, 96), (192, 131),
             (171, 145), (145, 151), (127, 141)),
    thigh=((80, 177), (113, 178), (144, 184), (154, 197), (161, 222), (156, 244),
           (135, 248), (121, 230), (91, 220)),
    shin=((134, 222), (153, 222), (163, 239), (170, 269), (172, 280),
          (151, 281), (142, 263), (136, 240)),
    boot=((145, 256), (169, 255), (171, 269), (192, 267), (192, 295),
          (146, 295), (142, 284)),
)


def kneel(hip, ankle, upper, lower):
    dx, dy = ankle[0] - hip[0], ankle[1] - hip[1]
    separation = hypot(dx, dy)
    reach = min(separation, upper + lower - 0.25)
    ux, uy = dx / separation, dy / separation
    along = (upper * upper + reach * reach - lower * lower) / (2 * reach)
    forward = sqrt(max(0, upper * upper - along * along))
    knee = hip[0] + ux * along + uy * forward, hip[1] + uy * along - ux * forward
    return knee, add(hip, (reach * ux, reach * uy))


def boot_path(phase, rig):
    contact = 0.46
    if phase < contact:
        progress = phase / contact
        return rig.stride * (1 - 2 * progress), 0, 0
    swing = (phase - contact) / (1 - contact)
    eased = swing * swing * (3 - 2 * swing)
    lift = sin(pi * swing)
    return rig.stride * (2 * eased - 1), rig.rise * lift, -0.30 * lift * cos(pi * swing)


def running_frames(image, rig, samples):
    torso = cut(image, rig.torso)
    near_arm = cut(image, rig.near_arm)
    far_arm = cut(image, rig.far_arm, 0.73)
    legs = [
        tuple(cut(image, polygon, tint) for polygon in (rig.thigh, rig.shin, rig.boot))
        for tint in (0.70, 1)
    ]
    upper = hypot(rig.knee[0] - rig.pelvis[0], rig.knee[1] - rig.pelvis[1])
    lower = hypot(rig.ankle[0] - rig.knee[0], rig.ankle[1] - rig.knee[1])
    boot_height = image.height - rig.ankle[1]
    baseline = rig.field[1] - 1

    for phase, effort in samples:
        turn = phase * 2 * pi
        relax = 1 - effort
        bob = 6 * (0.5 - 0.5 * cos(2 * turn)) * effort + 6 * relax
        hip = (rig.field[0] * 0.5, baseline - rig.hip_height - bob)
        lean = 0.036 * sin(2 * turn + 0.33) * effort - 0.06 * relax
        shoulders = [
            add(hip, rotate((x - rig.pelvis[0], y - rig.pelvis[1]), lean))
            for x, y in rig.shoulders
        ]
        canvas = Image.new("RGBA", rig.field)

        def draw_leg(parts, limb_phase, offset):
            stride, lift, angle = boot_path(limb_phase % 1, rig)
            socket = add(hip, (offset, 0))
            ankle = (hip[0] + stride * effort + offset * relax * 1.5,
                     baseline - boot_height - lift * effort)
            knee, ankle = kneel(socket, ankle, upper, lower)
            thigh, shin, boot = parts
            draw_rotated(canvas, boot, rig.ankle, ankle, angle * effort)
            draw_bone(canvas, shin, rig.knee, rig.ankle, knee, ankle)
            draw_bone(canvas, thigh, rig.pelvis, rig.knee, socket, knee)

        swing = 0.25 * cos(turn) * effort
        draw_leg(legs[0], phase + 0.5, -5)
        draw_rotated(canvas, far_arm, rig.shoulders[1], shoulders[1], lean - swing + 0.87 * relax)
        draw_leg(legs[1], phase, 5)
        draw_rotated(canvas, torso, rig.pelvis, hip, lean)
        draw_rotated(canvas, near_arm, rig.shoulders[0], shoulders[0], lean + swing - 0.52 * relax)
        yield canvas.resize(rig.cel, Image.Resampling.LANCZOS)


def finish_pixels(cel, step=2):
    """Sample finer pixel clusters while preserving the engine's frame rectangles."""
    grid_size = round(cel.width / step), round(cel.height / step)
    sample = cel.resize(grid_size, Image.Resampling.BOX)
    alpha = sample.getchannel("A").point(lambda value: 255 if value >= 115 else 0)
    toned = sample.convert("RGB").point(MIDTONES)
    toned.putalpha(alpha)
    clean = Image.composite(toned, Image.new("RGBA", grid_size), alpha)
    return clean.resize(cel.size, Image.Resampling.NEAREST)


def motion_atlas(name, frames, size, count=FRAMES, columns=COLUMNS):
    w, h = size
    tile_w, tile_h = w + 2 * GUTTER, h + 2 * GUTTER
    atlas = Image.new("RGBA", (tile_w * columns, tile_h * ((count + columns - 1) // columns)))
    for index, frame in enumerate(frames):
        x = (index % columns) * tile_w + GUTTER
        y = (index // columns) * tile_h + GUTTER
        atlas.paste(finish_pixels(frame), (x, y))
    atlas.save(ART / (name + ".png"), optimize=True)


def pose_cel(image, height, center=None, canvas_size=None):
    if center is None:
        band = image.getchannel("A").crop((0, round(image.height * .48), image.width, round(image.height * .66)))
        masses = [sum(band.crop((x, 0, x + 1, band.height)).getdata()) for x in range(band.width)]
        center = sum(x * mass for x, mass in enumerate(masses)) / (sum(masses) * image.width)
    scale = height / image.height
    w = round(image.width * scale)
    image = image.resize((w, height), Image.Resampling.LANCZOS)
    radius = max(round(w * center), round(w * (1 - center))) + 3
    dimensions = canvas_size or (2 * radius, height)
    canvas = Image.new("RGBA", dimensions)
    canvas.paste(image, (round(dimensions[0] * .5 - w * center), dimensions[1] - height))
    return canvas


def pose_atlas(cels):
    width = 1536
    x, y, row_height = GUTTER, GUTTER, 0
    placements = []
    for key, image in cels.items():
        if x + image.width + GUTTER > width:
            x, y, row_height = GUTTER, y + row_height + 2 * GUTTER, 0
        placements.append((key, image, x, y))
        x += image.width + 2 * GUTTER
        row_height = max(row_height, image.height)
    atlas = Image.new("RGBA", (width, y + row_height + GUTTER))
    manifest = XML.Element("A", A="actors-hd.png")
    for key, image, x, y in placements:
        atlas.paste(finish_pixels(image), (x, y))
        XML.SubElement(manifest, "B", A=key, B=f"{x},{y},{image.width},{image.height}")
    atlas.save(ART / "actors-hd.png", optimize=True)
    XML.indent(manifest, "  ")
    (ART / "actors-hd.clip").write_text(XML.tostring(manifest, encoding="unicode") + "\n", encoding="utf-8")


def export_duo():
    """Apply the same finish to holding hands and carrying poses."""
    manifest = XML.parse(ART / "actors_extra.clip").getroot()
    atlas_path = ART / manifest.attrib["A"]
    with Image.open(atlas_path) as image:
        atlas = image.convert("RGBA")
    with Image.open(HERE / "duo-poses.png") as source:
        offset = 0
        for frame in manifest:
            if not frame.attrib["A"].startswith("duo_"):
                continue
            x, y, w, h = map(int, frame.attrib["B"].split(","))
            cel = source.crop((offset, 0, offset + w, h))
            atlas.paste(finish_pixels(cel, step=1.42), (x, y))
            offset += w
    atlas.save(atlas_path, optimize=True)


def ease(t):
    return t * t * (3 - 2 * t)


def warp(image, source, target):
    """Follow anatomical landmarks with a small inverse displacement mesh."""
    width, height = image.size
    pairs = [(tx, ty, sx - tx, sy - ty) for (sx, sy), (tx, ty) in zip(source, target)]
    xs = [*range(0, width, 8), width]
    ys = [*range(0, height, 8), height]
    points = {}
    for y in ys:
        for x in xs:
            weights = [1 / (((x - tx) ** 2 + (y - ty) ** 2 + 20) ** 2)
                       for tx, ty, _, _ in pairs]
            total = sum(weights)
            dx = sum(w * pair[2] for w, pair in zip(weights, pairs)) / total
            dy = sum(w * pair[3] for w, pair in zip(weights, pairs)) / total
            points[x, y] = x + dx, y + dy
    mesh = [
        ((x0, y0, x1, y1), points[x0, y0] + points[x0, y1] + points[x1, y1] + points[x1, y0])
        for y0, y1 in zip(ys, ys[1:]) for x0, x1 in zip(xs, xs[1:])
    ]
    return image.transform(image.size, Image.Transform.MESH, mesh, Image.Resampling.BILINEAR)


def morph(first, second, first_joints, second_joints, t):
    if t <= 0:
        return first
    if t >= 1:
        return second
    joints = [((1 - t) * sx + t * ex, (1 - t) * sy + t * ey)
              for (sx, sy), (ex, ey) in zip(first_joints, second_joints)]
    first = warp(first.convert("RGBa"), first_joints, joints)
    second = warp(second.convert("RGBa"), second_joints, joints)
    blended = Image.blend(first, second, t).convert("RGBA")
    # Blend detail on the aligned poses, but keep one opaque silhouette.
    silhouette = (first if t < 0.5 else second).getchannel("a")
    blended.putalpha(silhouette)
    return Image.composite(blended, Image.new("RGBA", blended.size), silhouette.point(lambda a: 255 if a else 0))


def standing_in_canvas(standing, size):
    width, height = size
    w = round(standing.width * height / standing.height)
    standing = standing.resize((w, height), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", size)
    canvas.paste(standing, ((width - w) // 2, 0))
    return canvas


def centerline(cel):
    mask = cel.getchannel("A")
    _, top, _, foot = mask.getbbox()
    joints = []
    for fraction in (0.13, 0.30, 0.54, 0.72, 0.94):
        y = round(top + (foot - top - 1) * fraction)
        band = mask.crop((0, y - 2, cel.width, y + 3)).getbbox()
        joints.append(((band[0] + band[2]) * 0.5, y))
    return joints


def transition_frames(image, rig, idle):
    idle = standing_in_canvas(idle, rig.cel)
    idle_joints = centerline(idle)
    samples = [
        (phase / TRANSITION_PHASES, level / (TRANSITION_LEVELS + 1))
        for level in range(1, TRANSITION_LEVELS + 1) for phase in range(TRANSITION_PHASES)
    ]
    for (_, effort), pose in zip(samples, running_frames(image, rig, samples)):
        if effort < 0.42:
            pose = morph(idle, pose, idle_joints, centerline(pose), ease(effort / 0.42))
        yield pose


# Helmet, face, collar, shoulder, hip, forward elbow/hand, rear elbow/hand,
# back knee/boot and leading knee/heel/toe in the final 300x198 slide cel.
SLIDE_JOINTS = (
    ((151, 23), (161, 34), (150, 48), (140, 57), (149, 120), (160, 76), (174, 96),
     (138, 81), (158, 99), (138, 148), (139, 195), (159, 148), (153, 196), (178, 194)),
    ((151, 70), (160, 80), (145, 92), (133, 100), (144, 146), (178, 110), (207, 100),
     (106, 122), (85, 146), (129, 172), (131, 194), (194, 160), (232, 193), (251, 182)),
    ((127, 94), (137, 105), (123, 116), (115, 127), (142, 166), (168, 129), (200, 123),
     (106, 155), (98, 193), (137, 180), (147, 195), (183, 170), (251, 196), (260, 182)),
    ((152, 80), (165, 92), (149, 99), (133, 109), (143, 156), (184, 121), (213, 113),
     (119, 137), (101, 164), (143, 181), (153, 195), (196, 151), (232, 190), (250, 178)),
    ((158, 63), (174, 78), (154, 92), (139, 109), (126, 145), (177, 119), (212, 124),
     (129, 148), (141, 170), (109, 181), (116, 195), (170, 150), (148, 195), (169, 194)),
)


def slide_frames(cels):
    idle = standing_in_canvas(cels["soldier_idle"], SLIDE_SIZE)
    low = cels["soldier_slide_1"]
    low_joints = SLIDE_JOINTS[2]
    # Let the shoulder sink and carry forward while the supporting heel stays planted.
    loaded_joints = [(x + dx, y + dy) for (x, y), (dx, dy) in zip(low_joints,
                     ((7, 4), (8, 4), (7, 5), (8, 4), (4, 1), (7, 2), (9, -1),
                      (3, 1), (-3, 0), (1, 0), (0, 0), (2, 0), (0, 0), (0, 0)))]
    loaded = warp(low, low_joints, loaded_joints)
    keys = (
        (0.00, idle, SLIDE_JOINTS[0]),
        (0.12, cels["soldier_slide_0"], SLIDE_JOINTS[1]),
        (0.27, low, low_joints),
        (0.57, loaded, loaded_joints),
        (0.75, cels["soldier_slide_2"], SLIDE_JOINTS[3]),
        (0.88, cels["soldier_slide_3"], SLIDE_JOINTS[4]),
        (1.00, idle, SLIDE_JOINTS[0]),
    )
    segment = 0
    for index in range(SLIDE_FRAMES):
        phase = index / (SLIDE_FRAMES - 1)
        if phase > keys[segment + 1][0]:
            segment += 1
        start, first, first_joints = keys[segment]
        end, second, second_joints = keys[segment + 1]
        yield morph(first, second, first_joints, second_joints, ease((phase - start) / (end - start)))


def main():
    sources = {}
    for name, order in (
        ("zhoushu.png", (
            "soldier_idle", "soldier_run", "soldier_step", "soldier_roll",
            "soldier_cover", "soldier_push", "soldier_hold", "soldier_offer",
            "soldier_knock", "soldier_hit", "soldier_fire", "soldier_push_step",
        )),
        ("xiaoman.png", (
            "child_idle", "child_run", "child_step", "child_fear",
            "child_crouch", "child_crouch_step", "child_peek", "child_pull",
            "child_aim", "child_throw", "child_knock", "child_offer",
        )),
    ):
        sources.update((key, trim(cel)) for key, cel in zip(order, grid(name, 4, 3)))
    extra_names = ("soldier_fire_run", "soldier_fire_run_step", "child_pull_step", "child_peek")
    sources.update((key, trim(cel)) for key, cel in zip(extra_names, grid("extra-poses.png", 2, 2)))

    cels = {
        key: pose_cel(source, 198 if key.startswith("soldier") else 144,
                      .5 if key == "soldier_roll" else None)
        for key, source in sources.items()
    }
    for index, (image, height, center) in enumerate(zip(
        grid("zhoushu-slide.png", 2, 2), (153, 128, 141, 157), (.40, .37, .37, .47),
    )):
        cels[f"soldier_slide_{index}"] = pose_cel(trim(image), height, center, SLIDE_SIZE)

    pose_atlas(cels)
    for name, key, rig in (("zhoushu", "soldier", SOLDIER), ("xiaoman", "child", CHILD)):
        source = sources[f"{key}_run"]
        samples = ((index / FRAMES, 1) for index in range(FRAMES))
        motion_atlas(f"{name}-run", running_frames(source, rig, samples), rig.cel)
        motion_atlas(f"{name}-run-transition", transition_frames(source, rig, cels[f"{key}_idle"]),
                     rig.cel, TRANSITION_LEVELS * TRANSITION_PHASES, TRANSITION_PHASES)
    motion_atlas("zhoushu-slide", slide_frames(cels), SLIDE_SIZE, SLIDE_FRAMES, 8)
    export_duo()


if __name__ == "__main__":
    main()
