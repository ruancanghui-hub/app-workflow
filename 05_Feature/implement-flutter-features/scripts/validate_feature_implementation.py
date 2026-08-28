#!/usr/bin/env python3
"""Validate Flutter feature implementation trace and project health."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

STATUSES_OK = {"implemented", "deferred"}
ROW_RE = re.compile(
    r"^\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|$"
)


def _fail(msg: str) -> None:
    print(f"FAIL: {msg}")


def _parse_trace(path: Path) -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.startswith("|") or "---" in line:
            continue
        m = ROW_RE.match(line)
        if not m:
            continue
        req_id = m.group(1).strip()
        if not req_id or req_id in ("MVP 需求 ID", "状态"):
            continue
        rows.append(
            {
                "id": req_id,
                "goal": m.group(2).strip(),
                "code": m.group(3).strip(),
                "test": m.group(4).strip(),
                "status": m.group(5).strip().lower(),
                "evidence": m.group(6).strip(),
            }
        )
    return rows


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "Usage: validate_feature_implementation.py <flutter_app_dir> <implementation-trace.md>",
            file=sys.stderr,
        )
        return 2

    app_dir = Path(sys.argv[1]).resolve()
    trace_path = Path(sys.argv[2]).resolve()

    if not app_dir.is_dir():
        _fail(f"flutter app dir not found: {app_dir}")
        return 1
    if not trace_path.is_file():
        _fail(f"implementation trace not found: {trace_path}")
        return 1

    rows = _parse_trace(trace_path)
    if not rows:
        _fail("no traceability rows in implementation-trace.md")
        return 1

    errors: list[str] = []
    for row in rows:
        status = row["status"]
        if status not in STATUSES_OK:
            errors.append(f"{row['id']}: status must be implemented or deferred, got {status}")
        if status == "implemented":
            if not row["code"]:
                errors.append(f"{row['id']}: code path required when implemented")
            else:
                code_path = Path(row["code"])
                if not code_path.is_absolute():
                    code_path = (app_dir / code_path).resolve()
                if not code_path.exists():
                    errors.append(f"{row['id']}: missing code path {row['code']}")
        if status == "deferred" and not row["evidence"]:
            errors.append(f"{row['id']}: deferral requires evidence/ADR link")

    for cmd, label in (
        (["dart", "analyze", "lib"], "dart analyze"),
        (["flutter", "test"], "flutter test"),
    ):
        try:
            proc = subprocess.run(cmd, cwd=app_dir, capture_output=True, text=True, timeout=600)
        except FileNotFoundError:
            errors.append(f"{label}: command not found")
            continue
        if proc.returncode != 0:
            errors.append(f"{label} failed (exit {proc.returncode})")
            tail = (proc.stdout + proc.stderr).strip().splitlines()[-5:]
            for ln in tail:
                errors.append(f"  {ln}")

    if errors:
        for e in errors:
            _fail(e)
        return 1

    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
