#!/usr/bin/env python3
"""Validate qa-report.md has required sections and PASS gate."""

from __future__ import annotations

import re
import sys
from pathlib import Path

REQUIRED_SECTIONS = (
    "主路径",
    "状态覆盖",
    "性能",
    "无障碍",
    "弱网",
    "阻塞项",
    "总 Gate",
)

GATE_PASS_RE = re.compile(r"\*\*qa_gate\*\*:\s*PASS\b", re.IGNORECASE)
SECTION_CONCLUSION = {
    "主路径": re.compile(r"\*\*主路径结论\*\*:\s*PASS\b", re.IGNORECASE),
    "状态覆盖": re.compile(r"\*\*状态覆盖结论\*\*:\s*PASS\b", re.IGNORECASE),
    "性能": re.compile(r"\*\*性能结论\*\*:\s*PASS\b", re.IGNORECASE),
    "无障碍": re.compile(r"\*\*无障碍结论\*\*:\s*PASS\b", re.IGNORECASE),
    "弱网": re.compile(r"\*\*韧性结论\*\*:\s*PASS\b", re.IGNORECASE),
}


def _fail(msg: str) -> None:
    print(f"FAIL: {msg}")


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: validate_qa_report.py <qa-report.md>", file=sys.stderr)
        return 2

    path = Path(sys.argv[1]).resolve()
    if not path.is_file():
        _fail(f"file not found: {path}")
        return 1

    text = path.read_text(encoding="utf-8")
    errors: list[str] = []

    for section in REQUIRED_SECTIONS:
        if section not in text:
            errors.append(f"missing section: {section}")

    for section, pattern in SECTION_CONCLUSION.items():
        if section in text and not pattern.search(text):
            errors.append(f"{section} section must conclude with PASS")

    if not GATE_PASS_RE.search(text):
        errors.append("**qa_gate**: PASS not found")

    if re.search(r"\*\*qa_gate\*\*:\s*FAIL\b", text, re.IGNORECASE):
        errors.append("qa_gate is FAIL")

    open_blockers = re.findall(
        r"\|\s*[^|]+\s*\|\s*[^|]+\s*\|\s*open\s*\|",
        text,
        flags=re.IGNORECASE,
    )
    if open_blockers:
        errors.append(f"{len(open_blockers)} open blocker(s) in table")

    if errors:
        for e in errors:
            _fail(e)
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
