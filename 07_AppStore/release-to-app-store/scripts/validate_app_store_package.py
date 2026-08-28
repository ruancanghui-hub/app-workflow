#!/usr/bin/env python3
"""Validate app-store-submission.md completeness."""

from __future__ import annotations

import re
import sys
from pathlib import Path

REQUIRED_HEADINGS = (
    "## 元数据",
    "## 版本",
    "## 文案",
    "## 审核信息",
    "## TestFlight",
    "## 提审状态",
    "## Gate",
)

REQUIRED_FIELDS = (
    "Bundle ID",
    "Marketing Version",
    "Build Number",
    "演示账号",
    "submission_status",
)


def _fail(msg: str) -> None:
    print(f"FAIL: {msg}")


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: validate_app_store_package.py <app-store-submission.md>", file=sys.stderr)
        return 2

    path = Path(sys.argv[1]).resolve()
    if not path.is_file():
        _fail(f"file not found: {path}")
        return 1

    text = path.read_text(encoding="utf-8")
    errors: list[str] = []

    for heading in REQUIRED_HEADINGS:
        if heading not in text:
            errors.append(f"missing heading: {heading}")

    for field in REQUIRED_FIELDS:
        if field not in text:
            errors.append(f"missing field label: {field}")

    if not re.search(r"\*\*app_store_gate\*\*:\s*PASS\b", text, re.IGNORECASE):
        errors.append("**app_store_gate**: PASS not found")

    status_m = re.search(r"submission_status\*\*:\s*(\w+)", text)
    if status_m:
        status = status_m.group(1).lower()
        if status not in ("submitted", "approved", "testflight"):
            errors.append(
                "submission_status must be testflight, submitted, or approved for gate PASS"
            )
    else:
        errors.append("submission_status not set")

    # Privacy companion file
    privacy = path.parent / "privacy-questionnaire.md"
    if not privacy.is_file():
        errors.append("privacy-questionnaire.md missing alongside submission doc")
    elif not re.search(r"\*\*privacy_gate\*\*:\s*PASS\b", privacy.read_text(encoding="utf-8"), re.I):
        errors.append("privacy-questionnaire.md must have **privacy_gate**: PASS")

    if errors:
        for e in errors:
            _fail(e)
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
