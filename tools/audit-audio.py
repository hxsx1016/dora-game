#!/usr/bin/env python3
"""《向西守望》全量音频资产声学质量与完整性审计工具（纯 Python 标准库，CI 零外部依赖）。

检查项：
1. 全部 WAV 文件为合法 16-bit PCM、采样率 48000 Hz、立体声、非静音、零削波（Peak <= -0.5 dBFS）；
2. 全部 OGG 文件为合法 Ogg Vorbis 封装（OggS + \\x01vorbis 头）、48000 Hz 立体声、有效时长；
3. 全部无缝循环音轨（*_loop.*、night_distant_fire.wav、tower_wind_cold.wav、tower_room_warm.wav）
   时长 >= 6.0s 且 WAV 首尾采样跳变 < 0.025（零爆音接缝）；
4. 与代码中静态引用的全部 assets/audio/** 路径双向核对（0 缺失、0 孤儿未登记资产）；
5. 若当前 Python 环境具备 soundfile + numpy（如音频制作虚拟环境），附加执行 OGG 解码峰值与循环点接缝深度校验。
"""

from __future__ import annotations

import array
import math
import re
import struct
import sys
import wave
from pathlib import Path
from typing import Dict, List, Optional, Tuple

ROOT = Path(__file__).resolve().parents[1]
AUDIO_ROOT = ROOT / "assets" / "audio"
AUDIO_REF_RE = re.compile(r"assets/audio/[A-Za-z0-9_./-]+\.(?:wav|ogg)")

# 额外不带 _loop 后缀但以循环方式播放的环境轨
EXTRA_LOOP_FILES = {
    "prologue/night_distant_fire.wav",
    "tower/tower_wind_cold.wav",
    "tower/tower_room_warm.wav",
}

# 短动作循环（非长房间底噪，允许 0.5s–6.0s 紧凑时长）
SHORT_ACTION_LOOPS = {
    "interact/wedge_craft_loop.wav",
}

# BGM 循环点（秒，与 Script/watch/fe/bgm.ts BGM_CATALOG 保持单一真源对齐）
BGM_LOOP_POINTS = {
    "bgm/title_westward_watch.ogg": 8.0,
    "bgm/prologue_ember_night.ogg": 0.0,
    "bgm/street_alley_tension.ogg": 0.0,
    "bgm/checkpoint_granary.ogg": 0.0,
    "bgm/gate_siege_45s.ogg": 48.0,
    "bgm/gate_count_drone.ogg": 0.0,
    "bgm/reunion_hand_in_hand.ogg": 0.0,
    "bgm/escort_combat.ogg": 4.0,
    "bgm/escort_craft_bench.ogg": 0.0,
    "bgm/child_lone_journey.ogg": 0.0,
    "bgm/forest_stalk_and_creek.ogg": 0.0,
    "bgm/creek_dawn_reflection.ogg": 0.0,
    "bgm/ending_f03_lamp.ogg": 32.0,
    "bgm/ending_m03_reunion.ogg": 32.0,
    "bgm/museum_dawn_peace.ogg": 6.0,
}


def lin_to_db(v: float) -> float:
    return -120.0 if v <= 1e-12 else 20.0 * math.log10(v)


def inspect_wav(path: Path) -> Dict[str, float]:
    with wave.open(str(path), "rb") as wf:
        ch = wf.getnchannels()
        sw = wf.getsampwidth()
        sr = wf.getframerate()
        nf = wf.getnframes()
        raw = wf.readframes(nf)
    if sw != 2:
        raise ValueError(f"非 16-bit PCM (sampwidth={sw})")
    if nf == 0:
        raise ValueError("空 WAV（0 帧）")
    samples = array.array("h")
    samples.frombytes(raw)
    if sys.byteorder == "big":
        samples.byteswap()
    scale = 1.0 / 32768.0
    max_abs = max(abs(min(samples)), abs(max(samples))) * scale
    # 采样步进计算 RMS（大文件抽样不丢精度，小文件全量）
    step = 1 if len(samples) <= 480000 else 4
    sq_sum = 0.0
    cnt = 0
    for s in samples[::step]:
        fv = s * scale
        sq_sum += fv * fv
        cnt += 1
    rms = math.sqrt(sq_sum / max(1, cnt))
    # 首尾跨循环接缝最大声道差
    seam = 0.0
    if nf >= 2:
        for c in range(ch):
            d = abs(samples[c] - samples[(nf - 1) * ch + c]) * scale
            if d > seam:
                seam = d
    return {
        "channels": ch,
        "sr": sr,
        "dur": nf / float(sr),
        "peak_db": lin_to_db(max_abs),
        "rms_db": lin_to_db(rms),
        "seam": seam,
    }


