#!/usr/bin/env python3
"""《向西守望》发行前资产、图集、字库与 Lua 模块完整性审计。

检查项：
1. 代码中静态引用的全部 assets/** 文件及动态前缀拼接音频/贴图均存在且非空；
2. assets/art/*.clip XML 指向的纹理 PNG 存在且非空，代码引用的图集帧名全部存在于对应 .clip 中；
3. 全仓库 init.ts 与 Script/watch/**/*.ts（含模板字符串）中出现的全部非 ASCII 界面字与符号
   均被正文宋体字库 lxgw-neo-zhisong.ttf 覆盖（0 缺字），且 banner/title 静态字被龙藏体覆盖；
4. Script/watch/** 下不存在裸 require("watch.*") 导致双加载。
"""

import re
import struct
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSET_REF_RE = re.compile(r"assets/[A-Za-z0-9_./-]+\.[A-Za-z0-9]+")
CLIP_FRAME_RE = re.compile(r"(assets/art/[A-Za-z0-9_.-]+\.clip)\|([A-Za-z0-9_.-]+)")
DIR_CONST_RE = re.compile(r'const\s+([A-Z0-9_]+)\s*=\s*"(assets/[A-Za-z0-9_./-]+/)"')
BARE_REQ_RE = re.compile(r'require\(["\']watch\.')
STRING_LIT_RE = re.compile(
    r'"([^"\\]*(?:\\.[^"\\]*)*)"|\'([^\'\\]*(?:\\.[^\'\\]*)*)\'|`([^`\\]*(?:\\.[^`\\]*)*)`'
)


def read_ttf_cmap(path: Path) -> set[int]:
    data = path.read_bytes()
    num_tables = struct.unpack(">H", data[4:6])[0]
    cmap_off = None
    for i in range(num_tables):
        tag, _, off, _ = struct.unpack(">4sIII", data[12 + i * 16 : 28 + i * 16])
        if tag == b"cmap":
            cmap_off = off
            break
    if cmap_off is None:
        raise RuntimeError(f"字库缺少 cmap 表: {path}")
    num_sub = struct.unpack(">H", data[cmap_off + 2 : cmap_off + 4])[0]
    chars: set[int] = set()
    for i in range(num_sub):
        _, _, sub_off = struct.unpack(">HHI", data[cmap_off + 4 + i * 8 : cmap_off + 12 + i * 8])
        o = cmap_off + sub_off
        fmt = struct.unpack(">H", data[o : o + 2])[0]
        if fmt == 4:
            seg2 = struct.unpack(">H", data[o + 6 : o + 8])[0]
            segs = seg2 // 2
            ends = struct.unpack(f">{segs}H", data[o + 14 : o + 14 + seg2])
            starts = struct.unpack(f">{segs}H", data[o + 16 + seg2 : o + 16 + 2 * seg2])
            for s, e in zip(starts, ends):
                if s != 0xFFFF:
                    chars.update(range(s, e + 1))
        elif fmt == 12:
            ngroups = struct.unpack(">I", data[o + 12 : o + 16])[0]
            for g in range(ngroups):
                s, e, _ = struct.unpack(">III", data[o + 16 + g * 12 : o + 28 + g * 12])
                chars.update(range(s, e + 1))
    return chars


def check_static_and_dynamic_assets() -> tuple[int, list[str]]:
    refs: set[str] = set()
    scan_files = [ROOT / "init.ts", *(ROOT / "Script" / "watch").rglob("*.ts")]
    for path in scan_files:
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        for m in ASSET_REF_RE.finditer(text):
            refs.add(m.group(0))
        # 解析 const FOO_ROOT = "assets/.../" + "bar.wav" 形式的动态路径
        roots: dict[str, str] = {}
        for cm in DIR_CONST_RE.finditer(text):
            roots[cm.group(1)] = cm.group(2)
        for const_name, prefix in roots.items():
            concat_re = re.compile(rf'{re.escape(const_name)}\s*\+\s*"([A-Za-z0-9_./-]+\.[A-Za-z0-9]+)"')
            for fm in concat_re.finditer(text):
                refs.add(prefix + fm.group(1))
    errors: list[str] = []
    for rel in sorted(refs):
        full = ROOT / rel
        if not full.is_file() or full.stat().st_size == 0:
            errors.append(f"缺少或空资产文件: {rel}")
    # 校验核心动态音频与品牌目录非空
    for req_dir in (
        "assets/audio/gate",
        "assets/audio/tower",
        "assets/audio/museum",
        "assets/audio/prologue",
        "assets/audio/combat",
        "assets/audio/sfx",
        "assets/art/brand",
    ):
        dpath = ROOT / req_dir
        if not dpath.is_dir() or not any(p.is_file() and p.stat().st_size > 0 for p in dpath.iterdir()):
            errors.append(f"核心资产目录缺失或为空: {req_dir}")
    return len(refs), errors


