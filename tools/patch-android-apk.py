#!/usr/bin/env python3
"""《向西守望》Android APK 模板裁剪、二进制清单修补与资产注入工具。

对齐 Dora SSR v1.10.2 GameApk.java / GameManifest.java，并扩展以下原生游戏发行能力：
1. 动态解析 resources.arsc，定位 game_export_icon 的真实资源 ID 与 APK 内路径，
   注入统一品牌 512x512 图标（art-source/brand/icons/android/ic_launcher_512.png）；
2. 无损重写二进制 AndroidManifest.xml（保持 resources.arsc 与 classes.dex 字节级不变）：
   - 替换独立包名、versionCode、versionName、应用名、图标；
   - 默认注入 android:screenOrientation="fullUser"（允许自由横竖屏切换：横屏全屏 / 竖屏上半 16:9 舞台 + 下半宋明水墨掌机台），
     同时支持 --orientation sensorLandscape|unspecified 覆盖；
   - 重写 FileProvider / Startup / 动态权限前缀避免与官方 Dora SSR App 冲突；
   - 剔除非 LAUNCHER intent-filter（dora-ssr:// 与 ZIP 关联）以及离线单机不需要的高危权限；
3. 白名单裁剪模板 APK：移除旧签名、Dev/Test/Tools/www/Doc/dora-wa/GeneralUserGS.sf3、
   libgojni.so 与 libgodot_android.so，并按目标 ABI 筛选；
4. 严格保持 lib/*.so 与 resources.arsc 为 ZIP_STORED（适配 extractNativeLibs=false），
   供后续 zipalign -P 16（Android 15+ 16KB 页对齐）与 apksigner v2/v3 正式签名。
"""

from __future__ import annotations

import argparse
import re
import struct
import sys
import zipfile
from pathlib import Path

CHUNK_XML = 0x0003
CHUNK_STRING_POOL = 0x0001
CHUNK_RESOURCE_MAP = 0x0180
CHUNK_START_NAMESPACE = 0x0100
CHUNK_END_NAMESPACE = 0x0101
CHUNK_START_ELEMENT = 0x0102
CHUNK_END_ELEMENT = 0x0103
CHUNK_CDATA = 0x0104

RES_TABLE_PACKAGE_TYPE = 0x0200
RES_TABLE_TYPE_TYPE = 0x0201

UTF8_FLAG = 0x100
SORTED_FLAG = 0x1

TYPE_REFERENCE = 0x01
TYPE_STRING = 0x03
TYPE_INT_DEC = 0x10

ATTR_SCREEN_ORIENTATION_RES_ID = 0x0101001E
ORIENTATION_VALUES = {
    "unspecified": -1,
    "sensorLandscape": 6,
    "fullUser": 10,
}
ANDROID_NS_URI = "http://schemas.android.com/apk/res/android"

STRIP_PERMISSIONS = {
    "android.permission.REQUEST_INSTALL_PACKAGES",
    "android.permission.RECORD_AUDIO",
    "android.permission.READ_EXTERNAL_STORAGE",
    "android.permission.WRITE_EXTERNAL_STORAGE",
    "android.permission.READ_MEDIA_IMAGES",
    "android.permission.READ_MEDIA_AUDIO",
    "android.permission.INTERNET",
    "android.permission.ACCESS_NETWORK_STATE",
}


def u16(buf: bytes | bytearray, off: int) -> int:
    return struct.unpack_from("<H", buf, off)[0]


def u32(buf: bytes | bytearray, off: int) -> int:
    return struct.unpack_from("<I", buf, off)[0]


def i32(buf: bytes | bytearray, off: int) -> int:
    return struct.unpack_from("<i", buf, off)[0]


