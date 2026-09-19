#!/usr/bin/env python3
"""Classify + enqueue a Feature Quest into backlog.json."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _steward_lib import (  # noqa: E402
    append_steward_log,
    classify,
    dump_json,
    load_json,
    next_quest_id,
    quests_dir,
    scaffold_quest_dir,
    sync_backlog_md,
    utc_now,
)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("workflow_slug_dir", type=Path)
    p.add_argument("--title", required=True)
    p.add_argument("--summary", default="")
    p.add_argument("--fxx", default="")
    p.add_argument("--priority", default="unknown")
    p.add_argument("--mvp-loop", action="store_true")
    p.add_argument("--infra", action="store_true")
    p.add_argument("--deferred-tab", action="store_true")
    p.add_argument("--track-override", choices=["main", "side", "needs_triage"])
    p.add_argument("--override-reason", default=None)
    p.add_argument("--scaffold", action="store_true", help="Also create quest dir templates now")
    p.add_argument("--page-slug", default="")
    p.add_argument("--flutter-feature", default="")
    args = p.parse_args()

    root = args.workflow_slug_dir.resolve()
    qdir = quests_dir(root)
    backlog_path = qdir / "backlog.json"
    if not backlog_path.is_file():
        print(f"FAIL: missing {backlog_path}; run init_quests.py first")
        return 1

    fxx = [x for x in args.fxx.split(",") if x.strip()]
    try:
        verdict = classify(
            title=args.title,
            summary=args.summary,
            fxx=fxx,
            priority=args.priority,
            mvp_loop=args.mvp_loop,
            infra=args.infra,
            deferred_tab=args.deferred_tab,
            track_override=args.track_override,
            override_reason=args.override_reason,
        )
    except ValueError as exc:
        print(f"FAIL: {exc}")
        return 2

    backlog = load_json(backlog_path)
    qid = next_quest_id(backlog, args.title)
    now = utc_now()
    entry = {
        "id": qid,
        "title": args.title,
        "summary": args.summary,
        "track": verdict["track"],
        "kind": verdict["kind"],
        "status": verdict["status"],
        "priority": verdict["priority"],
        "fxx": verdict["fxx"],
        "mvp_loop": verdict["mvp_loop"],
        "infra": verdict["infra"],
        "classification_reason": verdict["reason"],
        "track_override": args.track_override,
        "override_reason": args.override_reason,
        "page_slug": args.page_slug,
        "flutter_feature": args.flutter_feature,
        "created_at": now,
        "updated_at": now,
    }
    backlog.setdefault("quests", []).append(entry)
    backlog["product_slug"] = root.name
    dump_json(backlog_path, backlog)
    sync_backlog_md(qdir, backlog)

    append_steward_log(
        qdir,
        f"**enqueue** `{qid}` → track=`{verdict['track']}` status=`{verdict['status']}`\n\n"
        f"- title: {args.title}\n"
        f"- reason: {verdict['reason']}\n"
        f"- fxx: {', '.join(verdict['fxx']) or '—'}",
    )

    if args.scaffold and verdict["status"] != "needs_triage":
        quest_full = {
            **entry,
            "product_slug": root.name,
            "force_side": False,
            "route": "",
            "waivers": [],
            "stages": {
                "doc": "PENDING",
                "design": "PENDING",
                "page": "PENDING",
                "done": "PENDING",
            },
        }
        scaffold_quest_dir(qdir, quest_full)

    print(f"PASS: enqueued {qid} track={verdict['track']} status={verdict['status']}")
    print(f"reason: {verdict['reason']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