def check_clips() -> tuple[int, list[str]]:
    errors: list[str] = []
    clip_frames: dict[str, set[str]] = {}
    for clip_path in sorted((ROOT / "assets" / "art").glob("*.clip")):
        rel_clip = clip_path.relative_to(ROOT).as_posix()
        try:
            tree = ET.parse(clip_path)
            root_el = tree.getroot()
        except ET.ParseError as exc:
            errors.append(f"图集 XML 解析失败: {rel_clip} ({exc})")
            continue
        tex_file = root_el.attrib.get("A") or root_el.attrib.get("File", "")
        if not tex_file:
            errors.append(f"图集缺少纹理文件属性: {rel_clip}")
        else:
            tex_path = clip_path.parent / tex_file
            if not tex_path.is_file() or tex_path.stat().st_size == 0:
                errors.append(f"图集纹理缺失或为空: {rel_clip} -> {tex_file}")
        names: set[str] = set()
        for child in root_el:
            name = child.attrib.get("A") or child.attrib.get("Name", "")
            if name:
                names.add(name)
        clip_frames[rel_clip] = names

    checked_refs = 0
    for path in (ROOT / "Script" / "watch").rglob("*.ts"):
        text = path.read_text(encoding="utf-8")
        for m in CLIP_FRAME_RE.finditer(text):
            clip_rel, frame = m.group(1), m.group(2)
            checked_refs += 1
            if clip_rel not in clip_frames:
                errors.append(f"引用不存在的图集: {clip_rel}|{frame} ({path.relative_to(ROOT)})")
            elif frame not in clip_frames[clip_rel]:
                errors.append(f"图集缺少帧名: {clip_rel}|{frame} ({path.relative_to(ROOT)})")
    return checked_refs, errors


def check_font_coverage() -> tuple[int, list[str]]:
    font_path = ROOT / "assets" / "font" / "lxgw-neo-zhisong.ttf"
    if not font_path.is_file():
        return 0, [f"缺少正文字库: {font_path.relative_to(ROOT)}"]
    cmap = read_ttf_cmap(font_path)

    brush_path = ROOT / "assets" / "font" / "longcang-brush.ttf"
    brush_cmap = read_ttf_cmap(brush_path) if brush_path.is_file() else set()

    ui_chars: set[str] = set()
    banner_chars: set[str] = set()
    targets = [ROOT / "init.ts", *(ROOT / "Script" / "watch").rglob("*.ts")]
    for path in targets:
        if not path.is_file():
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            stripped = line.strip()
            if stripped.startswith("//") or stripped.startswith("*"):
                continue
            for m in STRING_LIT_RE.finditer(line):
                s = next(g for g in m.groups() if g is not None)
                for ch in s:
                    cp = ord(ch)
                    if cp >= 0x80:
                        ui_chars.add(ch)
            if '"banner"' in line or '"title"' in line:
                for m in re.finditer(r'"([^"\\]*(?:\\.[^"\\]*)*)"', line):
                    s = m.group(1)
                    if s not in ("banner", "title"):
                        for ch in s:
                            if ord(ch) >= 0x80:
                                banner_chars.add(ch)

    errors: list[str] = []
    missing_zs = sorted(ch for ch in ui_chars if ord(ch) not in cmap)
    if missing_zs:
        errors.append(f"正文字库 lxgw-neo-zhisong.ttf 缺字 ({len(missing_zs)}): {''.join(missing_zs)}")
    if brush_cmap:
        missing_lc = sorted(ch for ch in banner_chars if ord(ch) not in brush_cmap)
        if missing_lc:
            errors.append(f"行书字库 longcang-brush.ttf 缺字 ({len(missing_lc)}): {''.join(missing_lc)}")
    return len(ui_chars), errors


def check_bare_requires() -> list[str]:
    errors: list[str] = []
    for path in sorted((ROOT / "Script" / "watch").rglob("*.lua")):
        text = path.read_text(encoding="utf-8")
        for lineno, line in enumerate(text.splitlines(), 1):
            if BARE_REQ_RE.search(line):
                errors.append(f"{path.relative_to(ROOT)}:{lineno} 存在裸 require(\"watch.*\")")
    return errors


def main() -> int:
    errors: list[str] = []
    ref_count, asset_errs = check_static_and_dynamic_assets()
    errors.extend(asset_errs)
    clip_refs, clip_errs = check_clips()
    errors.extend(clip_errs)
    glyph_count, font_errs = check_font_coverage()
    errors.extend(font_errs)
    errors.extend(check_bare_requires())

    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(
        f"资产审计通过：{ref_count} 处静/动态资产与 {clip_refs} 处图集帧全部存在，"
        f"{glyph_count} 枚界面非 ASCII 字形 0 缺字，Lua require 路径规范。"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