def parse_string_pool(buf: bytes, pos: int) -> tuple[list[str], int, bool, int]:
    ctype = u16(buf, pos)
    hsize = u16(buf, pos + 2)
    csize = u32(buf, pos + 4)
    if ctype != CHUNK_STRING_POOL:
        raise ValueError(f"Expected STRING_POOL chunk at {pos}, got 0x{ctype:04x}")
    scount = u32(buf, pos + 8)
    style_count = u32(buf, pos + 12)
    flags = u32(buf, pos + 16)
    sstart = u32(buf, pos + 20)
    utf8 = bool(flags & UTF8_FLAG)
    strings: list[str] = []
    for idx in range(scount):
        off = pos + sstart + u32(buf, pos + hsize + idx * 4)
        if utf8:
            o = off + (1 if (buf[off] & 0x80) == 0 else 2)
            blen = buf[o]
            o += 1
            if blen & 0x80:
                blen = ((blen & 0x7F) << 8) | buf[o]
                o += 1
            strings.append(buf[o : o + blen].decode("utf-8"))
        else:
            clen = u16(buf, off)
            o = off + 2
            if clen & 0x8000:
                clen = ((clen & 0x7FFF) << 16) | u16(buf, o)
                o += 2
            strings.append(buf[o : o + clen * 2].decode("utf-16le"))
    if style_count != 0:
        raise ValueError("Unsupported styled string pool in AndroidManifest.xml")
    return strings, pos + csize, utf8, flags


def encode_string_pool(strings: list[str], utf8: bool, orig_flags: int) -> bytes:
    header_size = 28
    offsets: list[int] = []
    blob = bytearray()
    for text in strings:
        offsets.append(len(blob))
        if utf8:
            raw = text.encode("utf-8")
            char_len = len(text)
            byte_len = len(raw)
            for length in (char_len, byte_len):
                if length > 0x7F:
                    blob.append(((length >> 8) & 0x7F) | 0x80)
                blob.append(length & 0xFF)
            blob.extend(raw)
            blob.append(0)
        else:
            raw = text.encode("utf-16le")
            char_len = len(raw) // 2
            if char_len > 0x7FFF:
                blob.extend(struct.pack("<HH", ((char_len >> 16) & 0x7FFF) | 0x8000, char_len & 0xFFFF))
            else:
                blob.extend(struct.pack("<H", char_len))
            blob.extend(raw)
            blob.extend(b"\x00\x00")
    while len(blob) % 4 != 0:
        blob.append(0)

    strings_start = header_size + len(strings) * 4
    total_size = strings_start + len(blob)
    flags = orig_flags & ~SORTED_FLAG
    if utf8:
        flags |= UTF8_FLAG
    else:
        flags &= ~UTF8_FLAG

    out = bytearray(total_size)
    struct.pack_into(
        "<HHIIIIII",
        out,
        0,
        CHUNK_STRING_POOL,
        header_size,
        total_size,
        len(strings),
        0,
        flags,
        strings_start,
        0,
    )
    for i, off in enumerate(offsets):
        struct.pack_into("<I", out, header_size + i * 4, off)
    out[strings_start:] = blob
    return bytes(out)


def resolve_arsc_resource(arsc: bytes, target_name: str) -> tuple[int, str] | None:
    pos = u16(arsc, 2)
    global_strings, pos, _, _ = parse_string_pool(arsc, pos)
    while pos < len(arsc):
        ctype = u16(arsc, pos)
        hsize = u16(arsc, pos + 2)
        csize = u32(arsc, pos + 4)
        if ctype == RES_TABLE_PACKAGE_TYPE:
            pkg_id = u32(arsc, pos + 8)
            key_strings_off = u32(arsc, pos + 276)
            key_strings, _, _, _ = parse_string_pool(arsc, pos + key_strings_off)
            sub = pos + hsize
            end = pos + csize
            while sub < end:
                st = u16(arsc, sub)
                sh = u16(arsc, sub + 2)
                sc = u32(arsc, sub + 4)
                if st == RES_TABLE_TYPE_TYPE:
                    type_id = arsc[sub + 8]
                    flags = arsc[sub + 9]
                    ecount = u32(arsc, sub + 12)
                    estart = u32(arsc, sub + 16)
                    is_sparse = bool(flags & 1)
                    is_off16 = bool(flags & 2)
                    offsets_pos = sub + sh
                    if not is_sparse:
                        for ei in range(ecount):
                            if is_off16:
                                raw_off = u16(arsc, offsets_pos + ei * 2)
                                if raw_off == 0xFFFF:
                                    continue
                                eoff = raw_off * 4
                            else:
                                raw_off = u32(arsc, offsets_pos + ei * 4)
                                if raw_off == 0xFFFFFFFF:
                                    continue
                                eoff = raw_off
                            ep = sub + estart + eoff
                            esize = u16(arsc, ep)
                            kidx = u32(arsc, ep + 4)
                            if kidx < len(key_strings) and key_strings[kidx] == target_name:
                                res_id = (pkg_id << 24) | (type_id << 16) | ei
                                vtype = arsc[ep + esize + 3]
                                vdata = u32(arsc, ep + esize + 4)
                                if vtype == TYPE_STRING and vdata < len(global_strings):
                                    return res_id, global_strings[vdata]
                sub += sc
        pos += csize
    return None


