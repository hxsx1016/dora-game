import os
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]
LINK = re.compile(r"\]\((?:<([^>]+)>|([^()\s]+))(?:\s+\"[^\"]*\")?\)")


def git_paths(*options):
    output = subprocess.check_output(["git", "ls-files", "-z", *options], cwd=ROOT)
    return {ROOT / os.fsdecode(name) for name in output.split(b"\0") if name}


def check_links(document, files):
    errors = []
    fence = ""
    for number, line in enumerate(document.read_text(encoding="utf-8").splitlines(), 1):
        block = re.match(r"^\s*(`{3,}|~{3,})", line)
        if block:
            marker = block.group(1)
            if not fence:
                fence = marker
            elif marker.startswith(fence):
                fence = ""
            continue
        if fence:
            continue
        for match in LINK.finditer(line):
            destination = match.group(1) or match.group(2)
            url = urlsplit(destination)
            if url.scheme or url.netloc or not url.path:
                continue
            target = (document.parent / unquote(url.path)).resolve()
            if target not in files:
                errors.append(f"{document.relative_to(ROOT)}:{number} 找不到仓库内目标 {destination}")
    return errors


def main():
    files = {path for path in git_paths("--cached", "--others", "--exclude-standard") if path.is_file()}
    errors = [f"已跟踪忽略项 {path.relative_to(ROOT)}" for path in
              sorted(git_paths("--cached", "--ignored", "--exclude-per-directory=.gitignore"))]
    modules = {ROOT / "init"}
    watch = ROOT / "Script" / "watch"
    for path in files:
        if path == watch / "testdrive.lua":
            continue
        if watch in path.parents and path.suffix in {".ts", ".lua"} and not path.name.endswith(".d.ts"):
            modules.add(path.parent / path.stem)
    for module in sorted(modules):
        for suffix in (".ts", ".lua"):
            path = module.parent / (module.name + suffix)
            if path not in files:
                errors.append(f"模块缺少 {path.relative_to(ROOT)}")
    targets = files | {parent for path in files for parent in path.parents if parent == ROOT or ROOT in parent.parents}
    documents = sorted(path for path in files if path.suffix == ".md")
    for document in documents:
        errors.extend(check_links(document, targets))
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"仓库检查通过，{len(modules)} 组源码与 Lua，{len(documents)} 份 Markdown。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
