#!/usr/bin/env python3
"""Validate quests backlog health."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _steward_lib import load_json  # noqa: E402


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("quests_dir", type=Path)
    args = p.parse_args()
    qdir = args.quests_dir.resolve()
    errors: list[str] = []

    backlog_path = qdir / "backlog.json"
    if not backlog_path.is_file():
        print(f"FAIL: missing {backlog_path}")
        return 1
    if not (qdir / "BACKLOG.md").is_file():
        errors.append("missing BACKLOG.md")
    if not (qdir / "steward-log.md").is_file():
        errors.append("missing steward-log.md")

    backlog = load_json(backlog_path)
    ids: set[str] = set()
    active = 0
    for q in backlog.get("quests") or []:
        qid = q.get("id") or ""
        if not qid:
            errors.append("quest missing id")
            continue
        if qid in ids:
            errors.append(f"duplicate id {qid}")
        ids.add(qid)
        track = q.get("track")
        if track not in ("main", "side", "needs_triage"):
            errors.append(f"{qid}: invalid track {track}")
        status = q.get("status")
        if status not in (
            "queued",
            "needs_triage",
            "doc",
            "design",
            "page",
            "done",
            "cancelled",
        ):
            errors.append(f"{qid}: invalid status {status}")
        if status in ("doc", "design", "page"):
            active += 1
            if not (qdir / qid / "quest.json").is_file():
                errors.append(f"{qid}: active but missing quest dir")
        if track != "needs_triage" and status != "needs_triage" and not q.get("classification_reason"):
            errors.append(f"{qid}: missing classification_reason")

    if active > 1:
        errors.append(f"more than one active quest ({active})")

    if errors:
        for e in errors:
            print(f"FAIL: {e}")
        return 1

    print(f"PASS: backlog ok ({len(ids)} quests, {active} active)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