def bump_str_index(idx: int, threshold: int) -> int:
    return idx + 1 if idx >= threshold else idx


def shift_chunk_strings(chunk: bytearray, threshold: int) -> None:
    ctype = u16(chunk, 0)
    hsize = u16(chunk, 2)
    if hsize >= 16:
        struct.pack_into("<i", chunk, 12, bump_str_index(i32(chunk, 12), threshold))

    if ctype in (CHUNK_START_NAMESPACE, CHUNK_END_NAMESPACE):
        struct.pack_into("<i", chunk, hsize, bump_str_index(i32(chunk, hsize), threshold))
        struct.pack_into("<i", chunk, hsize + 4, bump_str_index(i32(chunk, hsize + 4), threshold))
    elif ctype == CHUNK_END_ELEMENT:
        struct.pack_into("<i", chunk, hsize, bump_str_index(i32(chunk, hsize), threshold))
        struct.pack_into("<i", chunk, hsize + 4, bump_str_index(i32(chunk, hsize + 4), threshold))
    elif ctype == CHUNK_CDATA:
        struct.pack_into("<i", chunk, hsize, bump_str_index(i32(chunk, hsize), threshold))
        vtype = chunk[hsize + 7]
        if vtype == TYPE_STRING:
            struct.pack_into("<i", chunk, hsize + 8, bump_str_index(i32(chunk, hsize + 8), threshold))
    elif ctype == CHUNK_START_ELEMENT:
        el = hsize
        struct.pack_into("<i", chunk, el, bump_str_index(i32(chunk, el), threshold))
        struct.pack_into("<i", chunk, el + 4, bump_str_index(i32(chunk, el + 4), threshold))
        astart = el + u16(chunk, el + 8)
        asize = u16(chunk, el + 10)
        acount = u16(chunk, el + 12)
        for i in range(acount):
            at = astart + i * asize
            struct.pack_into("<i", chunk, at, bump_str_index(i32(chunk, at), threshold))
            struct.pack_into("<i", chunk, at + 4, bump_str_index(i32(chunk, at + 4), threshold))
            struct.pack_into("<i", chunk, at + 8, bump_str_index(i32(chunk, at + 8), threshold))
            if chunk[at + 15] == TYPE_STRING:
                struct.pack_into("<i", chunk, at + 16, bump_str_index(i32(chunk, at + 16), threshold))


