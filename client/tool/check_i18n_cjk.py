#!/usr/bin/env python3
"""Verify localized i18n files contain no untranslated CJK strings.

Two scopes:
1. JSON: per-file policy below.
2. Dart (lib/): user-visible string literals must not contain CJK — copy
   belongs in slang files. Line comments (//, ///) and /* */ blocks are
   skipped (developer notes, not UI). A trailing `// cjk-allow: <reason>`
   pragma exempts legit locale data (e.g. Intl date skeletons like
   'yyyy年M月', which are per-locale format patterns, not copy).

Policy per JSON file:
- en.i18n.json: no CJK characters anywhere (English has no kanji usage).
- ko.i18n.json: no CJK outside the `locale` section, where native language
  names (e.g. "简体中文") are intentionally kept for the language picker.
- ja.i18n.json: skipped — Japanese legitimately uses kanji (CJK codepoints),
  so a codepoint check cannot distinguish untranslated Chinese from valid
  Japanese text.

Usage:
    python3 client/tool/check_i18n_cjk.py [--fix]
"""

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
I18N_DIR = ROOT / "lib" / "i18n"
CJK = re.compile(r"[\u4e00-\u9fff]")
ALLOWED_SECTIONS = {"locale"}  # native language names are intentionally kept


def walk(obj, path, findings):
    if isinstance(obj, dict):
        for k, v in obj.items():
            walk(v, path + [k], findings)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            walk(v, path + [str(i)], findings)
    elif isinstance(obj, str) and CJK.search(obj):
        section = path[0] if path else ""
        if section in ALLOWED_SECTIONS:
            return
        findings.append((".".join(path), obj))


def check_file(path: Path, fix: bool) -> int:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"[FAIL] {path}: invalid JSON: {e}")
        return 1

    findings = []
    walk(data, [], findings)

    if not findings:
        return 0

    if fix:
        text = path.read_text(encoding="utf-8")
        for dotted, value in findings:
            # Match the exact JSON literal (handles escaped quotes/backslashes)
            # instead of the raw decoded value.
            literal = json.dumps(value, ensure_ascii=False)
            if literal in text:
                text = text.replace(literal, '""', 1)
        path.write_text(text, encoding="utf-8")
        print(f"[FIXED] {path}: {len(findings)} untranslated entries blanked")
        return 0

    print(f"[FAIL] {path}: {len(findings)} untranslated entries:")
    for dotted, value in findings:
        print(f"  - {dotted}: {value}")
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--fix",
        action="store_true",
        help="blank untranslated values instead of failing",
    )
    args = parser.parse_args()

    files = sorted(I18N_DIR.glob("*.i18n.json"))
    # The base locale (zh) is Chinese by design; ja legitimately uses kanji.
    files = [
        f
        for f in files
        if not f.name.startswith("zh") and not f.name.startswith("ja")
    ]
    if not files:
        print("[FAIL] no i18n files found under", I18N_DIR)
        return 1

    failed = False
    for f in files:
        if check_file(f, args.fix) != 0:
            failed = True
    if check_dart_lib() != 0:
        failed = True
    return 1 if failed else 0


def check_dart_lib() -> int:
    """Scan lib/**/*.dart for CJK in code (comments stripped).

    Full-line (//, ///) and /* */ block comments are developer notes, not
    UI copy. A `cjk-allow` pragma on the raw line exempts legit locale data.
    Returns 0 when clean.
    """
    findings: list[str] = []
    in_block = False
    for path in sorted((ROOT / "lib").rglob("*.dart")):
        # Generated code mirrors slang output — the JSON gate is authoritative.
        if ".g.dart" in path.name or ".freezed.dart" in path.name:
            continue
        # GenUI catalog descriptions feed the MODEL (tool/component schemas),
        # never the screen — translating them has zero user impact.
        if path.name.startswith("catalog_"):
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except OSError:
            continue
        for lineno, raw in enumerate(text.split("\n"), 1):
            if "cjk-allow" in raw:
                continue
            line = raw
            if in_block:
                if "*/" in line:
                    line = line.split("*/", 1)[1]
                    in_block = False
                else:
                    continue
            while "/*" in line:
                before, _, rest = line.partition("/*")
                if "*/" in rest:
                    after = rest.split("*/", 1)[1]
                    line = before + after
                else:
                    line = before
                    in_block = True
                    break
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            code = line.split("//", 1)[0]
            if CJK.search(code):
                findings.append(f"{path.relative_to(ROOT)}:{lineno}: {stripped[:100]}")
    if findings:
        print(f"[FAIL] lib/: {len(findings)} CJK hits in Dart code:")
        for finding in findings:
            print(f"  - {finding}")
        return 1
    print("[OK] lib/: no CJK in Dart code")
    return 0


if __name__ == "__main__":
    sys.exit(main())