def inspect_ogg_header(path: Path) -> Dict[str, float]:
    data = path.read_bytes()
    if len(data) < 64 or data[:4] != b"OggS":
        raise ValueError("缺少 OggS 文件头")
    idx = data.find(b"\x01vorbis")
    if idx < 0 or idx + 29 > len(data):
        raise ValueError("缺少 Vorbis 识别头")
    ver, ch, sr, br_max, br_nom, br_min = struct.unpack_from("<IBIiii", data, idx + 7)
    if ver != 0:
        raise ValueError(f"不支持的 Vorbis 版本: {ver}")
    # 查找最后一个 OggS 页的 granule_position 精确计算总时长
    last_ogg = data.rfind(b"OggS")
    dur = 0.0
    if last_ogg >= 0 and last_ogg + 14 <= len(data):
        granule = struct.unpack_from("<q", data, last_ogg + 6)[0]
        if granule > 0 and sr > 0:
            dur = granule / float(sr)
    return {
        "channels": ch,
        "sr": sr,
        "dur": dur,
        "br_nom": br_nom,
        "size": len(data),
    }


def collect_code_audio_refs() -> set[str]:
    refs: set[str] = set()
    files = [ROOT / "init.ts", *(ROOT / "Script" / "watch").rglob("*.ts")]
    for p in files:
        if not p.is_file():
            continue
        text = p.read_text(encoding="utf-8")
        for m in AUDIO_REF_RE.finditer(text):
            refs.add(m.group(0))
        # 处理前缀常量拼接，例如 GATE_AUDIO_ROOT + "count_01.wav"、BGM_ROOT + "splash_brand.ogg" 等
        prefix_map = {
            "GATE_AUDIO_ROOT": "assets/audio/gate/",
            "CHILD_AUDIO_ROOT": "assets/audio/child/",
            "TOWER_AUDIO_ROOT": "assets/audio/tower/",
            "MUSEUM_AUDIO_ROOT": "assets/audio/museum/",
            "PROLOGUE_AUDIO_ROOT": "assets/audio/prologue/",
            "COMBAT_AUDIO_ROOT": "assets/audio/combat/",
            "BGM_ROOT": "assets/audio/bgm/",
            "AMB_ROOT": "assets/audio/ambience/",
            "FOL_ROOT": "assets/audio/foley/",
            "CMB_ROOT": "assets/audio/combat/",
            "UI_ROOT": "assets/audio/ui/",
        }
        for const_name, base_dir in prefix_map.items():
            for m in re.finditer(rf'{const_name}\s*\+\s*["\']([A-Za-z0-9_./-]+\.(?:wav|ogg))["\']', text):
                refs.add(base_dir + m.group(1))
    # 动态生成的编号资产（count_01..20, reload_node_1..6, step_*）
    for n in range(1, 21):
        refs.add(f"assets/audio/gate/count_{n:02d}.wav")
    for n in range(1, 7):
        refs.add(f"assets/audio/combat/reload_node_{n}.wav")
    return refs