def rewrite_manifest(
    manifest: bytes,
    original_id: str,
    game_id: str,
    title: str,
    version_code: int,
    version_name: str,
    icon_res_id: int | None,
    orientation: str = "fullUser",
) -> bytes:
    if orientation not in ORIENTATION_VALUES:
        raise ValueError(f"Unsupported orientation: {orientation} (expected one of {sorted(ORIENTATION_VALUES)})")
    orient_val = ORIENTATION_VALUES[orientation]

    if u16(manifest, 0) != CHUNK_XML or u16(manifest, 2) != 8 or u32(manifest, 4) != len(manifest):
        raise ValueError("Invalid binary AndroidManifest.xml header")

    strings, pos, utf8, sp_flags = parse_string_pool(manifest, 8)
    resmap: list[int] = []
    chunks: list[bytearray] = []

    while pos < len(manifest):
        ctype = u16(manifest, pos)
        hsize = u16(manifest, pos + 2)
        csize = u32(manifest, pos + 4)
        if csize < 8 or pos + csize > len(manifest):
            raise ValueError(f"Invalid AXML chunk size at {pos}")
        if ctype == CHUNK_RESOURCE_MAP:
            rcount = (csize - hsize) // 4
            resmap = [u32(manifest, pos + hsize + i * 4) for i in range(rcount)]
        else:
            chunks.append(bytearray(manifest[pos : pos + csize]))
        pos += csize

    # Ensure android:screenOrientation exists in RESOURCE_MAP + STRING_POOL
    if ATTR_SCREEN_ORIENTATION_RES_ID in resmap:
        orient_idx = resmap.index(ATTR_SCREEN_ORIENTATION_RES_ID)
    else:
        orient_idx = len(resmap)
        resmap.append(ATTR_SCREEN_ORIENTATION_RES_ID)
        strings.insert(orient_idx, "screenOrientation")
        for ch in chunks:
            shift_chunk_strings(ch, orient_idx)

    def add_string(text: str) -> int:
        strings.append(text)
        return len(strings) - 1

    android_ns_idx = -1
    for ch in chunks:
        if u16(ch, 0) == CHUNK_START_NAMESPACE:
            hsize = u16(ch, 2)
            uri_idx = i32(ch, hsize + 4)
            if 0 <= uri_idx < len(strings) and strings[uri_idx] == ANDROID_NS_URI:
                android_ns_idx = uri_idx
                break

    found_package = False
    found_vc = False
    found_vn = False
    found_label = False
    found_icon = False
    patched_orientation = False

    # First pass: filter out unwanted <intent-filter> (inside <activity> only) and <uses-permission> subtrees
    filtered_chunks: list[bytearray] = []
    elem_stack: list[str] = []
    i = 0
    while i < len(chunks):
        ch = chunks[i]
        ctype = u16(ch, 0)
        hsize = u16(ch, 2)

        if ctype == CHUNK_START_ELEMENT:
            tag = strings[i32(ch, hsize + 4)]
            parent_tag = elem_stack[-1] if elem_stack else ""
            if tag == "intent-filter" and parent_tag == "activity":
                depth = 1
                j = i + 1
                is_launcher = False
                while j < len(chunks) and depth > 0:
                    c2 = chunks[j]
                    t2 = u16(c2, 0)
                    h2 = u16(c2, 2)
                    if t2 == CHUNK_START_ELEMENT:
                        depth += 1
                        tag2 = strings[i32(c2, h2 + 4)]
                        if tag2 == "action":
                            astart = h2 + u16(c2, h2 + 8)
                            asize = u16(c2, h2 + 10)
                            acount = u16(c2, h2 + 12)
                            for ai in range(acount):
                                at = astart + ai * asize
                                nm = strings[i32(c2, at + 4)]
                                if nm == "name" and c2[at + 15] == TYPE_STRING:
                                    if strings[i32(c2, at + 16)] == "android.intent.action.MAIN":
                                        is_launcher = True
                    elif t2 == CHUNK_END_ELEMENT:
                        depth -= 1
                    j += 1
                if not is_launcher:
                    i = j
                    continue

            if tag == "uses-permission":
                astart = hsize + u16(ch, hsize + 8)
                asize = u16(ch, hsize + 10)
                acount = u16(ch, hsize + 12)
                perm_name = ""
                for ai in range(acount):
                    at = astart + ai * asize
                    if strings[i32(ch, at + 4)] == "name" and ch[at + 15] == TYPE_STRING:
                        perm_name = strings[i32(ch, at + 16)]
                if perm_name in STRIP_PERMISSIONS:
                    depth = 1
                    j = i + 1
                    while j < len(chunks) and depth > 0:
                        t2 = u16(chunks[j], 0)
                        if t2 == CHUNK_START_ELEMENT:
                            depth += 1
                        elif t2 == CHUNK_END_ELEMENT:
                            depth -= 1
                        j += 1
                    i = j
                    continue

            elem_stack.append(tag)
        elif ctype == CHUNK_END_ELEMENT and elem_stack:
            elem_stack.pop()

        filtered_chunks.append(ch)
        i += 1

    # Second pass: rewrite attributes & inject screenOrientation on MainActivity
    out_chunks: list[bytearray] = []
    for ch in filtered_chunks:
        ctype = u16(ch, 0)
        hsize = u16(ch, 2)
        if ctype == CHUNK_START_ELEMENT:
            el = hsize
            tag = strings[i32(ch, el + 4)]
            astart = el + u16(ch, el + 8)
            asize = u16(ch, el + 10)
            acount = u16(ch, el + 12)

            is_main_activity = False
            has_orient_attr = False

            for ai in range(acount):
                at = astart + ai * asize
                nm_idx = i32(ch, at + 4)
                name = strings[nm_idx]
                vtype = ch[at + 15]
                val = i32(ch, at + 16)
                text = strings[val] if vtype == TYPE_STRING and 0 <= val < len(strings) else ""

                def set_str(new_text: str) -> None:
                    sidx = add_string(new_text)
                    struct.pack_into("<i", ch, at + 8, sidx)
                    ch[at + 15] = TYPE_STRING
                    struct.pack_into("<i", ch, at + 16, sidx)

                if tag == "manifest" and name == "package" and text == original_id:
                    set_str(game_id)
                    found_package = True
                elif tag == "manifest" and name == "versionCode":
                    struct.pack_into("<i", ch, at + 8, -1)
                    ch[at + 15] = TYPE_INT_DEC
                    struct.pack_into("<i", ch, at + 16, version_code)
                    found_vc = True
                elif tag == "manifest" and name == "versionName":
                    set_str(version_name)
                    found_vn = True
                elif tag == "application" and name == "label":
                    set_str(title)
                    found_label = True
                elif tag == "application" and name in ("icon", "roundIcon"):
                    if icon_res_id is not None:
                        struct.pack_into("<i", ch, at + 8, -1)
                        ch[at + 15] = TYPE_REFERENCE
                        struct.pack_into("<I", ch, at + 16, icon_res_id)
                    if name == "icon":
                        found_icon = True
                elif (
                    name in ("authorities", "permission")
                    or (tag in ("permission", "uses-permission") and name == "name")
                ) and text.startswith(original_id + "."):
                    set_str(game_id + text[len(original_id) :])
                elif tag == "activity" and name == "name":
                    if text.startswith("."):
                        full = original_id + text
                        set_str(full)
                        text = full
                    if text == "org.ippclub.dorassr.MainActivity":
                        is_main_activity = True
                elif tag == "activity" and name == "screenOrientation":
                    has_orient_attr = True
                    struct.pack_into("<i", ch, at + 8, -1)
                    ch[at + 15] = TYPE_INT_DEC
                    struct.pack_into("<i", ch, at + 16, orient_val)
                    patched_orientation = True

            if is_main_activity and not has_orient_attr:
                if android_ns_idx < 0 or orient_idx < 0:
                    raise ValueError("Cannot inject screenOrientation: missing android namespace")
                insert_pos_idx = acount
                for ai in range(acount):
                    at = astart + ai * asize
                    aname_idx = i32(ch, at + 4)
                    ares = resmap[aname_idx] if 0 <= aname_idx < len(resmap) else 0xFFFFFFFF
                    if ares > ATTR_SCREEN_ORIENTATION_RES_ID:
                        insert_pos_idx = ai
                        break
                attr_bytes = struct.pack(
                    "<iiiHBBi",
                    android_ns_idx,
                    orient_idx,
                    -1,
                    8,
                    0,
                    TYPE_INT_DEC,
                    orient_val,
                )
                if len(attr_bytes) != asize:
                    raise ValueError(f"Unexpected AXML attribute size {asize}")
                byte_off = astart + insert_pos_idx * asize
                ch[byte_off:byte_off] = attr_bytes
                struct.pack_into("<I", ch, 4, len(ch))
                struct.pack_into("<H", ch, el + 12, acount + 1)
                for idx_off in (el + 14, el + 16, el + 18):
                    cur_idx = u16(ch, idx_off)
                    if cur_idx > 0 and cur_idx - 1 >= insert_pos_idx:
                        struct.pack_into("<H", ch, idx_off, cur_idx + 1)
                patched_orientation = True

        out_chunks.append(ch)

    if not (found_package and found_vc and found_vn and found_label and found_icon):
        raise ValueError(
            f"Manifest missing expected fields: pkg={found_package} vc={found_vc} "
            f"vn={found_vn} label={found_label} icon={found_icon}"
        )
    if not patched_orientation:
        raise ValueError("Failed to inject android:screenOrientation on MainActivity")

    new_sp = encode_string_pool(strings, utf8, sp_flags)
    resmap_size = 8 + len(resmap) * 4
    new_rm = bytearray(resmap_size)
    struct.pack_into("<HHI", new_rm, 0, CHUNK_RESOURCE_MAP, 8, resmap_size)
    for i, rid in enumerate(resmap):
        struct.pack_into("<I", new_rm, 8 + i * 4, rid)

    body = b"".join(out_chunks)
    total_size = 8 + len(new_sp) + len(new_rm) + len(body)
    header = struct.pack("<HHI", CHUNK_XML, 8, total_size)
    return header + new_sp + bytes(new_rm) + body


