#!/usr/bin/env python3
"""Validate autotest-report.md: required sections, no FAIL rows, no open blockers, L3 done or deferred."""

from __future__ import annotations

import re
import sys
from pathlib import Path

REQUIRED_SECTIONS = ("L1", "L2", "L3", "阻塞项", "总 Gate")
GATE_PASS_RE = re.compile(r"\*\*autotest_gate\*\*:\s*PASS\b", re.IGNORECASE)
L3_STATUS_RE = re.compile(r"\*\*状态\*\*:\s*(\S+)")
L3_CONFIRMED_RE = re.compile(r"\*\*用户确认\*\*:\s*(.*)")
TOKEN_RE = re.compile(r"\{\{\w+\}\}")


def split_sections(text: str) -> dict[str, str]:
    sections: dict[str, str] = {}
    current = None
    for line in text.splitlines():
        if line.startswith("## "):
            current = line[3:].strip()
            sections[current] = ""
        elif current is not None:
            sections[current] += line + "\n"
    return sections


def section(sections: dict[str, str], prefix: str) -> str | None:
    for title, body in sections.items():
        if title.startswith(prefix):
            return body
    return None


def table_rows(body: str) -> list[list[str]]:
    rows = []
    for line in body.splitlines():
        line = line.strip()
        if not line.startswith("|") or re.match(r"^\|[\s\-|:]+\|$", line):
            continue
        rows.append([cell.strip() for cell in line.strip("|").split("|")])
    return rows


def has_result(rows: list[list[str]], value: str) -> bool:
    return any(value in row for row in rows)


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: validate_autotest_report.py <autotest-report.md>", file=sys.stderr)
        return 2

    path = Path(sys.argv[1]).resolve()
    if not path.is_file():
        print(f"FAIL: file not found: {path}")
        return 1

    text = path.read_text(encoding="utf-8")
    sections = split_sections(text)
    errors: list[str] = []

    for name in REQUIRED_SECTIONS:
        if section(sections, name) is None:
            errors.append(f"missing section: ## {name}")

    if tokens := TOKEN_RE.findall(text):
        errors.append(f"unfilled template tokens: {', '.join(sorted(set(tokens)))}")

    if not GATE_PASS_RE.search(text):
        errors.append("**autotest_gate**: PASS not found")

    for name in ("L1", "L2"):
        body = section(sections, name)
        if body is None:
            continue
        rows = table_rows(body)
        if has_result(rows, "FAIL"):
            errors.append(f"{name} has FAIL rows")
        if not has_result(rows, "PASS"):
            errors.append(f"{name} has no PASS evidence")

    blockers = section(sections, "阻塞项")
    if blockers is not None:
        open_rows = [r for r in table_rows(blockers) if len(r) >= 4 and r[3].lower() == "open"]
        if open_rows:
            errors.append(f"{len(open_rows)} open blocker(s)")

    l3 = section(sections, "L3")
    if l3 is not None:
        status_match = L3_STATUS_RE.search(l3)
        status = status_match[1].lower() if status_match else ""
        if status == "done":
            rows = table_rows(l3)
            if has_result(rows, "FAIL"):
                errors.append("L3 has FAIL rows")
            if not has_result(rows, "PASS"):
                errors.append("L3 is done but has no PASS evidence")
            unchecked = re.findall(r"^- \[ \]", l3, flags=re.M)
            if unchecked:
                errors.append(f"L3 manual checklist has {len(unchecked)} unchecked item(s)")
        elif status == "deferred":
            confirmed = L3_CONFIRMED_RE.search(l3)
            who = confirmed[1].strip() if confirmed else ""
            if who in ("", "-", "—"):
                errors.append("L3 deferred requires **用户确认**: <who / when>")
        else:
            errors.append("L3 **状态** must be done or deferred")

    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
