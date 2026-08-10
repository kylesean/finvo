#!/usr/bin/env python3
"""Verify localized i18n files contain no untranslated CJK strings.

Policy per file:
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
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