def should_skip_template_entry(name: str, keep_abis: set[str], strip_controller_db: bool = False) -> bool:
    if strip_controller_db and name == "assets/gamecontrollerdb.txt":
        return True
    if (
        name == "assets/Script/init.lua"
        or name == "assets/Script/init.yue"
        or name.startswith("assets/Game/")
        or name.startswith("assets/Script/Dev/")
        or name.startswith("assets/Script/Test/")
        or name.startswith("assets/Script/Tools/")
        or name.startswith("assets/dora-wa/")
        or name.startswith("assets/Doc/")
        or name.startswith("assets/www/")
        or name.startswith("assets/GodotRuntimeNotices/")
        or name == "assets/Image/Mobile/dora-remix-states.png"
        or name == "assets/Audio/GeneralUserGS.sf3"
        or name == "stamp-cert-sha256"
    ):
        return True
    if name.startswith("META-INF/"):
        sub = name[len("META-INF/") :].upper()
        if "/" not in sub and (
            sub == "MANIFEST.MF"
            or sub.startswith("SIG-")
            or sub.endswith((".SF", ".RSA", ".DSA", ".EC"))
        ):
            return True
    if name.startswith("lib/"):
        parts = name.split("/")
        if len(parts) != 3:
            return True
        abi, libname = parts[1], parts[2]
        if abi not in keep_abis:
            return True
        if libname in ("libgojni.so", "libgodot_android.so"):
            return True
    return False


