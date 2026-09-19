#!/usr/bin/env python3
"""Validate a quest stage gate: doc | design | page | done."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _steward_lib import dump_json, load_json, placeholder_filled, utc_now  # noqa: E402


def _fail(msg: str, errors: list[str]) -> None:
    errors.append(msg)


def validate_doc(qdir: Path, quest: dict, errors: list[str]) -> None:
    path = qdir / "01-quest-doc.md"
    if not placeholder_filled(path, min_chars=120):
        _fail("01-quest-doc.md missing or still template-like", errors)
    text = path.read_text(encoding="utf-8") if path.is_file() else ""
    for needle in ("## Goal", "## Entry", "## Acceptance"):
        if needle not in text:
            _fail(f"01-quest-doc.md missing section {needle}", errors)
    if not quest.get("fxx") and "needs_triage" not in str(quest.get("track")):
        # allow empty fxx only if waiver
        if "fxx-optional" not in (quest.get("waivers") or []):
            _fail("quest.json fxx empty (add Fxx or waiver fxx-optional)", errors)


def validate_design(qdir: Path, quest: dict, errors: list[str]) -> None:
    if quest.get("stages", {}).get("doc") != "PASS":
        _fail("doc stage must be PASS before design", errors)
    path = qdir / "02-ui-interaction-spec.md"
    if not placeholder_filled(path, min_chars=120):
        _fail("02-ui-interaction-spec.md missing or still template-like", errors)
    text = path.read_text(encoding="utf-8") if path.is_file() else ""
    for needle in ("## Element inventory", "## Interaction", "## Design acceptance"):
        if needle not in text:
            _fail(f"02-ui-interaction-spec.md missing section {needle}", errors)


def validate_page(qdir: Path, quest: dict, errors: list[str]) -> None:
    if quest.get("stages", {}).get("design") != "PASS":
        _fail("design stage must be PASS before page", errors)
    path = qdir / "03-acceptance.md"
    if not placeholder_filled(path, min_chars=80):
        _fail("03-acceptance.md missing or still template-like", errors)
    text = path.read_text(encoding="utf-8") if path.is_file() else ""
    if "lib/features/" not in text and "Flutter page" not in text:
        _fail("03-acceptance.md should record Flutter page path", errors)
    if "skip-assets" not in (quest.get("waivers") or []):
        if "05-ui-assets" not in text and "assets/images" not in text:
            _fail("03-acceptance.md should record asset package path (or waiver skip-assets)", errors)


def validate_done(qdir: Path, quest: dict, errors: list[str]) -> None:
    stages = quest.get("stages") or {}
    for s in ("doc", "design", "page"):
        if stages.get(s) != "PASS":
            _fail(f"stage {s} must be PASS before done", errors)
    acc = qdir / "03-acceptance.md"
    if acc.is_file() and "implemented" not in acc.read_text(encoding="utf-8") and "deferred" not in acc.read_text(
        encoding="utf-8"
    ):
        _fail("03-acceptance.md Trace write-back should mark implemented or deferred", errors)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("quest_dir", type=Path)
    p.add_argument("stage", choices=["doc", "design", "page", "done"])
    args = p.parse_args()

    qdir = args.quest_dir.resolve()
    qpath = qdir / "quest.json"
    if not qpath.is_file():
        print(f"FAIL: missing {qpath}")
        return 1

    quest = load_json(qpath)
    errors: list[str] = []

    if args.stage == "doc":
        validate_doc(qdir, quest, errors)
    elif args.stage == "design":
        validate_design(qdir, quest, errors)
    elif args.stage == "page":
        validate_page(qdir, quest, errors)
    else:
        validate_done(qdir, quest, errors)

    if errors:
        for e in errors:
            print(f"FAIL: {e}")
        return 1

    stages = quest.setdefault("stages", {})
    stages[args.stage] = "PASS"
    quest["updated_at"] = utc_now()

    # sync backlog status
    status_map = {"doc": "doc", "design": "design", "page": "page", "done": "done"}
    quest["status"] = status_map[args.stage]
    dump_json(qpath, quest)

    backlog_path = qdir.parent / "backlog.json"
    if backlog_path.is_file():
        backlog = load_json(backlog_path)
        for i, q in enumerate(backlog.get("quests") or []):
            if q.get("id") == quest.get("id"):
                backlog["quests"][i]["status"] = quest["status"]
                backlog["quests"][i]["updated_at"] = quest["updated_at"]
                break
        dump_json(backlog_path, backlog)
        # refresh md
        sys.path.insert(0, str(Path(__file__).resolve().parent))
        from _steward_lib import sync_backlog_md  # noqa: E402

        sync_backlog_md(qdir.parent, backlog)

    print(f"PASS: {quest.get('id')} stage={args.stage}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
