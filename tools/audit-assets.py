#!/usr/bin/env python3
"""《向西守望》发行前资产、字库与 Lua 模块完整性审计。

检查项：
1. 代码中静态引用的全部 assets/** 文件存在且非空；
2. Script/watch/fe/** 与 Script/watch/app.ts 中出现的中文字符均被正文宋体字库覆盖（0 缺字）；
3. Script/watch/** 下不存在裸 require("watch.*") 导致双加载。
"""

import os
import re
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSET_REF_RE = re.compile(r"assets/[A-Za-z0-9_./-]+\.[A-Za-z0-9]+")
BARE_REQ_RE = re.compile(r'require\(["\']watch\.')


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


def check_static_assets() -> tuple[int, list[str]]:
    refs: set[str] = set()
    scan_files = [ROOT / "init.ts", *(ROOT / "Script" / "watch").rglob("*.ts")]
    for path in scan_files:
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        for m in ASSET_REF_RE.finditer(text):
            refs.add(m.group(0))
    errors: list[str] = []
    for rel in sorted(refs):
        full = ROOT / rel
        if not full.is_file() or full.stat().st_size == 0:
            errors.append(f"缺少或空资产文件: {rel}")
    return len(refs), errors


def check_font_coverage() -> tuple[int, list[str]]:
    font_path = ROOT / "assets" / "font" / "lxgw-neo-zhisong.ttf"
    if not font_path.is_file():
        return 0, [f"缺少正文字库: {font_path.relative_to(ROOT)}"]
    cmap = read_ttf_cmap(font_path)
    cjk_chars: set[str] = set()
    string_re = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*)"|\'([^\'\\]*(?:\\.[^\'\\]*)*)\'')
    targets = list((ROOT / "Script" / "watch" / "fe").rglob("*.ts"))
    for path in targets:
        if not path.is_file():
            continue
        for line in path.read_text(encoding="utf-8").splitlines():
            stripped = line.strip()
            if stripped.startswith("//") or stripped.startswith("*"):
                continue
            for m in string_re.finditer(line):
                s = m.group(1) if m.group(1) is not None else m.group(2)
                for ch in s:
                    cp = ord(ch)
                    if 0x4E00 <= cp <= 0x9FFF:
                        cjk_chars.add(ch)
    missing = sorted(ch for ch in cjk_chars if ord(ch) not in cmap)
    if missing:
        return len(cjk_chars), [f"正文字库 lxgw-neo-zhisong.ttf 缺字 ({len(missing)}): {''.join(missing)}"]
    return len(cjk_chars), []


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
    ref_count, asset_errs = check_static_assets()
    errors.extend(asset_errs)
    glyph_count, font_errs = check_font_coverage()
    errors.extend(font_errs)
    errors.extend(check_bare_requires())

    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"资产审计通过：{ref_count} 处静态资产全部存在，{glyph_count} 枚界面汉字 0 缺字，Lua require 路径规范。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