def build_apk(
    template_apk: Path,
    stage_assets_dir: Path,
    output_apk: Path,
    package_name: str,
    app_title: str,
    version_code: int,
    version_name: str,
    abis: set[str],
    icon_png: Path | None,
    orientation: str = "fullUser",
    strip_controller_db: bool = False,
) -> None:
    if not re.match(r"^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$", package_name):
        raise ValueError(f"Invalid Android package name: {package_name}")
    if package_name == "org.ippclub.dorassr":
        raise ValueError("Package name must differ from org.ippclub.dorassr")

    icon_bytes = icon_png.read_bytes() if icon_png is not None and icon_png.is_file() else None

    with zipfile.ZipFile(template_apk, "r") as zin:
        arsc = zin.read("resources.arsc")
        icon_res_id: int | None = None
        icon_entry_path: str | None = None
        if icon_bytes is not None:
            resolved = resolve_arsc_resource(arsc, "game_export_icon")
            if resolved is None:
                raise RuntimeError("Could not resolve game_export_icon in template resources.arsc")
            icon_res_id, icon_entry_path = resolved
            if icon_entry_path not in zin.namelist():
                raise RuntimeError(f"Icon entry {icon_entry_path} missing from template APK")

        manifest_raw = zin.read("AndroidManifest.xml")
        manifest_patched = rewrite_manifest(
            manifest_raw,
            original_id="org.ippclub.dorassr",
            game_id=package_name,
            title=app_title,
            version_code=version_code,
            version_name=version_name,
            icon_res_id=icon_res_id,
            orientation=orientation,
        )

        avail_abis = {
            n.split("/")[1]
            for n in zin.namelist()
            if n.startswith("lib/") and n.endswith("/libmain.so")
        }
        missing_abis = abis - avail_abis
        if missing_abis:
            raise RuntimeError(f"Template APK missing ABIs: {sorted(missing_abis)} (available: {sorted(avail_abis)})")

        output_apk.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(output_apk, "w") as zout:
            for item in zin.infolist():
                name = item.filename
                if item.is_dir() or should_skip_template_entry(name, abis, strip_controller_db):
                    continue
                if name == "AndroidManifest.xml":
                    zi = zipfile.ZipInfo(name)
                    zi.compress_type = zipfile.ZIP_DEFLATED
                    zout.writestr(zi, manifest_patched, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
                elif icon_entry_path is not None and name == icon_entry_path and icon_bytes is not None:
                    zi = zipfile.ZipInfo(name)
                    zi.compress_type = zipfile.ZIP_STORED
                    zout.writestr(zi, icon_bytes, compress_type=zipfile.ZIP_STORED)
                else:
                    raw = zin.read(name)
                    must_store = (
                        item.compress_type == zipfile.ZIP_STORED
                        or name == "resources.arsc"
                        or name.endswith(".so")
                    )
                    zi = zipfile.ZipInfo(name)
                    if must_store:
                        zi.compress_type = zipfile.ZIP_STORED
                        zout.writestr(zi, raw, compress_type=zipfile.ZIP_STORED)
                    else:
                        zi.compress_type = zipfile.ZIP_DEFLATED
                        zout.writestr(zi, raw, compress_type=zipfile.ZIP_DEFLATED, compresslevel=6)

            for path in sorted(stage_assets_dir.rglob("*")):
                if not path.is_file():
                    continue
                rel = path.relative_to(stage_assets_dir).as_posix()
                entry_name = f"assets/{rel}"
                zi = zipfile.ZipInfo(entry_name)
                if path.suffix.lower() in (".png", ".jpg", ".jpeg", ".webp", ".ogg"):
                    zi.compress_type = zipfile.ZIP_STORED
                    zout.writestr(zi, path.read_bytes(), compress_type=zipfile.ZIP_STORED)
                else:
                    zi.compress_type = zipfile.ZIP_DEFLATED
                    zout.writestr(zi, path.read_bytes(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=6)

    print(
        f"Patched APK built: {output_apk} ({output_apk.stat().st_size / (1024 * 1024):.1f} MB) | "
        f"pkg={package_name} title={app_title} vc={version_code} vn={version_name} "
        f"orientation={orientation} abis={','.join(sorted(abis))} icon={icon_entry_path or 'default'}"
    )


def main() -> int:
    ap = argparse.ArgumentParser(description="Repackage Dora SSR Android APK for Westward Watch")
    ap.add_argument("--template-apk", required=True, type=Path)
    ap.add_argument("--assets-dir", required=True, type=Path)
    ap.add_argument("--output", required=True, type=Path)
    ap.add_argument("--package", default="com.hxsx1016.westwardwatch")
    ap.add_argument("--title", default="向西守望")
    ap.add_argument("--version-code", type=int, default=1)
    ap.add_argument("--version-name", default="1.0.0")
    ap.add_argument("--abis", default="arm64-v8a")
    ap.add_argument("--icon", type=Path, default=None)
    ap.add_argument(
        "--orientation",
        choices=sorted(ORIENTATION_VALUES.keys()),
        default="fullUser",
        help="MainActivity screenOrientation (default: fullUser for landscape/portrait auto switch)",
    )
    ap.add_argument(
        "--strip-controller-db",
        action="store_true",
        help="Strip assets/gamecontrollerdb.txt for touch-only Android phone APKs",
    )
    args = ap.parse_args()

    abis = {a.strip() for a in args.abis.split(",") if a.strip()}
    build_apk(
        template_apk=args.template_apk,
        stage_assets_dir=args.assets_dir,
        output_apk=args.output,
        package_name=args.package,
        app_title=args.title,
        version_code=args.version_code,
        version_name=args.version_name,
        abis=abis,
        icon_png=args.icon,
        orientation=args.orientation,
        strip_controller_db=args.strip_controller_db,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