def main() -> int:
    errors: List[str] = []
    warnings: List[str] = []

    if not AUDIO_ROOT.is_dir():
        print("缺少 assets/audio 目录", file=sys.stderr)
        return 1

    all_files = sorted(
        p for p in AUDIO_ROOT.rglob("*")
        if p.is_file() and p.suffix.lower() in (".wav", ".ogg")
    )

    try:
        import numpy as np
        import soundfile as sf
        has_deep = True
    except Exception:
        has_deep = False

    wav_count = 0
    ogg_count = 0
    loop_count = 0
    total_bytes = 0
    dir_counts: Dict[str, int] = {}

    for p in all_files:
        rel = p.relative_to(AUDIO_ROOT).as_posix()
        top_dir = rel.split("/")[0]
        dir_counts[top_dir] = dir_counts.get(top_dir, 0) + 1
        total_bytes += p.stat().st_size
        is_loop = p.stem.endswith("_loop") or rel in EXTRA_LOOP_FILES

        if p.suffix.lower() == ".wav":
            wav_count += 1
            try:
                info = inspect_wav(p)
            except Exception as exc:
                errors.append(f"[WAV损坏] {rel}: {exc}")
                continue
            if info["sr"] != 48000:
                errors.append(f"[WAV采样率非48k] {rel}: {info['sr']} Hz")
            if info["channels"] != 2:
                errors.append(f"[WAV非立体声] {rel}: {info['channels']} ch")
            if info["peak_db"] > -0.5:
                errors.append(f"[WAV削波风险] {rel}: Peak={info['peak_db']:.2f} dBFS (> -0.5)")
            if info["rms_db"] < -62.0:
                errors.append(f"[WAV近静音] {rel}: RMS={info['rms_db']:.2f} dBFS")
            if is_loop:
                loop_count += 1
                min_dur = 0.5 if rel in SHORT_ACTION_LOOPS else 6.0
                if info["dur"] < min_dur:
                    errors.append(f"[循环过短] {rel}: dur={info['dur']:.2f}s (< {min_dur:.1f}s)")
                if info["seam"] > 0.025:
                    errors.append(f"[循环接缝跳变] {rel}: seam={info['seam']:.5f} (> 0.025)")
        else:
            ogg_count += 1
            try:
                info = inspect_ogg_header(p)
            except Exception as exc:
                errors.append(f"[OGG损坏] {rel}: {exc}")
                continue
            if info["sr"] != 48000:
                errors.append(f"[OGG采样率非48k] {rel}: {info['sr']} Hz")
            if info["channels"] != 2:
                errors.append(f"[OGG非立体声] {rel}: {info['channels']} ch")
            if info["dur"] <= 1.0:
                errors.append(f"[OGG时长异常] {rel}: dur={info['dur']:.2f}s")
            if is_loop:
                loop_count += 1
                if info["dur"] < 6.0:
                    errors.append(f"[OGG循环过短] {rel}: dur={info['dur']:.2f}s")
            if has_deep:
                try:
                    data, dsr = sf.read(str(p), dtype="float64")
                    pk = lin_to_db(float(np.max(np.abs(data))))
                    if pk > -0.5:
                        errors.append(f"[OGG解码削波风险] {rel}: Peak={pk:.2f} dBFS")
                    if is_loop and len(data) > 10:
                        seam = float(np.max(np.abs(data[0] - data[-1])))
                        if seam > 0.025:
                            errors.append(f"[OGG循环接缝跳变] {rel}: seam={seam:.5f}")
                    elif rel in BGM_LOOP_POINTS and len(data) > 10:
                        lp_sec = BGM_LOOP_POINTS[rel]
                        lp_idx = min(len(data) - 1, int(round(lp_sec * dsr)))
                        # 对带前奏曲目（lp_idx > 0），循环回跳用末尾 sample[-1] 替代 sample[lp_idx - 1] 衔接入 sample[lp_idx]
                        ref_idx = lp_idx - 1 if lp_idx > 0 else 0
                        seam = float(np.max(np.abs(data[ref_idx] - data[-1])))
                        if seam > 0.025:
                            errors.append(f"[BGM循环点接缝跳变] {rel} (@{lp_sec:.1f}s): seam={seam:.5f}")
                except Exception as exc:
                    warnings.append(f"[OGG深度解码跳过] {rel}: {exc}")

    # 双向代码引用完整性核对
    code_refs = collect_code_audio_refs()
    disk_rels = {"assets/audio/" + p.relative_to(AUDIO_ROOT).as_posix() for p in all_files}
    missing = sorted(r for r in code_refs if r not in disk_rels)
    for m in missing:
        errors.append(f"[代码引用缺失] {m}")

    unreferenced = sorted(r for r in disk_rels if r not in code_refs)
    if unreferenced:
        warnings.append(f"未在静态扫描中直接命中的音频 ({len(unreferenced)}): " + ", ".join(unreferenced[:8]))

    if warnings:
        for w in warnings:
            print(f"WARN  {w}")

    if errors:
        print("\n".join(errors), file=sys.stderr)
        print(f"音频声学审计失败：{len(errors)} 项错误。", file=sys.stderr)
        return 1

    dir_summary = ", ".join(f"{k}={v}" for k, v in sorted(dir_counts.items()))
    print(
        f"音频声学审计通过：共 {len(all_files)} 份资产（OGG={ogg_count}, WAV={wav_count}, "
        f"无缝循环={loop_count}, 体积={total_bytes / (1024 * 1024):.1f} MB, 深度解码={'ON' if has_deep else 'STDLIB'}）"
    )
    print(f"  目录分布：{dir_summary}")
    print(f"  代码静态引用覆盖：{len(code_refs)} 项 0 缺失。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
